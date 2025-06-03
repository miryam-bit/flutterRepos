import 'package:delivery_app/models/order_item.dart';
import 'package:delivery_app/models/user.dart'; // Import the User model

class Order {
  final int id;
  final int userId; // This is the ID of the customer who placed the order
  final User? user; // Optional: To store the full customer User object if backend provides it
  final String deliveryAddress;
  final double? deliveryLatitude; // Added for map integration
  final double? deliveryLongitude; // Added for map integration
  final double totalAmount;
  final String status;
  final double? deliveryFee; // Made nullable as backend might not always return it or it could be 0
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final int? driverId; // ID of the assigned driver
  final User? driver; // The assigned driver User object
  final DateTime? assignedAt;

  Order({
    required this.id,
    required this.userId,
    this.user,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.totalAmount,
    required this.status,
    this.deliveryFee,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.driverId,
    this.driver,
    this.assignedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? []; // Get the list, or an empty list if null
    List<OrderItem> parsedItems = itemsList
        .where((itemJson) => itemJson is Map<String, dynamic>) // Filter out nulls or non-Map items
        .map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    // Helper function to safely parse numbers that might be strings
    double? safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null; // Or throw an error, or return a default
    }

    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null; // Or throw an error, or return a default
    }

    return Order(
      id: safeParseInt(json['id']) ?? 0, // Default to 0 or handle error if null
      userId: safeParseInt(json['user_id']) ?? 0, // Default to 0 or handle error if null
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      deliveryAddress: json['delivery_address'] as String? ?? 'N/A',
      deliveryLatitude: safeParseDouble(json['delivery_latitude']),
      deliveryLongitude: safeParseDouble(json['delivery_longitude']),
      totalAmount: safeParseDouble(json['total_amount']) ?? 0.0,
      status: json['status'] as String? ?? 'unknown',
      deliveryFee: safeParseDouble(json['delivery_fee']),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      items: parsedItems,
      driverId: safeParseInt(json['driver_id']),
      driver: json['driver'] != null ? User.fromJson(json['driver'] as Map<String, dynamic>) : null,
      assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at'] as String) : null,
    );
  }

  // Optional: toJson for sending to backend (less likely for this specific model from client)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user': user?.toJson(),
      'delivery_address': deliveryAddress,
      'total_amount': totalAmount,
      'status': status,
      'delivery_fee': deliveryFee,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'driver_id': driverId,
      'driver': driver?.toJson(),
      'assigned_at': assignedAt?.toIso8601String(),
    };
  }
} 