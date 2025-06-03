import 'dart:convert';

class Food {
  final int id;
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final FoodCategory category;
  List<Addon> avaliableAddons;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.avaliableAddons,
  });

  // Factory constructor to create a Food object from a JSON map
  factory Food.fromJson(Map<String, dynamic> json) {
    // Helper to parse the category string to enum
    FoodCategory parseCategory(String categoryStr) {
      switch (categoryStr.toLowerCase()) {
        case 'burgers':
          return FoodCategory.Burgers;
        case 'salads':
          return FoodCategory.Salads;
        case 'sides':
          return FoodCategory.Sides;
        case 'desserts':
          return FoodCategory.Desserts;
        case 'drinks':
          return FoodCategory.Drinks;
        default:
          // Fallback or throw error if category is unknown
          // For now, defaulting to Burgers if unknown, consider better error handling
          print('Unknown category string: $categoryStr, defaulting to Burgers.');
          return FoodCategory.Burgers; 
      }
    }

    // available_addons is expected to be a List<dynamic> (list of maps) from JSON
    List<Addon> parsedAddons = [];
    if (json['available_addons'] != null && json['available_addons'] is List) {
      List<dynamic> addonsData = json['available_addons'] as List<dynamic>;
      parsedAddons = addonsData
          .map((addonJson) => Addon.fromJson(addonJson as Map<String, dynamic>))
          .toList();
    }

    return Food(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['image_path'] as String,
      price: (json['price'] is String) ? double.parse(json['price']) : (json['price'] as num).toDouble(),
      category: parseCategory(json['category'] as String),
      avaliableAddons: parsedAddons,
    );
  }

  // Method to convert Food object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'price': price,
      // Convert enum to string: remove "FoodCategory." prefix
      'category': category.toString().split('.').last, 
      'available_addons': avaliableAddons.map((addon) => addon.toJson()).toList(),
    };
  }
}

enum FoodCategory {
  Burgers,
  Salads,
  Sides,
  Desserts,
  Drinks,
}

class Addon {
  String name;
  double price;

  Addon({required this.name, required this.price});

  // Factory constructor to create an Addon object from a JSON map
  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      name: json['name'] as String,
      price: (json['price'] is String) ? double.parse(json['price']) : (json['price'] as num).toDouble(),
    );
  }

  // Optional: Method to convert Addon object to JSON map (if sending data TO API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
