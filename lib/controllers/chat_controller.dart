import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:my_app/controllers/check_in_controller.dart';
import 'package:my_app/controllers/parking_controller.dart';
import 'package:my_app/views/check_in_screen.dart';
import 'package:my_app/views/check_out_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_app/controllers/user_profile_controller.dart';

class ChatController extends GetxController {
  final RxList<String> messages = <String>[].obs;
  final Rx<TextEditingController> textController = TextEditingController().obs;
  final focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  var isListening = false.obs;
  var recognizedText = "".obs;

  final FlutterTts flutterTts = FlutterTts();

  final ProfileController profileController = Get.find();
  final ParkingController parkingController = Get.find();

  var pendingCheckIn = false.obs;
  var selectedVehicleForCheckIn = Rx<Vehicle?>(null);

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(_onFocusChange);
    ever(messages, (_) => _scrollToBottom());
    _initSpeechRecognizer();
    _initTts();
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

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
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

  Future<void> startListening() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone.request();
    }

    if (await Permission.microphone.isGranted) {
      isListening.value = true;
      recognizedText.value = "";
      await _speechToText.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
          if (result.finalResult) {
            sendMessage(recognizedText.value);
            stopListening();
          }
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: null,
        cancelOnError: true,
      );
    } else {
      Get.snackbar(
        'Permission Required',
        'Please enable microphone access in your device settings to use voice input.',
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void stopListening() {
    _speechToText.stop();
    isListening.value = false;
    recognizedText.value = "";
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void sendMessage([String? voiceMessage]) {
    String messageToSend = voiceMessage ?? textController.value.text;
    if (messageToSend.isNotEmpty) {
      messages.insert(0, "You: $messageToSend");
      textController.value.clear();
      recognizedText.value = "";
      _processCommand(messageToSend);
      _scrollToBottom();
    }
  }

  void _processCommand(String command) {
    final lowercaseCommand = command.toLowerCase();

    if (_containsAny(lowercaseCommand, ['check in', 'checkin', 'parking'])) {
      _handleCheckIn();
    } else if (_containsAny(
        lowercaseCommand, ['check out', 'checkout', 'leave'])) {
      _handleCheckOut();
    } else if (_containsAny(
        lowercaseCommand, ['add vehicle', 'new vehicle', 'register vehicle'])) {
      _handleAddVehicle(command);
    } else if (_containsAny(lowercaseCommand, ['yes', 'confirm', 'proceed'])) {
      _handleConfirmation();
    } else if (_containsAny(lowercaseCommand, ['no', 'cancel', 'stop'])) {
      _handleCancellation();
    } else if (_containsAny(
        lowercaseCommand, ['parking info', 'available spaces'])) {
      _handleParkingInfo();
    } else {
      _handleOtherCommands(lowercaseCommand);
    }
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  void _handleCheckIn() {
    if (profileController.vehicles.isEmpty) {
      _respondAndSpeak(
          "You don't have any vehicles registered. Would you like to add a vehicle now?");
    } else {
      String vehicleList = profileController.vehicles
          .map((v) => "${v.brand} ${v.model}")
          .join(", ");
      _respondAndSpeak(
          "Which vehicle would you like to check in? Your options are: $vehicleList");
    }
  }

  void _handleCheckOut() {
    if (parkingController.parkings.isEmpty) {
      _respondAndSpeak("You don't have any active parkings to check out.");
    } else {
      String parkingList = parkingController.parkings
          .map((p) => "${p.brand} ${p.model}")
          .join(", ");
      _respondAndSpeak(
          "Which vehicle would you like to check out? Your options are: $parkingList");
    }
  }

  void _handleAddVehicle(String command) {
    List<String> parts = command.split(' ');
    if (parts.length >= 4) {
      String type = parts[parts.indexOf('vehicle') + 1];
      String brand = parts[parts.indexOf('vehicle') + 2];
      String model = parts.sublist(parts.indexOf('vehicle') + 3).join(' ');

      profileController.addVehicle(Vehicle(
          type: type,
          brand: brand,
          model: model,
          imagePath: 'assets/images/car.jpeg'));

      _respondAndSpeak(
          "Great! I've added the $brand $model to your profile. Would you like to check in with this vehicle now?");
    } else {
      _respondAndSpeak(
          "I couldn't catch the vehicle details. Please use the format: 'add vehicle [type] [brand] [model]'.");
    }
  }

  void _handleConfirmation() {
    if (pendingCheckIn.value) {
      _proceedWithCheckIn(selectedVehicleForCheckIn.value!,
          int.parse(Get.find<CheckInController>().durationController.text));
    } else if (messages.last.contains("Would you like to check it out now?")) {
      _proceedWithCheckout(0);
    } else {
      _respondAndSpeak(
          "I'm not sure what you're confirming. Can you please provide more context?");
    }
  }

  void _handleCancellation() {
    pendingCheckIn.value = false;
    selectedVehicleForCheckIn.value = null;
    _respondAndSpeak(
        "Alright, I've cancelled the current operation. Is there anything else I can help you with?");
  }

  void _handleParkingInfo() {
    String carSpaces = parkingController.getAvailableSpaces('Car').toString();
    String bikeSpaces = parkingController.getAvailableSpaces('Bike').toString();
    _respondAndSpeak(
        "Currently, there are $carSpaces car spaces and $bikeSpaces bike spaces available.");
  }

  void _handleOtherCommands(String command) {
    Vehicle? selectedVehicle = profileController.vehicles.firstWhereOrNull(
        (v) =>
            command.contains(v.brand.toLowerCase()) &&
            command.contains(v.model.toLowerCase()));

    if (selectedVehicle != null) {
      _askForDuration(selectedVehicle);
    } else if (RegExp(r'\d+').hasMatch(command)) {
      _handleDurationInput(command);
    } else {
      _respondAndSpeak(
          "I'm not sure how to help with that. Can you try rephrasing or ask for check-in, check-out, or adding a vehicle?");
    }
  }

  void _askForDuration(Vehicle vehicle) {
    selectedVehicleForCheckIn.value = vehicle;
    pendingCheckIn.value = true;
    _respondAndSpeak(
        "For how many hours would you like to check in the ${vehicle.brand} ${vehicle.model}?");
  }

  void _handleDurationInput(String command) {
    RegExp regExp = RegExp(r'\d+');
    Match? match = regExp.firstMatch(command);

    if (match != null) {
      int hours = int.parse(match.group(0)!);
      pendingCheckIn.value = false;
      _proceedWithCheckIn(selectedVehicleForCheckIn.value!, hours);
    } else {
      _respondAndSpeak(
          "I didn't catch the duration. Please tell me how many hours you'd like to park for.");
    }
  }

  void _proceedWithCheckIn(Vehicle vehicle, int duration) {
    Get.to(() => CheckInScreen());

    Future.delayed(const Duration(seconds: 1), () {
      CheckInController checkInController = Get.find();
      checkInController.selectedVehicle.value = vehicle;
      checkInController.durationController.text = duration.toString();
      checkInController.calculateCost();
      _respondAndSpeak(
          "I've calculated the cost for $duration hours. It will be \$${checkInController.cost.value.toStringAsFixed(2)}. Would you like to confirm the check-in?");
    });
  }

  void _proceedWithCheckout(int index) {
    ParkingController parkingController = Get.find();
    Get.to(() =>
        CheckoutScreen(index: index, spot: parkingController.parkings[index]));
    _respondAndSpeak(
        "I've initiated the check-out process for your ${parkingController.parkings[index].brand} ${parkingController.parkings[index].model}. Please follow the instructions on the screen to complete the process.");
  }

  void _respondAndSpeak(String message) {
    messages.insert(0, "Assistant: $message");
    speak(message);
  }
}
