import 'package:delivery_app/components/my_button.dart';
// Corrected import: Use the barrel file for all models
import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  final Food food;
  final Map<Addon, bool> selectedAddons = {};

  FoodPage({super.key, required this.food}) {
    for (Addon addon in food.avaliableAddons) {
      selectedAddons[addon] = false;
    }
  }

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  //method to add to cart
  void addToCart(Food food) {
    //close the current page
    Navigator.pop(context);

    // format the selected addons
    List<Addon> currentSelectedAddons = [];
    for (Addon addon in widget.food.avaliableAddons) {
      if (widget.selectedAddons[addon] == true) {
        currentSelectedAddons.add(addon);
      }
    }

    //add to cart
    context.read<Restaurant>().addToCart(food, currentSelectedAddons);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //Scaffold Ui
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    String imageUrl = '';
                    if (widget.food.imagePath.isNotEmpty) {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      if (Uri.tryParse(widget.food.imagePath)?.isAbsolute ?? false) {
                        imageUrl = widget.food.imagePath;
                      } else {
                        imageUrl = "${authService.baseUrl.replaceAll("/api", "")}/storage/${widget.food.imagePath}";
                      }
                      return Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading network image for food page: $imageUrl, Error: $error");
                          return Image.asset(
                            widget.food.imagePath,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print("Error loading asset image for food page: ${widget.food.imagePath}, Error: $error");
                              return Container(
                                height: 250,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image, size: 100, color: Theme.of(context).colorScheme.error),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(Icons.fastfood, size: 100, color: Theme.of(context).colorScheme.primary),
                      );
                    }
                  }
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //food name
                      Text(
                        widget.food.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      //food price
                      Text(
                        '\$${widget.food.price}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      SizedBox(height: 10),

                      //food description
                      Text(widget.food.description),

                      SizedBox(height: 10),

                      Divider(color: Theme.of(context).colorScheme.secondary),

                      SizedBox(height: 10),

                      Text(
                        'Add-ons',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 10),

                      //addons
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: widget.food.avaliableAddons.length,
                          itemBuilder: (context, index) {
                            // addon ka hal hal ula soo bax
                            Addon addon = widget.food.avaliableAddons[index];
                            return CheckboxListTile(
                              title: Text(addon.name),
                              subtitle: Text(
                                '\$${addon.price}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              value: widget.selectedAddons[addon],
                              onChanged: (bool? value) {
                                setState(() {
                                  widget.selectedAddons[addon] = value!;
                                });
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                //button => add to the cart
                MyButton(
                  onTap: () => addToCart(widget.food),
                  text: "Add to Cart",
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
        //Back button deb ulaawasho
        SafeArea(
          child: Opacity(
            opacity: 0.7,
            child: Container(
              margin: EdgeInsets.only(left: 15, top: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
