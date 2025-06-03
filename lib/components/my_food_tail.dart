import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFoodTail extends StatelessWidget {
  final Food food;
  final void Function()? onTap;

  const MyFoodTail({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                //food details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.name),
                      Text(
                        '\$${food.price}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        food.description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                //food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Builder(
                    builder: (context) {
                      String imageUrl = '';
                      if (food.imagePath.isNotEmpty) {
                        final authService = Provider.of<AuthService>(context, listen: false);
                        if (Uri.tryParse(food.imagePath)?.isAbsolute ?? false) {
                          imageUrl = food.imagePath;
                        } else {
                          imageUrl = "${authService.baseUrl.replaceAll("/api", "")}/storage/${food.imagePath}";
                        }
                        return Image.network(
                          imageUrl,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading network image for food tile: $imageUrl, Error: $error");
                            // Attempt to load as asset as a fallback
                            return Image.asset(
                              food.imagePath, // Original path
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print("Error loading asset image for food tile: ${food.imagePath}, Error: $error");
                                return Container(
                                  height: 120,
                                  width: 120, // Assuming similar width for placeholder
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image, size: 40, color: Theme.of(context).colorScheme.error),
                                );
                              },
                            );
                          },
                        );
                      } else {
                        // Placeholder if imagePath is empty
                        return Container(
                          height: 120,
                          width: 120,
                          color: Colors.grey[300],
                          child: Icon(Icons.fastfood, size: 40, color: Theme.of(context).colorScheme.primary),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.tertiary,
          endIndent: 20,
          indent: 20,
        )
      ],
    );
  }
}
