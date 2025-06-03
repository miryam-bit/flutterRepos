import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'order_details_page.dart';

class DeliveryDashboardPage extends StatefulWidget {
  const DeliveryDashboardPage({super.key});

  @override
  State<DeliveryDashboardPage> createState() => _DeliveryDashboardPageState();
}

class _DeliveryDashboardPageState extends State<DeliveryDashboardPage> {
  bool _isLoading = true;
  List<Order> _orders = [];
  String? _error;

  final List<String> _deliveryUpdateStatuses = [
    'delivered', 'failed'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDeliveryOrders();
  }

  Future<void> _fetchDeliveryOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.token == null || !authService.isDeliveryPersonnel) {
        if (mounted) {
          setState(() {
            _error = 'Authentication error or not authorized for delivery.';
            _isLoading = false;
          });
        }
        return;
      }
      final result = await authService.fetchUserOrders();
      
      if (!mounted) return;
      if (result['success'] == true) {
        final ordersData = result['orders']; // Can be List<dynamic> or null
        if (ordersData != null && ordersData is List) {
          _orders = ordersData
              .where((item) => item is Map<String, dynamic>) // Filter out nulls or non-Map items
              .map((item) => Order.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _orders = []; // Default to empty list if ordersData is null or not a list
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] as String? ?? 'Failed to load delivery orders.';
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

  Future<void> _handleTakeOrder(Order order) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attempting to take order #${order.id}...'))
    );
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.takeOrder(order.id.toString());

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Order taken successfully!'), backgroundColor: Colors.green)
        );
        _fetchDeliveryOrders(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Failed to take order.'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking order: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating status for order #${order.id} to $newStatus...'))
    );
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.updateOrderStatus(order.id.toString(), newStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Order status updated!'), backgroundColor: Colors.green)
        );
        _fetchDeliveryOrders(); // Refresh list
      } else {
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
    final authService = Provider.of<AuthService>(context, listen: false); // For checking current user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDeliveryOrders,
            tooltip: 'Refresh Orders',
          )
        ],
      ),
      body: _buildBody(authService),
    );
  }

  Widget _buildBody(AuthService authService) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchDeliveryOrders, child: const Text('Retry'))
          ]),
        ),
      );
    }
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders available or assigned to you at the moment.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchDeliveryOrders,
      child: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final customerName = order.user?.name ?? 'N/A'; // Access customer name via order.user.name
          final address = order.deliveryAddress;
          final currentUserId = authService.user?['id'];

          // Show "Take Order" button if the order is unassigned
          bool canTakeOrder = order.driver == null;
          
          bool isAssignedToCurrentUser = order.driver?.id == currentUserId;
          bool canUpdateStatusByDriver = isAssignedToCurrentUser && order.status == 'out_for_delivery';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order.id}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Customer: $customerName'),
                  const SizedBox(height: 4),
                  Text('Address: $address'),
                  const SizedBox(height: 4),
                  Text('Status: ${order.status}', style: TextStyle(color: _getStatusColor(order.status))),
                  const SizedBox(height: 4),
                  if (order.driver != null)
                    Text('Assigned Driver: ${order.driver!.name}', style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  Text('Order Date: ${DateFormat.yMMMd().add_jm().format(order.createdAt.toLocal())}'),
                  if (order.assignedAt != null)
                    Text('Assigned At: ${DateFormat.yMMMd().add_jm().format(order.assignedAt!.toLocal())}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (canTakeOrder)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delivery_dining_outlined),
                          label: const Text('Take Order'),
                          onPressed: () => _handleTakeOrder(order),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white),
                        ),
                      if (canUpdateStatusByDriver)
                        DropdownButton<String>(
                          hint: const Text("Update Status"),
                          items: _deliveryUpdateStatuses.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (String? newStatus) {
                            if (newStatus != null) {
                              _updateOrderStatus(order, newStatus);
                            }
                          },
                        ),
                      TextButton(
                        child: const Text('View Items'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(orderId: order.id.toString()),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'preparing':
        return Colors.blue;
      case 'out_for_delivery':
        return Colors.teal; // Changed for better distinction
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}