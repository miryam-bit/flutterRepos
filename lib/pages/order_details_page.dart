import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isLoading = true;
  Order? _order;
  String? _error;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _markers.clear(); // Clear previous markers
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.fetchOrderDetails(widget.orderId);

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _order = Order.fromJson(result['order'] as Map<String, dynamic>);
            _isLoading = false;
            _updateMarkers(); // Update markers when order is loaded
          });
        } else {
          setState(() {
            _error = result['message'] as String? ?? 'Failed to load order details.';
            _isLoading = false;
          });
        }
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

  void _updateMarkers() {
    if (_order != null && _order!.deliveryLatitude != null && _order!.deliveryLongitude != null) {
      final orderLocation = LatLng(_order!.deliveryLatitude!, _order!.deliveryLongitude!);
      setState(() {
        _markers = {
          Marker(
            markerId: MarkerId('orderLocation_${_order!.id}'),
            position: orderLocation,
            infoWindow: InfoWindow(
              title: 'Delivery Location',
              snippet: _order!.deliveryAddress,
            ),
          ),
        };
        // Optionally move camera to the marker
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(orderLocation, 15));
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers(); // Update markers when map is ready
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_order != null ? 'Order #${_order!.id}' : 'Order Details'),
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
                onPressed: _fetchOrderDetails,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }
    if (_order == null) {
      return const Center(child: Text('Order details not found.'));
    }

    final order = _order!;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Order Summary'),
          _buildDetailRow('Order ID:', order.id.toString()),
          _buildDetailRow('Status:', order.status),
          _buildDetailRow('Date Placed:', DateFormat.yMMMd().add_jm().format(order.createdAt.toLocal())),
          _buildDetailRow('Delivery Address:', order.deliveryAddress),
          if (order.notes != null && order.notes!.isNotEmpty)
            _buildDetailRow('Notes:', order.notes!),
          
          // Add Map Section here
          if (order.deliveryLatitude != null && order.deliveryLongitude != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Delivery Location Map'),
                  SizedBox(
                    height: 250, // Adjust height as needed
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(order.deliveryLatitude!, order.deliveryLongitude!),
                        zoom: 15, // Adjust zoom level as needed
                      ),
                      markers: _markers,
                      myLocationEnabled: false, // Set to true if you want to show user's location
                      myLocationButtonEnabled: false, // Corresponding button for user's location
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _buildDetailRow('Map:', 'Location data not available for this order.'),
            ),

          const SizedBox(height: 16),
          _buildSectionTitle('Items Ordered (${order.items.length})'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.food.name} (x${item.quantity})', style: Theme.of(context).textTheme.titleMedium),
                      Text('Price per item: ${currencyFormat.format(item.priceAtTimeOfOrder)}'),
                      if (item.addonsDetails.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Addons:', style: Theme.of(context).textTheme.labelMedium),
                              ...item.addonsDetails.map((addon) => 
                                Text('- ${addon.name}: ${currencyFormat.format(addon.price)} (x${item.quantity})')
                              ).toList(),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Item Total: ${currencyFormat.format(item.priceAtTimeOfOrder * item.quantity + item.addonsDetails.fold(0.0, (sum, addon) => sum + addon.price * item.quantity))}')
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Payment Details'),
          _buildDetailRow('Subtotal (Items):', currencyFormat.format(order.totalAmount - (order.deliveryFee ?? 0.0))),
          _buildDetailRow('Delivery Fee:', currencyFormat.format(order.deliveryFee ?? 0.0)),
          const Divider(),
          _buildDetailRow('Grand Total:', currencyFormat.format(order.totalAmount), isBold: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
} 