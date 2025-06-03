import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/pages/Home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyReceipt extends StatelessWidget {
  final String receiptContent; // Accept receipt content as a string
  const MyReceipt({super.key, required this.receiptContent});

  @override
  Widget build(BuildContext context) {
    // No longer need Consumer<Restaurant> here if receiptContent is passed directly
    final restaurant = context.watch<Restaurant>(); // Still need for clearCart and deliveryAddress (if Go Home uses it)

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Thanks you for your Order!'),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.secondary),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(25),
              // Display the passed receiptContent directly
              child: Text(receiptContent),
            ),
            const SizedBox(height: 25),
            Text('Your Order Is Delivered Now!'),
            TextButton(
              onPressed: () {
                // Navigate to home
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false, // Clears all previous routes
                );
                // It's good practice to clear cart here too, in case the user somehow gets back
                // to this page with a populated cart, though payment page already did it.
                restaurant.clearCart(); 
              },
              child: Text('Go Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
