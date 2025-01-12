import 'package:delivery_app/components/my_receipt.dart';
import 'package:flutter/material.dart';

class DelivaryProgressPage extends StatelessWidget {
  const DelivaryProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivary Progress'),
      ),
      body: Column(
        children: [MyReceipt()],
      ),
    );
  }
}
