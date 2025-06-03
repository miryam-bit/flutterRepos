import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_app/models/models.dart'; // Assuming models.dart exports Restaurant
import 'package:delivery_app/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final restaurant = context.watch<Restaurant>(); // To get delivery address

    // Use user data from AuthService if available, otherwise use placeholders
    final String userName = authService.user?['name'] ?? "Test User";
    final String userEmail = authService.user?['email'] ?? "test@example.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Profile Picture (Placeholder)
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // User Name
          Card(
            color: Theme.of(context).colorScheme.secondary,
            child: ListTile(
              leading: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
              title: Text(
                userName,
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Name", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          const SizedBox(height: 10),

          // User Email
          Card(
            color: Theme.of(context).colorScheme.secondary,
            child: ListTile(
              leading: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
              title: Text(
                userEmail,
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              ),
              subtitle: Text("Email", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          const SizedBox(height: 10),

          // Delivery Address (from Restaurant provider)
          Card(
            color: Theme.of(context).colorScheme.secondary,
            child: ListTile(
              leading: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.primary),
              title: Text(
                restaurant.deliveryAddress,
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              ),
              subtitle: Text("Current Delivery Address", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              // Optionally, add a trailing icon to navigate to edit address (already in settings)
              // trailing: IconButton(
              //   icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
              //   onPressed: () {
              //     // Logic to edit address - or just inform user to use settings page
              //   },
              // ),
            ),
          ),
          const SizedBox(height: 20),

          // Maybe a logout button here too, or other profile actions
          // For now, keeping it simple. Logout is in settings.
        ],
      ),
    );
  }
} 