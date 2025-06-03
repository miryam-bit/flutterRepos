import 'package:collection/collection.dart';
import 'package:delivery_app/models/cart_item.dart';
import 'package:delivery_app/models/food.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Restaurant extends ChangeNotifier {
  List<Food> _menu = [];

  final String _apiUrl = "http://192.168.1.107:8000/api/foods";

  String _deliveryAddress = '99 Hollywood Bvd';
  
  String get deliveryAddress => _deliveryAddress;

  List<Food> get menu => _menu;

  final List<CartItem> _cart = [];
  List<CartItem> get cart => _cart;

  final List<String> _orderHistory = [];
  List<String> get orderHistory => _orderHistory.reversed.toList();

  bool _isLoading = true;
  String? _error;

  bool _isPlacingOrder = false;
  String? _placeOrderError;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get placeOrderError => _placeOrderError;

  String get _baseApiUrl {
    if (_apiUrl.endsWith("/foods")) {
      return _apiUrl.substring(0, _apiUrl.length - "/foods".length);
    }
    return _apiUrl;
  }

  Future<void> fetchMenu(String? token) async {
    _isLoading = true;
    _error = null;
    if (token == null) {
        _error = "Authentication token not found. Please log in.";
        _isLoading = false;
        notifyListeners();
        return;
    }

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _menu = data.map((json) => Food.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        _error = "Unauthorized. Please log in again.";
        _menu = [];
      } else {
        _error = "Failed to load menu. Status code: ${response.statusCode}";
        _menu = [];
      }
    } catch (e) {
      _error = "Failed to load menu. Error: $e";
      _menu = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> placeOrder(
      {required String token,
      required String deliveryAddress,
      double deliveryFee = 0.0,
      String? notes}) async {
    _isPlacingOrder = true;
    _placeOrderError = null;
    notifyListeners();

    if (_cart.isEmpty) {
      _isPlacingOrder = false;
      _placeOrderError = "Cart is empty. Please add items to your cart.";
      notifyListeners();
      return {'success': false, 'message': _placeOrderError};
    }

    List<Map<String, dynamic>> itemsPayload = _cart.map((cartItem) {
      return {
        'food_id': cartItem.food.id,
        'quantity': cartItem.quantity,
        'addons_details': cartItem.selectedAddons.map((addon) => {
          'name': addon.name,
          'price': addon.price,
        }).toList(),
      };
    }).toList();

    Map<String, dynamic> body = {
      'delivery_address': deliveryAddress,
      'items': itemsPayload,
      'delivery_fee': deliveryFee,
    };
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseApiUrl/orders'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      _isPlacingOrder = false;
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        clearCart();
        notifyListeners();
        return {'success': true, 'order': responseBody};
      } else {
        _placeOrderError = "Failed to place order: ${responseBody['message'] ?? response.reasonPhrase}";
        notifyListeners();
        return {'success': false, 'message': _placeOrderError};
      }
    } catch (e) {
      _isPlacingOrder = false;
      _placeOrderError = "Failed to place order. Error: $e";
      notifyListeners();
      return {'success': false, 'message': _placeOrderError};
    }
  }

  void addToCart(Food food, List<Addon> selectedAddons) {
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      bool isSameFood = item.food == food;
      bool isSameAddons =
          ListEquality().equals(item.selectedAddons, selectedAddons);
      return isSameFood && isSameAddons;
    });

    if (cartItem != null) {
      cartItem.quantity++;
    } else {
      _cart.add(
        CartItem(
          food: food,
          selectedAddons: selectedAddons,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);
    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

  double getTotalPrice() {
    double total = 0.0;
    for (CartItem cartItem in _cart) {
      double itemTotal = cartItem.food.price;
      for (Addon addon in cartItem.selectedAddons) {
        itemTotal += addon.price;
      }
      total += itemTotal * cartItem.quantity;
    }
    return total;
  }

  int getTotalItemCount() {
    int totalItemCount = 0;
    for (CartItem cartItem in _cart) {
      totalItemCount += cartItem.quantity;
    }
    return totalItemCount;
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln("Here is your receipt.");
    receipt.writeln();

    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    receipt.writeln(formattedDate);
    receipt.writeln();
    receipt.writeln("----------");

    for (final cartItem in _cart) {
      receipt.writeln(
          "${cartItem.quantity} x ${cartItem.food.name} - ${_formatPrice(cartItem.food.price)}");
      if (cartItem.selectedAddons.isNotEmpty) {
        receipt
            .writeln("   Add-ons: ${_formatAddons(cartItem.selectedAddons)}");
      }
      receipt.writeln();
    }
    receipt.writeln("----------");
    receipt.writeln();
    receipt.writeln("Total Items: ${getTotalItemCount()}");
    receipt.writeln("Total Price: ${_formatPrice(getTotalPrice())}");
    receipt.writeln();
    receipt.writeln("Delivering to: $deliveryAddress");

    return receipt.toString();
  }

  String _formatPrice(double price) {
    return "\$${price.toStringAsFixed(2)}";
  }

  String _formatAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }

  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }

  void recordOrder() {
    final String receipt = displayCartReceipt();
    _orderHistory.add(receipt);
    notifyListeners();
  }
}