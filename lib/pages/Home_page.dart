import 'package:delivery_app/components/my_drawer.dart';
import 'package:delivery_app/components/my_food_tail.dart';
import 'package:delivery_app/components/my_sliver_app_bar.dart';
import 'package:delivery_app/components/my_tab_bar.dart';
import 'package:delivery_app/models/models.dart';
import 'package:delivery_app/pages/food_page.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);
    
    // Fetch menu after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final restaurant = Provider.of<Restaurant>(context, listen: false);
      // Only fetch menu if authenticated, otherwise AuthService should handle navigation
      if (authService.isAuthenticated) {
        restaurant.fetchMenu(authService.token);
      } else {
        // This case should ideally be handled by a higher-level auth state listener
        // that navigates to login if not authenticated.
        // For now, if HomePage is reached without auth, we can show an error or do nothing.
        print("HomePage: User not authenticated, menu not fetched.");
        // Optionally, set an error state in Restaurant provider
        // restaurant.setError("Not authenticated. Please login.");
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  List<Widget> getFoodInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);

      return ListView.builder(
          itemCount: categoryMenu.length,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final food = categoryMenu[index];

            return MyFoodTail(
              food: food,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodPage(food: food),
                ),
              ),
            );
          });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) {
        return Scaffold(
          drawer: MyDrawer(),
          body: Column(
            children: [
              // Show a loading indicator while the menu is being fetched
              if (restaurant.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (restaurant.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${restaurant.error}\nPlease try again later or re-login.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                    ),
                  ),
                )
              else if (restaurant.menu.isEmpty)
                const Center(child: Text("No menu items available. Try refreshing."))
              else
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      MySliverAppBar(
                        title: MyTabBar(tabController: _tabController),
                        child: SizedBox.shrink(),
                      )
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: getFoodInThisCategory(restaurant.menu),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
