import 'dart:convert';
import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For storing the token
import 'package:http_parser/http_parser.dart'; // Required for MediaType

class AuthService with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user; // To store user data

  // Base URL of your Laravel API
  // Make sure this is the correct IP for your local machine when testing on an emulator/device
  // For Android emulator, 10.0.2.2 usually points to the host machine
  // For physical devices, use your machine's local network IP (e.g., 192.168.1.X)
  // Ensure your Laravel server is running with `php artisan serve --host=0.0.0.0`
  final String _baseUrl = "http://192.168.1.107:8000/api"; // Adjust if necessary

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _token != null;

  // Getter to check if the current user is an admin
  bool get isAdmin {
    return _user != null && _user!['role'] == 'admin';
  }

  // Getter to check if the current user is a delivery personnel
  bool get isDeliveryPersonnel {
    return _user != null && _user!['role'] == 'delivery';
  }

  String get baseUrl => _baseUrl; // Added public getter

  AuthService() {
    _loadToken(); // Load token when AuthService is initialized
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    String? userString = prefs.getString('user_data');
    if (userString != null) {
      _user = jsonDecode(userString);
    }
    notifyListeners();
  }

  Future<void> _saveToken(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userData));
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      _token = responseData['access_token'];
      _user = responseData['user'];
      await _saveToken(_token!, _user!);
      notifyListeners();
      return {'success': true, 'user': _user, 'token': _token};
    } else {
      final responseData = jsonDecode(response.body);
      return {'success': false, 'message': 'Registration failed', 'errors': responseData};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _token = responseData['access_token'];
      _user = responseData['user'];
      await _saveToken(_token!, _user!);
      notifyListeners();
      return {'success': true, 'user': _user, 'token': _token};
    } else {
      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login failed',
        'errors': responseData['errors'] // If backend provides specific errors
      };
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: <String, String>{
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        // Log the error or handle it as needed, but proceed with local logout
        print("Error calling backend logout: $e");
      }
    }
    _token = null;
    _user = null;
    await _clearToken();
    notifyListeners();
  }

  // Method to delete a food item (Admin only)
  Future<Map<String, dynamic>> deleteFoodItem(String foodId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/foods/$foodId'), // Correct endpoint
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 204) { // 204 No Content for successful deletion
      return {'success': true, 'message': 'Food item deleted successfully.'};
    } else if (response.statusCode == 403) {
       final responseData = jsonDecode(response.body);
      return {'success': false, 'message': responseData['message'] ?? 'Forbidden: You may not have admin rights.'};
    } else if (response.statusCode == 404) {
      return {'success': false, 'message': 'Food item not found.'};
    } else {
      try {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['message'] ?? 'Failed to delete food item.', 'errors': responseData['errors']};
      } catch (_) {
        return {'success': false, 'message': 'Failed to delete food item. Status: ${response.statusCode}'};
      }
    }
  }

  // Method to create a new food item (Admin only)
  Future<Map<String, dynamic>> createFoodItem(Map<String, dynamic> foodData, String token, {File? imageFile}) async {
    var uri = Uri.parse('$_baseUrl/foods');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add text fields
    foodData.forEach((key, value) {
      if (value != null) {
        if (key == 'available_addons' && value is List) {
          for (int i = 0; i < value.length; i++) {
            if (value[i] is Map) {
              Map<String, dynamic> addon = value[i];
              addon.forEach((addonKey, addonValue) {
                if (addonValue != null) {
                  request.fields['available_addons[$i][$addonKey]'] = addonValue.toString();
                }
              });
            }
          }
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    // Add image file if provided
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // This 'image' field name must match what your Laravel backend expects
          imageFile.path,
          contentType: MediaType('image', imageFile.path.split('.').last), // e.g., 'image/jpeg' or 'image/png'
        ),
      );
    } else {
      // If image is mandatory for creation, this should ideally be validated on the client-side first
      // However, as a fallback, the backend will likely reject it.
      // For now, AdminFoodFormPage handles this client-side check.
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) { // 201 Created for successful creation
        return {'success': true, 'message': responseData['message'] ?? 'Food item created successfully.', 'food': responseData['food']};
      } else if (response.statusCode == 422) { // Validation errors
        return {'success': false, 'message': responseData['message'] ?? 'Validation failed.', 'errors': responseData['errors']};
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': responseData['message'] ?? 'Forbidden: You may not have admin rights.'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Failed to create food item.', 'errors': responseData['errors']};
      }
    } catch (e) {
      print('Error creating food item: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Method to update an existing food item (Admin only)
  Future<Map<String, dynamic>> updateFoodItem(String foodId, Map<String, dynamic> foodData, String token, {File? imageFile}) async {
    var uri = Uri.parse('$_baseUrl/foods/$foodId');
    // Laravel expects PUT requests for updates to be sent as POST with a _method field for multipart/form-data
    // or use a package that supports true PUT with multipart. For simplicity with http package, we use POST with _method.
    var request = http.MultipartRequest('POST', uri); 
    request.fields['_method'] = 'PUT'; // Important for Laravel to treat this as PUT

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add text fields
    foodData.forEach((key, value) {
       if (value != null) {
        if (key == 'available_addons' && value is List) {
          for (int i = 0; i < value.length; i++) {
            if (value[i] is Map) {
              Map<String, dynamic> addon = value[i];
              addon.forEach((addonKey, addonValue) {
                if (addonValue != null) {
                  request.fields['available_addons[$i][$addonKey]'] = addonValue.toString();
                }
              });
            }
          }
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    // Add image file if provided
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // This 'image' field name must match your Laravel backend
          imageFile.path,
          contentType: MediaType('image', imageFile.path.split('.').last),
        ),
      );
    }
    // If imageFile is null, we don't add it. The backend should handle this by not updating the image.

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) { // 200 OK for successful update
        return {'success': true, 'message': responseData['message'] ?? 'Food item updated successfully.', 'food': responseData['food']};
      } else if (response.statusCode == 422) { // Validation errors
        return {'success': false, 'message': responseData['message'] ?? 'Validation failed.', 'errors': responseData['errors']};
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': responseData['message'] ?? 'Forbidden: You may not have admin rights.'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Food item not found.'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Failed to update food item.', 'errors': responseData['errors']};
      }
    } catch (e) {
      print('Error updating food item: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Method to fetch all orders for the current user
  Future<Map<String, dynamic>> fetchUserOrders() async {
    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // The backend returns a list of orders directly.
        // For consistency in our service methods, let's wrap it.
        return {'success': true, 'orders': responseData};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch orders. Status: ${response.statusCode}',
          'errors': responseData['errors']
        };
      }
    } catch (e) {
      print('Error fetching user orders: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Method to fetch details for a single order
  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'order': responseData};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Order not found.'};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch order details. Status: ${response.statusCode}',
          'errors': responseData['errors']
        };
      }
    } catch (e) {
      print('Error fetching order details: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Method for a delivery person to take/accept an order
  Future<Map<String, dynamic>> takeOrder(String orderId) async {
    if (_token == null || !isDeliveryPersonnel) {
      return {'success': false, 'message': 'Not authenticated as delivery personnel.'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/take'),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8', // Though no body is sent, good practice
        },
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'order': responseData, 'message': responseData['message'] ?? 'Order taken successfully.'};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to take order. Status: ${response.statusCode}',
          'errors': responseData['errors']
        };
      }
    } catch (e) {
      print('Error taking order: $e');
      return {'success': false, 'message': 'An error occurred while taking order: $e'};
    }
  }

  // Method for Admin or Delivery Personnel to update order status
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    // The backend will handle role-specific logic for what statuses can be set by whom.
    // No explicit isAdmin or isDeliveryPersonnel check needed here as AuthService is a shared service.
    // The UI calling this should ensure it's providing valid statuses for the user's role.

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'status': status,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'order': responseData, 'message': responseData['message'] ?? 'Order status updated.'};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update order status. Status: ${response.statusCode}',
          'errors': responseData['errors']
        };
      }
    } catch (e) {
      print('Error updating order status: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
} 