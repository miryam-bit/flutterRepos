import 'package:delivery_app/components/my_button.dart';
import 'package:delivery_app/components/my_testfild.dart';
// Import HomePage if you want to navigate there after registration, or handle differently
// import 'package:delivery_app/pages/Home_page.dart'; 
import 'package:flutter/material.dart';
import 'package:delivery_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void register() async {
    print("Sign Up button (register_page.dart) pressed!");
    final authService = Provider.of<AuthService>(context, listen: false);

    if (passwordController.text == confirmPasswordController.text) {
      try {
        Map<String, dynamic> result = await authService.register(
          nameController.text,
          emailController.text,
          passwordController.text,
          confirmPasswordController.text,
        );

        if (result['success']) {
          // Navigate to home page or login page upon successful registration
          Navigator.pushReplacementNamed(context, '/home'); // Or '/login' to have them log in
        } else {
          // Show error message
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Registration Failed'),
              content: Text(result['message'] ?? 'An unknown error occurred.'),
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
            title: const Text('Registration Error'),
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Mismatch'),
          content: const Text('Passwords do not match.'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.app_registration_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),

              //messeg ,app s logon
              Text(
                'Create a new Account',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              MyTextFild(
                  controller: emailController, hintText: "Email", obscureText: false),

              const SizedBox(height: 15),

              MyTextFild(
                  controller: passwordController, hintText: "Password", obscureText: true),

              const SizedBox(height: 15),

              MyTextFild(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true),

              const SizedBox(height: 10),
              MyTextFild(
                controller: nameController,
                hintText: "Name",
                obscureText: false,
              ),

              //Register Button
              MyButton(onTap: register, text: 'Sign Up'),

              const SizedBox(height: 15),
              //not a member , register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You have Account?',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Login Now',
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
      ),
    );
  }
}
