import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_app/pages/admin_food_form_page.dart';

class AdminFoodManagePage extends StatefulWidget {
  const AdminFoodManagePage({super.key});

  @override
  State<AdminFoodManagePage> createState() => _AdminFoodManagePageState();
}

class _AdminFoodManagePageState extends State<AdminFoodManagePage> {
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurant = Provider.of<Restaurant>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      if (restaurant.menu.isEmpty && authService.isAuthenticated && authService.token != null) {
        print("AdminFoodManagePage: Attempting to fetch menu.");
        restaurant.fetchMenu(authService.token!);
      } else {
        print("AdminFoodManagePage: Menu already loaded or conditions not met for fetch.");
      }
    });
  }

  // Method to handle deleting a food item
  Future<void> _deleteFoodItem(BuildContext context, Food food) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${food.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      if (!mounted) return;
      setState(() {
        _isDeleting = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final restaurant = Provider.of<Restaurant>(context, listen: false);

      if (authService.token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Not authenticated. Please log in again.')),
        );
        setState(() {
          _isDeleting = false;
        });
        return;
      }
      
      // Make sure food.id is a String. Your Food model should define id as String.
      // If food.id is int, convert it: food.id.toString()
      final result = await authService.deleteFoodItem(food.id.toString(), authService.token!);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Food item deleted successfully!')),
        );
        // Refresh the menu list
        await restaurant.fetchMenu(authService.token!); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to delete food item.')),
        );
      }
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Menu'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isDeleting) const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0))),
          )
        ],
      ),
      body: Consumer<Restaurant>(
        builder: (context, restaurant, child) {
          if (restaurant.isLoading && restaurant.menu.isEmpty && !_isDeleting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (restaurant.error != null && restaurant.menu.isEmpty) {
            return Center(child: Text("Error loading menu: ${restaurant.error}"));
          }
          if (restaurant.menu.isEmpty) {
            return const Center(child: Text("No food items found."));
          }

          return ListView.builder(
            itemCount: restaurant.menu.length,
            itemBuilder: (context, index) {
              final food = restaurant.menu[index];
              String imageUrl = '';
              if (food.imagePath.isNotEmpty) {
                final authService = Provider.of<AuthService>(context, listen: false);
                // Check if imagePath is already a full URL (e.g., from an old seeder or external source)
                if (Uri.tryParse(food.imagePath)?.isAbsolute ?? false) {
                  imageUrl = food.imagePath;
                } else {
                  // Construct URL for images stored by Laravel in public/storage
                  imageUrl = "${authService.baseUrl.replaceAll("/api", "")}/storage/${food.imagePath}";
                }
              }

              return ListTile(
                leading: food.imagePath.isNotEmpty
                    ? Image.network(
                        imageUrl, 
                        width: 50, 
                        height: 50, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback for failed network image (e.g. if path is still an asset path)
                          // or if network is unavailable
                          print("Error loading network image: $imageUrl, Error: $error");
                          // Attempt to load as asset as a fallback for old data
                          return Image.asset(
                            food.imagePath, // Original path, might be an asset
                            width: 50, 
                            height: 50, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Final fallback if asset also fails
                              print("Error loading asset image: ${food.imagePath}, Error: $error");
                              return Icon(Icons.broken_image, size: 40, color: Theme.of(context).colorScheme.error);
                            },
                          );
                        },
                      )
                    : Icon(Icons.fastfood, size: 40, color: Theme.of(context).colorScheme.primary),
                title: Text(food.name),
                subtitle: Text('${food.category.toString().split('.').last} - \$${food.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                      onPressed: _isDeleting ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminFoodFormPage(food: food)),
                        ).then((value) {
                          if (value == true) {
                            final authService = Provider.of<AuthService>(context, listen: false);
                            if (authService.token != null) {
                              Provider.of<Restaurant>(context, listen: false).fetchMenu(authService.token!);
                            }
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                      onPressed: _isDeleting ? null : () => _deleteFoodItem(context, food),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isDeleting ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminFoodFormPage()),
          ).then((value) {
            if (value == true) {
              final authService = Provider.of<AuthService>(context, listen: false);
              if (authService.token != null) {
                print("AdminFoodManagePage: Refreshing menu after potential add/edit.");
                Provider.of<Restaurant>(context, listen: false).fetchMenu(authService.token!);
              }
            }
          });
        },
        tooltip: 'Add New Food',
        child: const Icon(Icons.add),
      ),
    );
  }
} 