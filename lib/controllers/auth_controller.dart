import 'package:get/get.dart';

class AuthController extends GetxController {
  var isAuthenticated = false.obs;

  void login(String username, String password) {
    // Add authentication logic here
    isAuthenticated.value = true; // Set to true for demo purposes
  }

  void logout() {
    isAuthenticated.value = false;
  }
}
