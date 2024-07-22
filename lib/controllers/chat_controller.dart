import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:my_app/controllers/check_in_controller.dart';
import 'package:my_app/controllers/parking_controller.dart';
import 'package:my_app/views/check_in_screen.dart';
import 'package:my_app/views/check_out_screen.dart';

class ChatController extends GetxController {
  final RxList<String> messages = <String>[].obs;
  final Rx<TextEditingController> textController = TextEditingController().obs;
  final focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  var isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(_onFocusChange);
    ever(messages, (_) => _scrollToBottom());
    _initSpeechRecognizer();
  }

  @override
  void onClose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    textController.value.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initSpeechRecognizer() async {
    await _speechToText.initialize();
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> toggleListening() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      // This will prompt the permission dialog
      await Permission.microphone.request();
    }

    if (await Permission.microphone.isGranted) {
      if (isListening.value) {
        stopListening();
      } else {
        startListening();
      }
    } else {
      Get.snackbar(
        'Permission Required',
        'Please enable microphone access in your device settings to use voice input.',
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void startListening() async {
    isListening.value = true;
    await _speechToText.listen(
      onResult: (result) {
        textController.value.text = result.recognizedWords;
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      onSoundLevelChange: null,
      cancelOnError: true,
    );
  }

  void stopListening() {
    _speechToText.stop();
    isListening.value = false;
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

    if (command.toLowerCase().contains("check in my car for")) {
      _handleCheckIn(command);
    } else if (command.toLowerCase().contains("check out")) {
      _handleCheckOut();
    } else {
      messages.insert(0,
          "Assistant: I'm sorry, I didn't understand that command. Can you please try again?");
    }
  }

  void _handleCheckIn(String command) {
    RegExp regExp = RegExp(r'check in my car for (\d+) hours?');
    Match? match = regExp.firstMatch(command.toLowerCase());

    if (match != null && match.groupCount >= 1) {
      String hours = match.group(1)!;
      Get.to(() => CheckInScreen());

      Future.delayed(const Duration(seconds: 1), () {
        CheckInController checkInController = Get.find();
        checkInController.durationController.text = hours;
        checkInController.confirmCheckIn();
      });

      messages.insert(0, "Assistant: Checking in your car for $hours hours.");
    } else {
      messages.insert(0,
          "Assistant: I couldn't understand the duration. Please try again.");
    }
  }

  void _handleCheckOut() {
    ParkingController parkingController = Get.find();
    if (parkingController.parkings.isNotEmpty) {
      int lastIndex = parkingController.parkings.length - 1;
      Get.to(() => CheckoutScreen(
          index: lastIndex, spot: parkingController.parkings[lastIndex]));
      messages.insert(0,
          "Assistant: Opening the checkout screen for your most recent parking.");
    } else {
      messages.insert(
          0, "Assistant: You don't have any active parkings to check out.");
    }
  }
}
