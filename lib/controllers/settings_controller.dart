import 'package:get/get.dart';

class SettingsController extends GetxController {
  var notificationsEnabled = true.obs;

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
  }
}
