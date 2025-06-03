<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->foreignId('driver_id')->nullable()->constrained('users')->onDelete('set null'); // Links to users table
            $table->timestamp('assigned_at')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['driver_id']); // Important for clean rollback
            $table->dropColumn('driver_id');
            $table->dropColumn('assigned_at');
        });
    }
};