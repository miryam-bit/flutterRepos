import 'package:delivery_app/components/my_drawer_tail.dart';
import 'package:delivery_app/pages/login_page.dart';
import 'package:delivery_app/pages/setting_page.dart';
import 'package:delivery_app/pages/order_history_page.dart';
import 'package:delivery_app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:delivery_app/pages/admin_food_manage_page.dart';
import 'package:delivery_app/pages/admin_order_management_page.dart';
import 'package:delivery_app/pages/delivery_dashboard_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Icon(
              Icons.delivery_dining_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          MyDrawerTail(
              text: 'Home',
              icon: Icons.home,
              onTap: () => Navigator.pop(context)),
          MyDrawerTail(
              text: 'Settings',
              icon: Icons.settings,
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ))
                  }),
          MyDrawerTail(
              text: 'My Orders',
              icon: Icons.history,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryPage(),
                    ));
              }),
          MyDrawerTail(
              text: 'Profile',
              icon: Icons.person_outline,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ));
              }),
          if (authService.isAdmin) ...[
            MyDrawerTail(
                text: 'Manage Food Menu',
                icon: Icons.admin_panel_settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminFoodManagePage()));
                }),
            MyDrawerTail(
                text: 'Manage Orders',
                icon: Icons.receipt_long,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrderManagementPage()));
                }),
          ],
          if (authService.isDeliveryPersonnel) ...[
            MyDrawerTail(
                text: 'Delivery Dashboard',
                icon: Icons.delivery_dining_outlined,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryDashboardPage()));
                }),
          ],
          const Spacer(),
          MyDrawerTail(
              text: 'Log Out',
              icon: Icons.logout,
              onTap: () {
                final authService = Provider.of<AuthService>(context, listen: false);
                authService.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login_or_register', (route) => false);
              }),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}
