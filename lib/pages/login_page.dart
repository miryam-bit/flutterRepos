import 'package:delivery_app/components/my_button.dart';
import 'package:delivery_app/components/my_testfild.dart';
import 'package:delivery_app/pages/Home_page.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController password = TextEditingController();

  void login() async {
    print("Login button (login_page.dart) pressed!");
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      Map<String, dynamic> result = await authService.login(
        controller.text,
        password.text,
      );

      if (result['success']) {
        // Navigate to home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: Text(result['message'] ?? 'Invalid credentials or an error occurred.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.delivery_dining_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),

            //messeg ,app s logon
            Text(
              'Food Delivery App',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            MyTextFild(
                controller: controller, hintText: "Email", obscureText: false),

            const SizedBox(height: 15),

            MyTextFild(
                controller: password, hintText: "Password", obscureText: true),

            //sign in Button
            MyButton(onTap: () => login(), text: 'Sign in'),

            const SizedBox(height: 15),
            //not a member , register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member?',
                  style: TextStyle(fontSize: 12.0),
                ),
                SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    'Register now',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
