import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/controllers/check_in_controller.dart';
import 'package:my_app/controllers/user_profile_controller.dart' as userProfile;

class CheckInScreen extends StatelessWidget {
  final CheckInController checkInController = Get.put(CheckInController());
  final userProfile.ProfileController profileController = Get.find();

  CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => Column(
                  children: [
                    // Existing Vehicles
                    Wrap(
                      spacing: 10,
                      children: profileController.vehicles
                          .map<Widget>((vehicle) => GestureDetector(
                                onTap: () {
                                  checkInController.selectedVehicle.value =
                                      vehicle;
                                },
                                child: Obx(() => Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: checkInController
                                                      .selectedVehicle.value ==
                                                  vehicle
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: vehicle
                                                    .imagePath.isEmpty
                                                ? AssetImage(vehicle.type ==
                                                        'Car'
                                                    ? 'assets/images/car.jpeg'
                                                    : 'assets/images/car.jpeg')
                                                : FileImage(
                                                        File(vehicle.imagePath))
                                                    as ImageProvider,
                                          ),
                                          Text(vehicle.model),
                                        ],
                                      ),
                                    )),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    // Add New Vehicle Button
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: AddVehicleForm(),
                          ),
                        );
                      },
                      child: const Text('Add New Vehicle'),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            // Check-in Duration and Confirmation
            TextField(
              controller: checkInController.durationController,
              decoration: const InputDecoration(labelText: 'Duration (hours)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => checkInController.confirmCheckIn(),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddVehicleForm extends StatelessWidget {
  final userProfile.ProfileController profileController = Get.find();

  AddVehicleForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Brand'),
            controller: profileController.brandController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Model'),
            controller: profileController.modelController,
          ),
          DropdownButton<String>(
            value: profileController.selectedVehicleType.value,
            onChanged: (String? newValue) {
              if (newValue != null) {
                profileController.setSelectedVehicleType(newValue);
              }
            },
            items: <String>['Car', 'Bike', 'Truck']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              profileController.addVehicle();
              Get.back();
            },
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }
}
