import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Vehicle {
  final String brand;
  final String model;
  final String type;
  final String imagePath;

  Vehicle({
    required this.brand,
    required this.model,
    required this.type,
    required this.imagePath,
  });
}

class ProfileController extends GetxController {
  var vehicles = <Vehicle>[].obs;
  var brandController = TextEditingController();
  var modelController = TextEditingController();
  var vehicleImage = ''.obs;
  var selectedVehicleType = 'Car'.obs;

  void setVehicleImage(String path) {
    vehicleImage.value = path;
  }

  void setSelectedVehicleType(String type) {
    selectedVehicleType.value = type;
  }

  void addVehicle() {
    if (brandController.text.isNotEmpty && modelController.text.isNotEmpty) {
      vehicles.add(Vehicle(
        brand: brandController.text,
        model: modelController.text,
        type: selectedVehicleType.value,
        imagePath: vehicleImage.value,
      ));
      brandController.clear();
      modelController.clear();
      vehicleImage.value = '';
    }
  }
}
