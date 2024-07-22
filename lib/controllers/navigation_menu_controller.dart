// lib/controllers/navigation_menu_controller.dart

import 'package:get/get.dart';
import 'package:my_app/views/check_in_screen.dart';
import 'package:my_app/views/general_queries.dart';
import 'package:my_app/views/parking_info_screen.dart';
import 'package:my_app/views/settings_screen.dart';

class NavigationMenuController extends GetxController {
  var selectedIndex = 0.obs;

  final screens = [
    CheckInScreen(),
    ParkingInfoScreen(),
    const GeneralInquiriesScreen(),
    const SettingsScreen(),
  ];
}
