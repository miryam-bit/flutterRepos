class Food {
  final String name;
  final String description;
  final String ImgaePath;
  final double price;
  final FoodCategory category;
  List<Addon> avaliableAddons;

  Food({
    required this.name,
    required this.description,
    required this.ImgaePath,
    required this.price,
    required this.category,
    required this.avaliableAddons,
  });
}

enum FoodCategory {
  Burgers,
  Salads,
  Sides,
  Desserts,
  Drinks,
}

class Addon {
  String name;
  double price;

  Addon({required this.name, required this.price});
}
