import 'package:delivery_app/components/my_receipt.dart';
import 'package:flutter/material.dart';
// Potentially needs import 'package:delivery_app/models/models.dart'; if MyReceipt needs it directly
// or if this page were to use Restaurant provider directly.
// For now, assuming MyReceipt handles its own model imports if necessary.

class DeliveryProgressPage extends StatelessWidget {
  final String receiptDetails;
  const DeliveryProgressPage({super.key, required this.receiptDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Progress'), // Updated title
      ),
      body: Column(
        children: [MyReceipt(receiptContent: receiptDetails)],
      ),
    );
  }
} 