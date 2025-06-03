<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class DeliveryPersonnelSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::factory()->create([
            'name' => 'Mustafa Atwi',
            'email' => '3at3at@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'delivery',
        ]);

        User::factory()->create([
            'name' => 'Torms',
            'email' => 'torms@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'delivery',
        ]);

        User::factory()->create([
            'name' => 'Mason',
            'email' => 'mason@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'delivery',
        ]);
    }
} 