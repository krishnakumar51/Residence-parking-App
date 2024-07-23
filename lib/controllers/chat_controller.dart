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
    if (pendingCheckIn.value) {
      _handleDurationInput(command);
    } else if (command.toLowerCase().contains("check in")) {
      _handleCheckIn(command);
    } else if (command.toLowerCase().contains("check out")) {
      _handleCheckOut();
    } else if (command.toLowerCase() == "yes") {
      _handleYesResponse();
    } else if (command.toLowerCase() == "no") {
      _handleNoResponse();
    } else if (command.toLowerCase().contains("add vehicle")) {
      _handleAddVehicle(command);
    } else {
      _handleVehicleSelection(command);
    }
  }

  void _handleCheckIn(String command) {
    if (profileController.vehicles.isEmpty) {
      String response =
          "You haven't added any vehicles to your profile. Would you like to add a vehicle now? Say 'yes' to add a vehicle or 'no' to cancel.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    } else if (profileController.vehicles.length == 1) {
      String response =
          "You have one vehicle in your profile. Would you like to check in this vehicle? Say 'yes' to proceed or 'no' to cancel.";
      messages.insert(0, "Assistant: $response");
      speak(response);
      selectedVehicleForCheckIn.value = profileController.vehicles[0];
    } else {
      String response =
          "Which vehicle would you like to check in? Please say the brand and model of the vehicle.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    }
  }

  void _handleCheckOut() {
    if (parkingController.parkings.isEmpty) {
      String response = "You don't have any active parkings to check out.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    } else if (parkingController.parkings.length == 1) {
      String response =
          "You have one vehicle checked in. Would you like to check it out? Say 'yes' to proceed or 'no' to cancel.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    } else {
      String response =
          "You have multiple vehicles checked in. Which one would you like to check out? Please say the brand and model of the vehicle.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    }
  }

  void _handleYesResponse() {
    if (messages.last.contains("Would you like to add a vehicle now?")) {
      String response =
          "Please say 'add vehicle' followed by the vehicle type, brand, and model. For example, 'add vehicle car Toyota Camry'.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    } else if (messages.last
        .contains("Would you like to check in this vehicle?")) {
      _askForDuration(profileController.vehicles[0]);
    } else if (messages.last.contains("Would you like to check it out?")) {
      _proceedWithCheckout(0);
    } else if (messages.last
        .contains("Would you like to confirm the check-in?")) {
      Get.find<CheckInController>().confirmCheckIn();
    }
  }

  void _handleNoResponse() {
    String response =
        "Operation cancelled. Is there anything else I can help you with?";
    messages.insert(0, "Assistant: $response");
    speak(response);
  }

  void _handleAddVehicle(String command) {
    List<String> parts = command.split(' ');
    if (parts.length >= 4) {
      String type = parts[2];
      String brand = parts[3];
      String model = parts.sublist(4).join(' ');

      profileController.addVehicle(Vehicle(
          type: type,
          brand: brand,
          model: model,
          imagePath: 'assets/images/car.jpeg'));

      String response =
          "Vehicle added successfully. Would you like to check in this vehicle now? Say 'yes' to proceed or 'no' to cancel.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    } else {
      String response =
          "I couldn't understand the vehicle details. Please try again with the format: 'add vehicle [type] [brand] [model]'.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    }
  }

  void _handleVehicleSelection(String command) {
    Vehicle? selectedVehicle = profileController.vehicles.firstWhereOrNull(
        (v) =>
            command.toLowerCase().contains(v.brand.toLowerCase()) &&
            command.toLowerCase().contains(v.model.toLowerCase()));

    if (selectedVehicle != null) {
      if (messages.last.contains("Which vehicle would you like to check in?")) {
        _askForDuration(selectedVehicle);
      } else if (messages.last
          .contains("Which one would you like to check out?")) {
        int index = parkingController.parkings.indexWhere((p) =>
            p.brand.toLowerCase() == selectedVehicle.brand.toLowerCase() &&
            p.model.toLowerCase() == selectedVehicle.model.toLowerCase());
        if (index != -1) {
          _proceedWithCheckout(index);
        } else {
          String response =
              "I couldn't find that vehicle in the current parkings. Please try again.";
          messages.insert(0, "Assistant: $response");
          speak(response);
        }
      }
    } else {
      String response =
          "I couldn't find a vehicle matching that description. Please try again.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    }
  }

  void _askForDuration(Vehicle vehicle) {
    selectedVehicleForCheckIn.value = vehicle;
    pendingCheckIn.value = true;
    String response =
        "For how many hours would you like to check in the ${vehicle.brand} ${vehicle.model}?";
    messages.insert(0, "Assistant: $response");
    speak(response);
  }

  void _handleDurationInput(String command) {
    RegExp regExp = RegExp(r'\d+');
    Match? match = regExp.firstMatch(command);

    if (match != null) {
      int hours = int.parse(match.group(0)!);
      pendingCheckIn.value = false;
      _proceedWithCheckIn(selectedVehicleForCheckIn.value!, hours);
    } else {
      String response =
          "I'm sorry, I couldn't understand the duration. Please say a number for the hours you want to check in.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    }
  }

  void _proceedWithCheckIn(Vehicle vehicle, int duration) {
    Get.to(() => CheckInScreen());

    Future.delayed(const Duration(seconds: 1), () {
      CheckInController checkInController = Get.find();
      checkInController.selectedVehicle.value = vehicle;
      checkInController.durationController.text = duration.toString();
      checkInController.calculateCost();
      String response =
          "The cost for $duration hours is \$${checkInController.cost.value.toStringAsFixed(2)}. Would you like to confirm the check-in? Say 'yes' to confirm or 'no' to cancel.";
      messages.insert(0, "Assistant: $response");
      speak(response);
    });
  }

  void _proceedWithCheckout(int index) {
    ParkingController parkingController = Get.find();
    Get.to(() =>
        CheckoutScreen(index: index, spot: parkingController.parkings[index]));
  }
}
