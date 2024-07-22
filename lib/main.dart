import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/app.dart';
import 'package:my_app/controllers/chat_controller.dart';
import 'package:my_app/controllers/parking_controller.dart';
import 'package:my_app/controllers/user_profile_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ProfileController());
  Get.put(ParkingController());
  Get.put(ChatController());
  runApp(const MyApp());
}
