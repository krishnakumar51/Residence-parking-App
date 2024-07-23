import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/models/parking_model.dart';
import 'package:my_app/controllers/parking_controller.dart';

class CheckoutScreen extends StatelessWidget {
  final int index;
  final ParkingSpot spot;

  const CheckoutScreen({super.key, required this.index, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Brand: ${spot.brand}'),
            Text('Model: ${spot.model}'),
            Text('Cost: \$${spot.cost.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Confirm Check-Out'),
                    content: Text('Cost: \$${spot.cost.toStringAsFixed(2)}'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.find<ParkingController>().checkOut(index);
                          Get.back();
                          Get.back(); // Close the CheckoutScreen
                          Get.snackbar('Success', 'Checked out successfully',
                              snackPosition: SnackPosition.BOTTOM);
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Pay & Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
