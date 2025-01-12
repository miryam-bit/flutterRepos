import 'package:delivery_app/components/my_button.dart';
import 'package:delivery_app/components/my_testfild.dart';
import 'package:flutter/material.dart';

class Register_Page extends StatefulWidget {
  final Function()? onTap;
  const Register_Page({super.key, required this.onTap});

  @override
  State<Register_Page> createState() => _Register_PageState();
}

class _Register_PageState extends State<Register_Page> {
  final TextEditingController controller = TextEditingController();

  final TextEditingController password = TextEditingController();

  final TextEditingController confirmPassword = TextEditingController();

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
                controller: controller, hintText: "Email", obscureText: false),

            const SizedBox(height: 15),

            MyTextFild(
                controller: password, hintText: "Password", obscureText: true),

            const SizedBox(height: 15),

            MyTextFild(
                controller: confirmPassword,
                hintText: "Confirm Password",
                obscureText: true),

            //Register Button
            MyButton(onTap: () {}, text: 'Sign Up'),

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
    );
  }
}
