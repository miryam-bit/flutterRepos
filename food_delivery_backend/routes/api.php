<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrderController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/foods', [FoodController::class, 'index'])->middleware('auth:sanctum');

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

Route::post('/orders', [OrderController::class, 'store'])->middleware('auth:sanctum');
Route::get('/orders', [OrderController::class, 'index'])->middleware('auth:sanctum');
Route::get('/orders/{order}', [OrderController::class, 'show'])->middleware('auth:sanctum');

// Route for delivery personnel to take an order
Route::post('/orders/{order}/take', [OrderController::class, 'takeOrder'])->middleware('auth:sanctum');

Route::get('/foods', [FoodController::class, 'index']);
Route::get('/foods/{food}', [FoodController::class, 'show']);

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::post('/foods', [FoodController::class, 'store']);
    Route::put('/foods/{food}', [FoodController::class, 'update']);
    Route::patch('/foods/{food}', [FoodController::class, 'update']);
    Route::delete('/foods/{food}', [FoodController::class, 'destroy']);

    // Admin can update orders (this already covers PUT and PATCH for admins)
    Route::match(['PUT', 'PATCH'], '/orders/{order}', [OrderController::class, 'update']); 
});

// Route for authenticated users (including delivery) to update orders (PUT or PATCH)
// Specific logic within OrderController@update handles role permissions
Route::match(['PUT', 'PATCH'], '/orders/{order}', [OrderController::class, 'update'])->middleware('auth:sanctum');
