import 'package:get/get.dart';
import 'package:my_app/models/parking_model.dart';

class ParkingController extends GetxController {
  var parkings = <ParkingSpot>[].obs;

  void addParkingSpot(ParkingSpot parkingSpot) {
    parkings.add(parkingSpot);
  }

  void removeParkingSpot(ParkingSpot parkingSpot) {
    parkings.remove(parkingSpot);
  }

  void checkOut(int index) {
    parkings.removeAt(index);
  }

  int getAvailableSpaces(String type) {
    int totalSpaces = 10;
    int occupiedSpaces = parkings.where((p) => p.parkingType == type).length;
    return totalSpaces - occupiedSpaces;
  }
}
