import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_app/controllers/parking_controller.dart';
import 'package:my_app/controllers/user_profile_controller.dart' as userProfile;
import 'package:my_app/models/parking_model.dart';
import 'package:my_app/navigation_menu.dart';

class CheckInController extends GetxController {
  var selectedVehicle = Rx<userProfile.Vehicle?>(null);
  var durationController = TextEditingController();
  var cost = 0.0.obs;
  final userProfile.ProfileController profileController = Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
  }

  void fetchVehicles() {
    // Fetch vehicles from ProfileController
    // This will automatically update the UI due to Obx in CheckInScreen
  }

  void calculateCost() {
    int duration = int.parse(durationController.text);
    double ratePerHour = 10.0; // Base rate per hour

    cost.value = duration * ratePerHour;
  }

  void confirmCheckIn() {
    calculateCost();

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Check-In'),
        content: Text('Cost: \$${cost.value.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedVehicle.value != null) {
                ParkingSpot newParking = ParkingSpot(
                  residenceType: 'N/A',
                  parkingType: selectedVehicle.value!.type,
                  brand: selectedVehicle.value!.brand,
                  model: selectedVehicle.value!.model,
                  duration: int.parse(durationController.text),
                  cost: cost.value,
                  parkingSpace: 'A1', // Dummy parking space
                  imagePath: selectedVehicle.value!.imagePath,
                );
                Get.find<ParkingController>().addParkingSpot(newParking);
                Get.back();
                Get.snackbar('Success', 'Check-In Confirmed',
                    snackPosition: SnackPosition.BOTTOM);

                // Added a delay to ensure snackbar displays before navigation
                Future.delayed(const Duration(seconds: 1), () {
                  Get.offAll(() => const NavigationMenu());
                });
              } else {
                Get.snackbar('Error', 'No vehicle selected',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
