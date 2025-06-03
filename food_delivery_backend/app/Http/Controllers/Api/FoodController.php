<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Food;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Storage; // Added for file storage

class FoodController extends Controller
{
    /**
     * Display a listing of the resource. (Public)
     */
    public function index()
    {
        // Consider adding pagination for large menus: Food::paginate(15)
        $foods = Food::orderBy('name')->get(); 
        return response()->json($foods);
    }

    /**
     * Store a newly created food item in storage. (Admin only)
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255|unique:foods,name',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            // 'image_path' => 'required|string|max:255', // Changed to image validation
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048', // Image validation
            'category' => ['required', 'string', Rule::in(['Burgers', 'Salads', 'Sides', 'Desserts', 'Drinks'])], 
            'available_addons' => 'nullable|array',
            'available_addons.*.name' => 'required_with:available_addons|string|max:255',
            'available_addons.*.price' => 'required_with:available_addons|numeric|min:0',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('foods', 'public'); // Stores in storage/app/public/foods
            $validatedData['image_path'] = $path;
        }
        
        // Remove the 'image' key as it's not a column in the foods table
        unset($validatedData['image']);

        $food = Food::create($validatedData);
        
        // Return the food item with the correct image_path (which might be transformed by an accessor in the model)
        return response()->json([
            'message' => 'Food item created successfully!',
            'food' => $food->fresh() // Use fresh() to get the model with accessors applied if any
        ], 201);
    }

    /**
     * Display the specified food item. (Primarily for Admin to edit, but can be public if needed)
     */
    public function show(Food $food) // Route model binding
    {
        return response()->json($food);
    }

    /**
     * Update the specified food item in storage. (Admin only)
     */
    public function update(Request $request, Food $food) // Route model binding
    {
        $validatedData = $request->validate([
            'name' => ['required', 'string', 'max:255', Rule::unique('foods', 'name')->ignore($food->id)],
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            // 'image_path' => 'sometimes|string|max:255', // Changed to image validation
            'image' => 'sometimes|image|mimes:jpeg,png,jpg,gif,svg|max:2048', // Image validation, sometimes means it's optional for update
            'category' => ['required', 'string', Rule::in(['Burgers', 'Salads', 'Sides', 'Desserts', 'Drinks'])],
            'available_addons' => 'nullable|array',
            'available_addons.*.name' => 'required_with:available_addons|string|max:255',
            'available_addons.*.price' => 'required_with:available_addons|numeric|min:0',
        ]);

        if ($request->hasFile('image')) {
            // Delete old image if it exists
            if ($food->image_path) {
                Storage::disk('public')->delete($food->image_path);
            }
            // Store new image
            $path = $request->file('image')->store('foods', 'public');
            $validatedData['image_path'] = $path;
        }

        // Remove the 'image' key as it's not a column in the foods table
        unset($validatedData['image']);

        $food->update($validatedData);
        
        return response()->json([
            'message' => 'Food item updated successfully!',
            'food' => $food->fresh() // Use fresh() to get model with accessors
        ]);
    }

    /**
     * Remove the specified food item from storage. (Admin only)
     */
    public function destroy(Food $food) // Route model binding
    {
        // Delete the associated image file if it exists
        if ($food->image_path) {
            Storage::disk('public')->delete($food->image_path);
        }
        $food->delete();
        return response()->json(['message' => 'Food item deleted successfully.'], 200); // Changed from 204 to 200 to allow message
    }
}
