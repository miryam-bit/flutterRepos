import 'package:delivery_app/pages/login_page.dart';
import 'package:delivery_app/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void toggleLoginPage() {
    print("toggleLoginPage called! Current showLoginPage: $showLoginPage");
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: toggleLoginPage,
      );
    } else {
      return RegisterPage(
        onTap: toggleLoginPage,
      );
    }
  }
}
