import 'package:delivery_app/auth/login_or_register.dart';
import 'package:delivery_app/models/restaurent.dart';
import 'package:delivery_app/themes/theme_provider.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_app/pages/home_page.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => Restaurant(),
      ),
      ChangeNotifierProvider(
        create: (context) => AuthService(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/login_or_register',
      routes: {
        '/login_or_register': (context) => const LoginOrRegister(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
