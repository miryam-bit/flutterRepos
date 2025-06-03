<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Food; // Import the Food model
use Illuminate\Support\Facades\DB; // Import DB facade for direct insertion if needed

class FoodSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Clear existing data from the foods table before seeding
        DB::table('foods')->delete();

        $foods = [
            // Burgers
            [
                'name' => 'Classic Cheeseburger',
                'description' => 'A juicy beef patty with melted cheddar cheese, lettuce, tomato, and our special sauce.',
                'price' => 9.99,
                'image_path' => 'lib/images/burgers/burger-1.png',
                'category' => 'Burgers',
                'available_addons' => json_encode([
                    ['name' => 'Extra Patty', 'price' => 2.50],
                    ['name' => 'Bacon', 'price' => 1.50],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'BBQ Bacon Burger',
                'description' => 'Smoky BBQ sauce, crispy bacon, and a perfectly grilled patty.',
                'price' => 11.50,
                'image_path' => 'lib/images/burgers/burger-2.webp',
                'category' => 'Burgers',
                'available_addons' => json_encode([
                    ['name' => 'Onion Rings', 'price' => 1.75],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Chicken Burger',
                'description' => 'A delicious chicken burger with a tender grilled or crispy chicken fillet, lettuce, and mayo.',
                'price' => 8.99,
                'image_path' => 'lib/images/burgers/burger-4.png',
                'category' => 'Burgers',
                'available_addons' => json_encode([
                    ['name' => 'Extra Cheese', 'price' => 0.99],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Special Burger',
                'description' => 'Our special burger with a unique combination of ingredients and a secret sauce.',
                'price' => 12.99,
                'image_path' => 'lib/images/burgers/burger-5.png',
                'category' => 'Burgers',
                'available_addons' => json_encode([
                    ['name' => 'Special Sauce', 'price' => 1.00],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            // Salads
            [
                'name' => 'Caesar Salad',
                'description' => 'Crisp romaine lettuce, parmesan cheese, croutons, and Caesar dressing.',
                'price' => 7.50,
                'image_path' => 'lib/images/salads/salad2.png',
                'category' => 'Salads',
                'available_addons' => json_encode([
                    ['name' => 'Grilled Chicken', 'price' => 3.00],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Greek Salad',
                'description' => 'Tomatoes, cucumbers, olives, feta cheese, and a light vinaigrette.',
                'price' => 8.00,
                'image_path' => 'lib/images/salads/salad3.png',
                'category' => 'Salads',
                'available_addons' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Chicken Salad',
                'description' => 'A fresh and healthy chicken salad with crisp greens and a light vinaigrette.',
                'price' => 9.00,
                'image_path' => 'lib/images/salads/salad4.png',
                'category' => 'Salads',
                'available_addons' => json_encode([
                    ['name' => 'Extra Dressing', 'price' => 0.50],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Cheese Salad',
                'description' => 'A delightful cheese salad featuring a mix of fresh vegetables and assorted cheeses.',
                'price' => 7.00,
                'image_path' => 'lib/images/salads/salad5.png',
                'category' => 'Salads',
                'available_addons' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            // Desserts
            [
                'name' => 'Ice Cream',
                'description' => 'Creamy and delicious ice cream, available in various flavors.',
                'price' => 4.50,
                'image_path' => 'lib/images/desserts/Desserts-1.png',
                'category' => 'Desserts',
                'available_addons' => json_encode([
                    ['name' => 'Chocolate Sauce', 'price' => 0.75],
                    ['name' => 'Sprinkles', 'price' => 0.50],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Cup Cake',
                'description' => 'A delightful cupcake, perfect for a sweet treat.',
                'price' => 3.00,
                'image_path' => 'lib/images/desserts/Desserts-2.png',
                'category' => 'Desserts',
                'available_addons' => json_encode([
                    ['name' => 'Extra Frosting', 'price' => 0.50],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Chocolate Cake',
                'description' => 'Rich and decadent chocolate cake, a chocolate lover\'s dream.',
                'price' => 6.00,
                'image_path' => 'lib/images/desserts/Desserts-3.png',
                'category' => 'Desserts',
                'available_addons' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Donuts',
                'description' => 'Sweet and fluffy donuts, glazed or filled.',
                'price' => 2.50,
                'image_path' => 'lib/images/desserts/Desserts-4.png',
                'category' => 'Desserts',
                'available_addons' => json_encode([
                    ['name' => 'Chocolate Glaze', 'price' => 0.50],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            // Sides
            [
                'name' => 'French Fries',
                'description' => 'Crispy golden french fries.',
                'price' => 3.50,
                'image_path' => 'lib/images/sides/Side-3.jpg',
                'category' => 'Sides',
                'available_addons' => json_encode([
                    ['name' => 'Cheese Sauce', 'price' => 1.00],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Onion Rings',
                'description' => 'Battered and fried onion rings.',
                'price' => 4.00,
                'image_path' => 'lib/images/sides/Side-4.jpg',
                'category' => 'Sides',
                'available_addons' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Special Mini Fries',
                'description' => 'Special seasoned fries, mini portion.',
                'price' => 2.50,
                'image_path' => 'lib/images/sides/Side-1.jpg',
                'category' => 'Sides',
                'available_addons' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Cooked Eggs (Ukun)',
                'description' => 'Perfectly cooked eggs, served as a side.',
                'price' => 3.00,
                'image_path' => 'lib/images/sides/Side-5.jpg',
                'category' => 'Sides',
                'available_addons' => json_encode([
                    ['name' => 'Salt & Pepper', 'price' => 0.10],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            // Drinks
            [
                'name' => 'Coca-Cola',
                'description' => 'Classic Coca-Cola.',
                'price' => 2.00,
                'image_path' => 'lib/images/drinks/Drink-1.png',
                'category' => 'Drinks',
                'available_addons' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Lemonade',
                'description' => 'Freshly squeezed lemonade.',
                'price' => 2.50,
                'image_path' => 'lib/images/drinks/Drink-2.png',
                'category' => 'Drinks',
                'available_addons' => json_encode([
                    ['name' => 'Strawberry Flavor', 'price' => 0.50],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Orange Juice',
                'description' => 'Freshly squeezed orange juice, packed with vitamin C.',
                'price' => 2.75,
                'image_path' => 'lib/images/drinks/Drink-3.png',
                'category' => 'Drinks',
                'available_addons' => json_encode([]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Ice Coffee',
                'description' => 'Chilled and energizing ice coffee.',
                'price' => 3.50,
                'image_path' => 'lib/images/drinks/Drink-4.png',
                'category' => 'Drinks',
                'available_addons' => json_encode([
                    ['name' => 'Extra Espresso Shot', 'price' => 1.00],
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        // Insert data into the 'foods' table
        // Using DB facade for mass insertion can be more efficient
        DB::table('foods')->insert($foods);

        // Alternatively, using Eloquent model (can be slower for large datasets due to event firing):
        // foreach ($foods as $foodData) {
        //     Food::create($foodData);
        // }
    }
}
