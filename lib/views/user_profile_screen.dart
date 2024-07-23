import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/controllers/user_profile_controller.dart' as userProfile;

class ProfileScreen extends StatelessWidget {
  final userProfile.ProfileController profileController = Get.find();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: profileController.brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: profileController.modelController,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            Obx(() => DropdownButton<String>(
                  value: profileController.selectedVehicleType.value,
                  items: ['Car', 'Bike'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    profileController.setSelectedVehicleType(newValue!);
                  },
                )),
            ElevatedButton(
              onPressed: () {
                final newVehicle = userProfile.Vehicle(
                  brand: profileController.brandController.text,
                  model: profileController.modelController.text,
                  type: profileController.selectedVehicleType.value,
                  imagePath: profileController.vehicleImage.value,
                );
                profileController.addVehicle(newVehicle);
                Get.snackbar('Success',
                    '${newVehicle.brand} ${newVehicle.model} successfully added',
                    snackPosition: SnackPosition.BOTTOM);

                // Clear the input fields after adding
                profileController.brandController.clear();
                profileController.modelController.clear();
                profileController.vehicleImage.value = '';
              },
              child: const Text('Add Vehicle'),
            ),
            const SizedBox(height: 20),
            Obx(() => Expanded(
                  child: ListView.builder(
                    itemCount: profileController.vehicles.length,
                    itemBuilder: (context, index) {
                      var vehicle = profileController.vehicles[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: vehicle.imagePath.isEmpty
                                  ? const AssetImage('assets/images/car.jpeg')
                                  : FileImage(File(vehicle.imagePath))
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.brand,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(vehicle.model),
                                Text(vehicle.type),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
