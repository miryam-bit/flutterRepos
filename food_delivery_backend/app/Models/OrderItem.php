<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'food_id',
        'quantity',
        'price_at_time_of_order',
        'addons_details',
    ];

    /**
     * The relationships that should always be loaded.
     *
     * @var array
     */
    protected $with = ['food'];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'addons_details' => 'array', // Automatically encode/decode JSON
    ];

    /**
     * Get the order that this item belongs to.
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Get the food item associated with this order item.
     */
    public function food(): BelongsTo
    {
        return $this->belongsTo(Food::class);
    }
}
