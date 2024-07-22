class ParkingSpot {
  final String residenceType;
  final String parkingType;
  final String brand;
  final String model;
  final int duration;
  final double cost;
  final String parkingSpace;
  final String imagePath;

  ParkingSpot({
    required this.residenceType,
    required this.parkingType,
    required this.brand,
    required this.model,
    required this.duration,
    required this.cost,
    required this.parkingSpace,
    this.imagePath = '',
  });
}
