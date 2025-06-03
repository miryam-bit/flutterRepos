import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'order_details_page.dart'; // For viewing full details

class AdminOrderManagementPage extends StatefulWidget {
  const AdminOrderManagementPage({super.key});

  @override
  State<AdminOrderManagementPage> createState() => _AdminOrderManagementPageState();
}

class _AdminOrderManagementPageState extends State<AdminOrderManagementPage> {
  bool _isLoading = true;
  List<Order> _orders = [];
  String? _error;

  // Define the possible order statuses for the dropdown
  final List<String> _orderStatuses = [
    'pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled', 'failed'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllOrders();
  }

  Future<void> _fetchAllOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.token == null || !authService.isAdmin) {
        if (mounted) {
          setState(() {
            _error = 'Authentication error or insufficient permissions.';
            _isLoading = false;
          });
        }
        return;
      }
      final result = await authService.fetchUserOrders(); // For admin, this gets all orders
      
      if (!mounted) return;
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

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    if (!mounted) return;
    // Show a loading indicator for the specific order or globally
    // For simplicity, let's just refetch all orders after an update attempt.
    // More sophisticated UI would update the specific item in the list.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating status for order #${order.id} to $newStatus...'))
    );

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.updateOrderStatus(order.id.toString(), newStatus);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Order status updated!'), backgroundColor: Colors.green)
        );
        _fetchAllOrders(); // Refresh the list to show the updated status
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Failed to update status.'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage All Orders'),
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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchAllOrders, child: const Text('Retry'))
          ]),
        ),
      );
    }
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchAllOrders,
      child: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          // The user object might be null if not properly loaded or if there's an issue with the backend response.
          // Safely access user details.
          final userName = order.toJson()['user']?['name'] ?? 'N/A'; // Example of accessing nested user name
          final userEmail = order.toJson()['user']?['email'] ?? 'N/A';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order.id}', style: Theme.of(context).textTheme.titleMedium),
                  Text('User: $userName ($userEmail)'),
                  Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                  Text('Date: ${DateFormat.yMMMd().add_jm().format(order.createdAt.toLocal())}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status: ${order.status}'),
                      DropdownButton<String>(
                        value: order.status,
                        items: _orderStatuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newStatus) {
                          if (newStatus != null && newStatus != order.status) {
                            _updateOrderStatus(order, newStatus);
                          }
                        },
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text('View Details'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsPage(orderId: order.id.toString()),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 