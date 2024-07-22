import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceAssistantController extends GetxController {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  var isListening = false.obs;
  var recognizedText = "".obs;
  var hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeechRecognizer();
  }

  Future<void> _initSpeechRecognizer() async {
    hasPermission.value = await _requestPermission();
    if (hasPermission.value) {
      await _speechToText.initialize();
    }
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
            'Microphone permission is required for voice input.');
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
}
