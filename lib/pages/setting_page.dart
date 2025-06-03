import 'package:delivery_app/auth/login_or_register.dart';
import 'package:delivery_app/models/models.dart'; // Import models for Restaurant
import 'package:delivery_app/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  // Method to show edit address dialog
  void _showEditAddressDialog(BuildContext context) {
    final restaurant = context.read<Restaurant>();
    TextEditingController addressController =
        TextEditingController(text: restaurant.deliveryAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Delivery Address"),
        content: TextField(
          controller: addressController,
          autofocus: true,
          decoration: InputDecoration(hintText: "Enter new address"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              restaurant.updateDeliveryAddress(addressController.text);
              Navigator.pop(context); // Close dialog
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting Page"),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // dark Mode
                Text(
                  "Dark Mode",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                //switch
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context, listen: false)
                      .isDarkMode,
                  onChanged: (value) =>
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme(),
                )
              ],
            ),
          ),

          // Edit Delivery Address Option
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: ListTile(
              leading: Icon(Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.inversePrimary),
              title: Text(
                "Edit Delivery Address",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              subtitle: Consumer<Restaurant>(
                builder: (context, restaurant, child) => Text(
                  restaurant.deliveryAddress,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
              onTap: () => _showEditAddressDialog(context),
            ),
          ),

          // Logout Button
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.inversePrimary),
              title: Text(
                "Logout",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              onTap: () {
                // Navigate to LoginOrRegister and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginOrRegister()),
                  (Route<dynamic> route) => false, // This predicate removes all routes
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
