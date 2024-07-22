import 'package:get/get.dart';
import 'package:my_app/controllers/check_in_controller.dart';
import 'package:my_app/controllers/user_profile_controller.dart' as userProfile;
import 'package:my_app/views/check_in_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class VoiceAssistantController extends GetxController {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  var isListening = false.obs;
  var command = "".obs;
  var messages = [].obs;
  final textController = TextEditingController();

  void listen() async {
    if (!isListening.value) {
      bool available = await _speechToText.initialize();
      if (available) {
        isListening.value = true;
        _speechToText.listen(
          onResult: (val) {
            command.value = val.recognizedWords;
            if (!val.hasConfidenceRating || val.confidence > 0) {
              if (!isListening.value) {
                _speechToText.stop();
                addMessage("You: ${command.value}");
                _processCommand(command.value);
              }
            }
          },
        );
      }
    } else {
      stopListening();
    }
  }

  void stopListening() {
    if (isListening.value) {
      isListening.value = false;
      _speechToText.stop();
    }
  }

  void _processCommand(String command) {
    addMessage("Assistant: Processing command...");

    if (command.contains("check my car in for")) {
      String hours = command.split("check my car in for ")[1].split(" ")[0];
      Get.to(() => CheckInScreen());

      Future.delayed(const Duration(seconds: 1), () {
        userProfile.ProfileController profileController = Get.find();
        if (profileController.vehicles.isNotEmpty) {
          CheckInController checkInController = Get.find();
          checkInController.selectedVehicle.value =
              profileController.vehicles.first;
          checkInController.durationController.text = hours;
          checkInController.confirmCheckIn();
        }
      });

      addMessage("Assistant: Checked in car for $hours hours.");
    } else {
      addMessage(
          "Assistant: I'm sorry, I didn't understand that command. Can you please try again?");
    }
  }

  void sendMessage() {
    if (textController.text.isNotEmpty) {
      addMessage("You: ${textController.text}");
      _processCommand(textController.text);
      textController.clear();
    }
  }

  void addMessage(String message) {
    messages.add(message);
  }
}
