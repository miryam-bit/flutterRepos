import 'package:collection/collection.dart';
import 'package:delivery_app/models/cart_item.dart';
import 'package:delivery_app/models/food.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Restaurant extends ChangeNotifier {
  final List<Food> _menu = [
    //Burger
    Food(
        name: "Chees Burger",
        description:
            "Waa Burger Saaid Umacaan Waxoo Ka Kowan Yahay Bardho iyo Burger iyo Chees Badan",
        ImgaePath: "lib/images/burgers/burger-1.png",
        price: 1.99,
        category: FoodCategory.Burgers,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Beef Burger",
        description:
            "Waa Heleb Burger Saaid Umacaan Waxoo Ka Kowan Yahay Bardho iyo Burger iyo Heleb ",
        ImgaePath: "lib/images/burgers/burger-2.webp",
        price: 2.99,
        category: FoodCategory.Burgers,
        avaliableAddons: [
          Addon(name: "Baedho Busbas Dheraad", price: 0.99),
          Addon(name: "Ukun Dheraad", price: 0.99),
        ]),
    Food(
        name: "Chiaken Burger",
        description:
            "Waa Burger Saaid Umacaan Waxoo Ka Kowan Yahay Bardho iyo Dooro iyo Chees Badan",
        ImgaePath: "lib/images/burgers/burger-4.png",
        price: 1.99,
        category: FoodCategory.Burgers,
        avaliableAddons: [
          Addon(name: "Ukun Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Spical Burger",
        description:
            "Waa Burger Saaid Umacaan Waxoo Ka Kowan Yahay Bardho iyo Burger iyo Chees Badan",
        ImgaePath: "lib/images/burgers/burger-5.png",
        price: 3.99,
        category: FoodCategory.Burgers,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Spical-Addon Dheraad", price: 1.99),
        ]),

    //Salad
    Food(
        name: "Chiken Salad",
        description: "Waa Salad iyo Chiken Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/salads/salad2.png",
        price: 1.99,
        category: FoodCategory.Salads,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Chees Salad",
        description: "Waa Salad iyo Chees Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/salads/salad5.png",
        price: 0.99,
        category: FoodCategory.Salads,
        avaliableAddons: [
          Addon(name: "Baedho Busbas Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Vegetable Salad",
        description: "Waa Salad iyo Qudar Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/salads/salad3.png",
        price: 2.99,
        category: FoodCategory.Salads,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Salad",
        description: "Waa Salad Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/salads/salad4.png",
        price: 1.00,
        category: FoodCategory.Salads,
        avaliableAddons: [
          Addon(name: "Ukun Dheraad", price: 0.99),
          Addon(name: "Spical.Addon Dheraad", price: 1.00),
        ]),

    //Desserts
    Food(
        name: "Ice Cream",
        description: "Waa Ice Cream Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/desserts/Desserts-1.png",
        price: 1.00,
        category: FoodCategory.Desserts,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Cup Cake",
        description: "Waa Ice Cream Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/desserts/Desserts-2.png",
        price: 0.99,
        category: FoodCategory.Desserts,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Chocolate Cake",
        description: "Waa Ice Cream Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/desserts/Desserts-3.png",
        price: 2.59,
        category: FoodCategory.Desserts,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Donats",
        description: "Waa Ice Cream Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/desserts/Desserts-4.png",
        price: 1.50,
        category: FoodCategory.Desserts,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    //Drinks
    Food(
        name: "Coca Cola",
        description: "Waa Cabitan Strowberry Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/drinks/Drink-1.png",
        price: 1.00,
        category: FoodCategory.Drinks,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Ice Coffee",
        description: "Waa Ice Coffee Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/drinks/Drink-4.png",
        price: 1.00,
        category: FoodCategory.Drinks,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Orange Juce ",
        description: "Waa Ice Cream Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/drinks/Drink-3.png",
        price: 1.00,
        category: FoodCategory.Drinks,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Lemon",
        description: "Waa Coca Cola Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/drinks/Drink-2.png",
        price: 1.00,
        category: FoodCategory.Drinks,
        avaliableAddons: [
          Addon(name: "Baedho Dheraad", price: 0.99),
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),

    //sides
    Food(
        name: "Spical-min",
        description: "Waa Bardho saaid Umac Oo Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/sides/Side-1.jpg",
        price: 1.00,
        category: FoodCategory.Sides,
        avaliableAddons: [
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Fries",
        description: "Waa Bardho saaid Umac Oo Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/sides/Side-3.jpg",
        price: 1.00,
        category: FoodCategory.Sides,
        avaliableAddons: [
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Spical-full",
        description: "Waa Ukun saaid Umac Oo Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/sides/Side-4.jpg",
        price: 1.00,
        category: FoodCategory.Sides,
        avaliableAddons: [
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
    Food(
        name: "Ukun",
        description: "Waa Karoto saaid Umac Oo Farsh ah Oo Saaid Umacaan ",
        ImgaePath: "lib/images/sides/Side-5.jpg",
        price: 1.00,
        category: FoodCategory.Sides,
        avaliableAddons: [
          Addon(name: "Chees Dheraad", price: 0.5),
        ]),
  ];

  //Gatter
  List<Food> get menu => _menu;
  List<CartItem> get cart => _cart;

  //shaqada mesha aan ka qabtay sid add cart iyo wixii laxariiro
  final List<CartItem> _cart = [];

  //add to cart
  void addToCart(Food food, List<Addon> selectedAddons) {
    CartItem? cartItem = _cart.firstWhereOrNull((Item) {
      //check if the food items are the same
      bool isSameFood = Item.food == food;

      //check if the addons are the same
      bool isSameAddons =
          ListEquality().equals(Item.selectedAddons, selectedAddons);
      return isSameFood && isSameAddons;
    });

    if (cartItem != null) {
      cartItem.quantity++;
    } else {
      _cart.add(
        CartItem(
          food: food,
          selectedAddons: selectedAddons,
        ),
      );
    }
    notifyListeners();
  }

  //remove from cart
  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);

    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
      notifyListeners();
    }
  }

  //get total price of cart
  double getTotalPrice() {
    double total = 0.0;

    for (CartItem cartItem in _cart) {
      double itemTotal = cartItem.food.price;

      for (Addon addon in cartItem.selectedAddons) {
        itemTotal += addon.price;
      }

      total += itemTotal * cartItem.quantity;
    }
    return total;
  }

  //get total number of items in cart
  int getTotalQuantity() {
    int total = 0;

    for (CartItem cartItem in _cart) {
      total += cartItem.quantity;
    }
    return total;
  }

  //clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // generate a receipt
  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln("Here is your receipt.");
    receipt.writeln();

    //format the data to include up to seconds only
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    receipt.writeln(formattedDate);
    receipt.writeln();
    receipt.writeln("--------------------");

    for (final CartItem in _cart) {
      receipt.writeln(
          "${CartItem.quantity} x ${CartItem.food.name} - ${_formatPrice(CartItem.food.price)}");
      if (CartItem.selectedAddons.isNotEmpty) {
        receipt
            .writeln("   Add-ons: ${_formatAddons(CartItem.selectedAddons)}");
      }
      receipt.writeln();
    }

    receipt.writeln("--------------------");
    receipt.writeln();
    receipt.writeln("Total Items: ${getTotalQuantity()}");
    receipt.writeln("Total Price: ${_formatPrice(getTotalPrice())}");

    return receipt.toString();
  }

  //from double value into Money
  String _formatPrice(double price) {
    return "\$${price.toStringAsFixed(2)}";
  }

  //format list of addons into a string summary
  String _formatAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }
}
