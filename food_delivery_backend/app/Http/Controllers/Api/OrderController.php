<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Food;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http; // Added for Google Maps API calls
use Illuminate\Support\Facades\Log; // Added for logging API errors
use Illuminate\Validation\Rule;
use Throwable; // For catching exceptions in transaction

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        $query = Order::query(); // Start with a base query

        if ($user->role === 'admin') {
            // Admin sees all orders, ordered by most recent
            $orders = $query->orderBy('created_at', 'desc')->get();
        } elseif ($user->role === 'delivery') {
            $orders = $query->where(function ($q) use ($user) {
                // Condition 1: Order is UNASSIGNED (driver_id is NULL)
                // Show all unassigned orders so drivers can see everything in the pool.
                $q->whereNull('driver_id');
            })->orWhere(function ($q) use ($user) {
                // Condition 2: Order is ASSIGNED TO THE CURRENT DRIVER
                // and is in 'out_for_delivery' status.
                $q->where('driver_id', $user->id)
                  ->where('status', 'out_for_delivery');
            })
            ->orderByRaw("CASE WHEN driver_id IS NULL THEN 0 ELSE 1 END ASC") // Unassigned first
            ->orderBy('status', 'asc') // Then by status (e.g., pending, confirmed before out_for_delivery for unassigned)
            ->orderBy('created_at', 'asc') // Then by oldest (for unassigned pool)
            ->get();
        } else {
            // Regular user sees only their own orders
            $orders = $query->where('user_id', $user->id)
                             ->orderBy('created_at', 'desc')
                             ->get();
        }

        return response()->json($orders);
    }

    /**
     * Allows a delivery person to assign an order to themselves.
     */
    public function takeOrder(Request $request, string $orderId)
    {
        $user = Auth::user();
        if ($user->role !== 'delivery') {
            return response()->json(['message' => 'Only delivery personnel can take orders.'], 403);
        }

        $order = Order::find($orderId);

        if (!$order) {
            return response()->json(['message' => 'Order not found.'], 404);
        }

        if ($order->driver_id !== null) {
            if ($order->driver_id === $user->id) {
                // If already assigned to this driver, and status is not yet 'out_for_delivery',
                // this action can confirm they are starting it.
                if ($order->status !== 'out_for_delivery') {
                    $order->status = 'out_for_delivery';
                    $order->assigned_at = $order->assigned_at ?? now(); // Update assigned_at if it was null (e.g. pre-assigned by admin)
                    $order->save();
                    return response()->json(['message' => 'Order confirmed for delivery.', 'order' => $order], 200);
                }
                return response()->json(['message' => 'Order already assigned to you and is out for delivery.', 'order' => $order], 200);
            }
            return response()->json(['message' => 'Order already assigned to another driver.'], 409); // 409 Conflict
        }

        // If order is unassigned, assign it and set status to out_for_delivery
        DB::beginTransaction();
        try {
            $order->driver_id = $user->id;
            $order->assigned_at = now();
            $order->status = 'out_for_delivery'; // Automatically update status
            $order->save();
            DB::commit();

            return response()->json($order, 200);
        } catch (Throwable $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to take order. ' . $e->getMessage()], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'delivery_address' => 'required|string|max:255',
            'delivery_fee' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string|max:1000',
            'items' => 'required|array|min:1',
            'items.*.food_id' => ['required', Rule::exists('foods', 'id')],
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.addons_details' => 'nullable|array',
        ]);

        $deliveryLat = null;
        $deliveryLng = null;
        $apiKey = config('services.google_maps.api_key');

        if ($apiKey && !empty($validatedData['delivery_address'])) {
            try {
                $response = Http::get('https://maps.googleapis.com/maps/api/geocode/json', [
                    'address' => $validatedData['delivery_address'],
                    'key' => $apiKey,
                ]);

                if ($response->successful() && isset($response->json()['results'][0]['geometry']['location'])) {
                    $location = $response->json()['results'][0]['geometry']['location'];
                    $deliveryLat = $location['lat'];
                    $deliveryLng = $location['lng'];
                } else {
                    Log::warning('Geocoding API call failed or returned no results for address: ' . $validatedData['delivery_address'], [
                        'response_status' => $response->status(),
                        'response_body' => $response->body(),
                    ]);
                }
            } catch (Throwable $e) {
                Log::error('Exception during Geocoding API call: ' . $e->getMessage(), [
                    'address' => $validatedData['delivery_address']
                ]);
            }
        }

        try {
            return DB::transaction(function () use ($validatedData, $request, $deliveryLat, $deliveryLng) {
                $user = Auth::user();
                $orderTotal = 0;

                foreach ($validatedData['items'] as $itemData) {
                    $food = Food::find($itemData['food_id']);
                    if (!$food) {
                        return response()->json(['message' => 'Invalid food item found.'], 400);
                    }
                    $itemPrice = $food->price * $itemData['quantity'];
                    if (isset($itemData['addons_details']) && is_array($itemData['addons_details'])) {
                        foreach ($itemData['addons_details'] as $addon) {
                            if (isset($addon['price']) && is_numeric($addon['price'])) {
                                $itemPrice += $addon['price'] * $itemData['quantity'];
                            }
                        }
                    }
                    $orderTotal += $itemPrice;
                }
                
                $deliveryFee = $validatedData['delivery_fee'] ?? 0;
                $orderTotal += $deliveryFee;

                $order = $user->orders()->create([
                    'delivery_address' => $validatedData['delivery_address'],
                    'delivery_latitude' => $deliveryLat,
                    'delivery_longitude' => $deliveryLng,
                    'total_amount' => $orderTotal,
                    'status' => 'pending',
                    'delivery_fee' => $deliveryFee,
                    'notes' => $validatedData['notes'] ?? null,
                ]);

                foreach ($validatedData['items'] as $itemData) {
                    $food = Food::find($itemData['food_id']);
                    $priceAtTimeOfOrder = $food->price;
                    $addonsDetailsForStorage = $itemData['addons_details'] ?? [];
                    $order->items()->create([
                        'food_id' => $food->id,
                        'quantity' => $itemData['quantity'],
                        'price_at_time_of_order' => $priceAtTimeOfOrder,
                        'addons_details' => $addonsDetailsForStorage,
                    ]);
                }
                $order->load(['items.food', 'user']); 
                return response()->json($order, 201);
            });
        } catch (Throwable $e) {
            Log::error('Order creation transaction failed: ' . $e->getMessage());
            return response()->json(['message' => 'Failed to create order. ' . $e->getMessage()], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $user = Auth::user();
        // Order model eager loads relationships
        $order = Order::findOrFail($id);

        // Admin can see any order.
        // Regular user can only see their own order.
        // Delivery person can see any order assigned to them OR any unassigned order.
        if ($user->role === 'admin') {
            // No additional checks needed for admin
        } elseif ($user->role === 'delivery') {
            // Allow if order is assigned to current delivery person OR if the order is unassigned (driver_id is null)
            if (!($order->driver_id === $user->id || $order->driver_id === null)) {
                return response()->json(['message' => 'You are not authorized to view this order.'], 403);
            }
        } else { // Regular user
            if ($order->user_id !== $user->id) {
                return response()->json(['message' => 'You are not authorized to view this order.'], 403);
            }
        }
        
        return response()->json($order);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $user = Auth::user();
        $order = Order::findOrFail($id);

        $validated = $request->validate([
            'status' => ['required', 'string'], // Validation rules will be more specific below
        ]);

        $newStatus = $validated['status'];

        if ($user->role === 'admin') {
            // Admin can set any of these statuses
            if (!in_array($newStatus, ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled', 'failed'])) {
                return response()->json(['message' => 'Invalid status value for admin.'], 422);
            }
        } elseif ($user->role === 'delivery') {
            // Delivery personnel can only update orders assigned to them
            if ($order->driver_id !== $user->id) {
                return response()->json(['message' => 'You can only update orders assigned to you.'], 403);
            }
            // Delivery personnel can only set these specific statuses
            if (!in_array($newStatus, ['delivered', 'failed'])) { // 'out_for_delivery' is set by takeOrder
                return response()->json(['message' => 'Invalid status value for delivery personnel.'], 422);
            }
             // Prevent updating status if it's already delivered, cancelled or failed by driver
            if (in_array($order->status, ['delivered', 'cancelled', 'failed'])) {
                return response()->json(['message' => "Order is already in a final state ('{$order->status}') and cannot be updated by driver."], 409);
            }

        } else {
            // Other roles (e.g., regular user) cannot update status via this endpoint
            return response()->json(['message' => 'Unauthorized to update order status.'], 403);
        }

        $order->status = $newStatus;
        $order->save();

        // Order model already eager loads relationships
        return response()->json($order);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        // Future: For admin to cancel/delete an order (soft delete preferrably)
        // e.g., $order = Order::findOrFail($id);
        // $this->authorize('delete', $order); // If using policies
        // $order->delete(); // or $order->update(['status' => 'cancelled']);
        // return response()->json(null, 204); // 204 No Content
    }
}
