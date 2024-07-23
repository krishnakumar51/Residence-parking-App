import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/controllers/parking_controller.dart';

class ParkingInfoScreen extends StatelessWidget {
  final ParkingController parkingController = Get.put(ParkingController());

  ParkingInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parking Info')),
      body: Obx(() {
        return ListView.builder(
          itemCount: parkingController.parkings.length,
          itemBuilder: (context, index) {
            final parking = parkingController.parkings[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: parking.imagePath.isEmpty
                    ? AssetImage(parking.parkingType == 'Car'
                        ? 'assets/images/car.jpeg'
                        : 'assets/images/car.jpeg')
                    : FileImage(File(parking.imagePath)),
              ),
              title: Text(
                '${parking.brand} ${parking.model}',
              ),
              subtitle: Text(
                'Parking Space: ${parking.parkingSpace}',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Confirm Check-Out'),
                      content:
                          Text('Cost: \$${parking.cost.toStringAsFixed(2)}'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            parkingController.checkOut(index);
                            Get.back(); // Close the dialog
                            Get.snackbar('Success', 'Checked out successfully',
                                snackPosition: SnackPosition.BOTTOM);
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Check-Out'),
              ),
            );
          },
        );
      }),
    );
  }
}
