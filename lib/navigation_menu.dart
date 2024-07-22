import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_app/views/general_queries.dart';
import 'package:my_app/views/home_screen.dart';
import 'package:my_app/views/parking_info_screen.dart';
import 'package:my_app/views/settings_screen.dart';
import 'package:my_app/views/user_profile_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Assistance App'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.user),
            onPressed: () {
              Get.to(ProfileScreen());
            },
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home1),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Iconsax.car1),
              label: "Parking",
            ),
            NavigationDestination(
              icon: Icon(Iconsax.command_square),
              label: "Queries",
            ),
            NavigationDestination(
              icon: Icon(Iconsax.setting),
              label: "Settings",
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    HomeScreen(),
    ParkingInfoScreen(),
    const GeneralInquiriesScreen(),
    const SettingsScreen()
  ];
}
