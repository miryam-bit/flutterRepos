import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'order_details_page.dart'; // This page still needs to be created or confirmed

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;
  List<Order> _orders = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    // Ensure the widget is still mounted before calling setState
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // Ensure token is available before making the call
      if (authService.token == null) {
        if (mounted) {
          setState(() {
            _error = 'Authentication token not found. Please log in again.';
            _isLoading = false;
          });
        }
        return;
      }
      final result = await authService.fetchUserOrders();
      
      if (!mounted) return; // Check again after the await

      if (result['success'] == true) {
        setState(() {
          _orders = (result['orders'] as List)
              .map((orderJson) => Order.fromJson(orderJson as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] as String? ?? 'Failed to load orders.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'), // Changed title to 'My Orders' for clarity
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchOrders,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }
    if (_orders.isEmpty) {
      return const Center(child: Text('You have no orders yet.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Order ID: ${order.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${order.status}'),
                  Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                  Text('Date: ${DateFormat.yMMMd().add_jm().format(order.createdAt.toLocal())}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Ensure OrderDetailsPage exists and is imported
                    builder: (context) => OrderDetailsPage(orderId: order.id.toString()),
                  ),
                ).then((_) {
                  // Optional: Refresh list if user comes back, in case status changed by another process
                  // For a user-only view, this might not be strictly necessary unless status can change server-side rapidly
                  // without user action on this screen. But good for consistency if other parts of app can alter orders.
                  if (mounted) { _fetchOrders(); }
                });
              },
            ),
          );
        },
      ),
    );
  }
} 