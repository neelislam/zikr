import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/zikr_model.dart';

class ZikrProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false; // Fix: Tracks if iOS gave permission yet
  String _lastWords = '';
  ZikrTask? _currentTask;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  ZikrTask? get currentTask => _currentTask;

  List<ZikrTask> dailyMissions = [
    ZikrTask(title: "Morning Astagfirullah", targetWords: ["astagfir", "استغفر", "astaghfirullah"], targetCount: 100),
    ZikrTask(title: "Morning Alhamdulillah", targetWords: ["alhamd", "الحمد", "alhamdulillah"], targetCount: 50),
    ZikrTask(title: "Morning Subhanallah", targetWords: ["subhan", "سبحان", "subhanallah"], targetCount: 33),
  ];

  void setCurrentTask(ZikrTask task) {
    _currentTask = task;
    notifyListeners();
  }

  void startListening() {
    _isListening = true;
    _startListeningInternal();
    notifyListeners();
  }

  Future<void> initSpeech() async {
    // Request BOTH microphone and speech recognition for iOS
    var micStatus = await Permission.microphone.request();
    var speechStatus = await Permission.speech.request();

    if (micStatus != PermissionStatus.granted || speechStatus != PermissionStatus.granted) {
      return; // Stop if the user denies permission
    }

    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _isListening && _currentTask != null && !_currentTask!.isCompleted) {
          Future.delayed(const Duration(milliseconds: 100), () => _startListeningInternal());
        }
      },
      onError: (errorNotification) => print('Speech Error: $errorNotification'),
    );
  }

  void _startListeningInternal() async {
    if (_speech.isListening) return;

    // GUARD: Ensure initialization is completely finished before listening
    if (!_isInitialized) {
      await initSpeech();
      if (!_isInitialized) return; // If it's STILL not initialized, abort.
    }

    _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;

        bool isMatch = _currentTask!.targetWords.any((word) =>
            _lastWords.toLowerCase().contains(word.toLowerCase())
        );

        if (isMatch) {
          incrementCount();
          _lastWords = '';
          _speech.stop();
        }
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  void stopListening() {
    _isListening = false;
    _speech.stop();
    notifyListeners();
  }

  void stopListeningSilent() {
    _isListening = false;
    _speech.stop();
  }

  void incrementCount() {
    if (_currentTask != null && !_currentTask!.isCompleted) {
      _currentTask!.currentCount++;
      if (_currentTask!.currentCount >= _currentTask!.targetCount) {
        _currentTask!.isCompleted = true;
        stopListening();
      }
      notifyListeners();
    }
  }
}