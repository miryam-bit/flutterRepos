import 'package:delivery_app/components/my_drawer_tail.dart';
import 'package:delivery_app/pages/login_page.dart';
import 'package:delivery_app/pages/setting_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Spacer(),
          MyDrawerTail(
              text: 'Log Out',
              icon: Icons.logout,
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ))
                  }),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}
