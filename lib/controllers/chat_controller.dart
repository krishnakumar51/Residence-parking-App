import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:my_app/controllers/check_in_controller.dart';
import 'package:my_app/controllers/user_profile_controller.dart' as userProfile;
import 'package:my_app/views/check_in_screen.dart';

class ChatController extends GetxController {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final RxBool isListening = false.obs;
  final RxBool isKeyboardVisible = false.obs;
  final RxList<String> messages = <String>[].obs;
  final Rx<TextEditingController> textController = TextEditingController().obs;
  final focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(_onFocusChange);
    ever(messages, (_) => _scrollToBottom());
  }

  @override
  void onClose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    textController.value.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onFocusChange() {
    isKeyboardVisible.value = focusNode.hasFocus;
    if (isKeyboardVisible.value) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void toggleListening() async {
    if (!isListening.value) {
      bool available = await _speechToText.initialize();
      if (available) {
        isListening.value = true;
        _speechToText.listen(
          onResult: (val) {
            if (!val.hasConfidenceRating || val.confidence > 0) {
              textController.value.text = val.recognizedWords;
              if (!isListening.value) {
                _speechToText.stop();
                sendMessage();
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

  void sendMessage() {
    if (textController.value.text.isNotEmpty) {
      String userMessage = textController.value.text;
      messages.insert(0, "You: $userMessage");
      textController.value.clear();
      _processCommand(userMessage);
      _scrollToBottom();
    }
  }

  void _processCommand(String command) {
    messages.insert(0, "Assistant: Processing command...");

    if (command.toLowerCase().contains("check my car in for")) {
      String hours =
          command.toLowerCase().split("check my car in for ")[1].split(" ")[0];
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

      messages.insert(0, "Assistant: Checked in car for $hours hours.");
    } else {
      messages.insert(0,
          "Assistant: I'm sorry, I didn't understand that command. Can you please try again?");
    }
  }

  void receiveMessage(String message) {
    messages.insert(0, "Professor: $message");
    _scrollToBottom();
  }
}
