import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/controllers/auth_controller.dart';
import 'package:my_app/views/home_screen.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/widgets/custom_textscreen.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: usernameController,
              hintText: 'Username',
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: passwordController,
              hintText: 'Password',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Login',
              onPressed: () {
                authController.login(
                  usernameController.text,
                  passwordController.text,
                );
                if (authController.isAuthenticated.value) {
                  Get.off(HomeScreen());
                } else {
                  Get.snackbar('Error', 'Login failed');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
