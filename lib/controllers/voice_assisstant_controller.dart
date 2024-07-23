import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_app/controllers/chat_controller.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantController extends GetxController {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  var isListening = false.obs;
  var recognizedText = "".obs;
  var hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeechRecognizer();
    _initTts();
  }

  Future<void> _initSpeechRecognizer() async {
    hasPermission.value = await _requestPermission();
    if (hasPermission.value) {
      await _speechToText.initialize();
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
  }

  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> toggleListening() async {
    if (!hasPermission.value) {
      hasPermission.value = await _requestPermission();
      if (!hasPermission.value) {
        Get.snackbar('Permission Denied',
            'Microphone permission is required for voice input.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    if (isListening.value) {
      stopListening();
    } else {
      startListening();
    }
  }

  void startListening() async {
    recognizedText.value = "";
    isListening.value = true;
    await _speechToText.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        if (result.finalResult) {
          Get.find<ChatController>().sendMessage(recognizedText.value);
          stopListening();
        }
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

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }
}
