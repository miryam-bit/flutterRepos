import 'package:delivery_app/models/food.dart'; // For Food and Addon models

class OrderItem {
  final int id;
  final int orderId;
  final int foodId;
  final int quantity;
  final double priceAtTimeOfOrder;
  final List<Addon> addonsDetails;
  final Food food; // Eager-loaded food details

  OrderItem({
    required this.id,
    required this.orderId,
    required this.foodId,
    required this.quantity,
    required this.priceAtTimeOfOrder,
    required this.addonsDetails,
    required this.food,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    var addonsList = json['addons_details'] as List? ?? [];
    List<Addon> parsedAddons = addonsList
        .where((addonJson) => addonJson is Map<String, dynamic>) // Filter out nulls/non-Maps
        .map((addonJson) => Addon.fromJson(addonJson as Map<String, dynamic>))
        .toList();

    final foodData = json['food'];
    if (foodData == null || !(foodData is Map<String, dynamic>)) {
      throw FormatException(
          "Invalid or missing 'food' data for OrderItem ID: ${json['id']}. Expected a Map but got ${foodData.runtimeType}.");
    }

    return OrderItem(
      id: json['id'] is String ? int.parse(json['id'] as String) : json['id'] as int,
      orderId: json['order_id'] is String ? int.parse(json['order_id'] as String) : json['order_id'] as int,
      foodId: json['food_id'] is String ? int.parse(json['food_id'] as String) : json['food_id'] as int,
      quantity: json['quantity'] is String ? int.parse(json['quantity'] as String) : json['quantity'] as int,
      priceAtTimeOfOrder: json['price_at_time_of_order'] is String 
          ? double.parse(json['price_at_time_of_order'] as String) 
          : (json['price_at_time_of_order'] as num).toDouble(),
      addonsDetails: parsedAddons,
      food: Food.fromJson(foodData as Map<String, dynamic>), // Now foodData is guaranteed to be a Map
    );
  }

  // Optional: toJson method if you ever need to send this model to the backend
  // For now, it's primarily for deserialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'food_id': foodId,
      'quantity': quantity,
      'price_at_time_of_order': priceAtTimeOfOrder,
      'addons_details': addonsDetails.map((addon) => addon.toJson()).toList(),
      'food': food.toJson(), // Assuming Food model has toJson
    };
  }
} 