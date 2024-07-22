import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/controllers/chat_controller.dart';
import 'package:my_app/controllers/parking_controller.dart';
import 'package:my_app/controllers/user_profile_controller.dart' as userProfile;
import 'package:my_app/controllers/voice_assisstant_controller.dart';
import 'package:my_app/views/check_in_screen.dart';
import 'package:my_app/views/check_out_screen.dart';
import 'package:my_app/views/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  final userProfile.ProfileController profileController = Get.find();
  final ParkingController parkingController = Get.find();
  final VoiceAssistantController voiceAssistantController =
      Get.put(VoiceAssistantController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: profileController.vehicles
                            .map((vehicle) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Handle vehicle tap
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: vehicle
                                                  .imagePath.isEmpty
                                              ? AssetImage(vehicle.type == 'Car'
                                                  ? 'assets/images/car.jpeg'
                                                  : 'assets/images/car.jpeg')
                                              : FileImage(
                                                      File(vehicle.imagePath))
                                                  as ImageProvider,
                                        ),
                                        SizedBox(height: 4),
                                        Text(vehicle.model),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => CheckInScreen());
                    },
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(child: Text('Check-In')),
                    ),
                  ),
                ),
                Obx(() => ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: parkingController.parkings.length,
                      itemBuilder: (context, index) {
                        final spot = parkingController.parkings[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: spot.imagePath.isEmpty
                                  ? AssetImage(spot.parkingType == 'Car'
                                      ? 'assets/images/car.jpeg'
                                      : 'assets/images/car.jpeg')
                                  : FileImage(File(spot.imagePath))
                                      as ImageProvider,
                            ),
                            title: Text('${spot.brand} ${spot.model}'),
                            subtitle:
                                Text('Parking Space: ${spot.parkingSpace}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Get.to(() =>
                                    CheckoutScreen(index: index, spot: spot));
                              },
                              child: const Text('Check-Out'),
                            ),
                          ),
                        );
                      },
                    )),
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSlidingBar(),
              GestureDetector(
                onTap: () => _showChatOverlay(context),
                onLongPressStart: (_) {
                  voiceAssistantController.startListening();
                },
                onLongPressEnd: (_) {
                  voiceAssistantController.stopListening();
                  _showChatOverlay(context);
                },
                child: FloatingActionButton(
                  elevation: 8.0,
                  onPressed: () => _showChatOverlay(context),
                  child: Icon(voiceAssistantController.isListening.value
                      ? Icons.mic
                      : Icons.mic_none),
                ),
              ),
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSlidingBar() {
    return Obx(() => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: voiceAssistantController.isListening.value ? 200 : 0,
          height: 50,
          margin: EdgeInsets.only(right: 10),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              // voiceAssistantController.isListening.value
              //     ? (voiceAssistantController.command.value.isEmpty
              //         ? 'Listening...'
              //         : voiceAssistantController.command.value)
              //     : '',
              "Yes",
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));
  }

  void _showChatOverlay(BuildContext context) {
    Get.dialog(
      Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
            Builder(
              builder: (BuildContext context) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutQuad,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Center(
                    child: FloatingChatOverlay(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.transparent,
    );
  }
}
