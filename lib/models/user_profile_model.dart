// lib/models/user_profile.dart

import 'package:my_app/controllers/user_profile_controller.dart';

class UserProfile {
  String name;
  List<Vehicle> vehicles;

  UserProfile({required this.name, required this.vehicles});
}
