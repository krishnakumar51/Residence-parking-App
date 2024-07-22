// lib/models/user_profile.dart
class UserProfile {
  String name;
  List<Vehicle> vehicles;

  UserProfile({required this.name, required this.vehicles});
}

class Vehicle {
  String type; // e.g., Car, Bike
  String brand;
  String model;

  Vehicle({required this.type, required this.brand, required this.model});
}
