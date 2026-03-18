import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/zikr_model.dart';

class ZikrProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  ZikrTask? _currentTask;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  ZikrTask? get currentTask => _currentTask;

  // We now provide English, Arabic, and phonetic spellings to make it super forgiving!
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
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;

    await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _isListening && _currentTask != null && !_currentTask!.isCompleted) {
          Future.delayed(const Duration(milliseconds: 100), () => _startListeningInternal());
        }
      },
      onError: (errorNotification) {},
    );
  }

  void _startListeningInternal() async {
    if (_speech.isListening) return;
    if (!_speech.isAvailable) await initSpeech();

    _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;

        // Check if ANY of our target words are in the recognized speech
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
      // Removed strict localeId. It will now use your device's default system language
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  // Used by the UI button
  void stopListening() {
    _isListening = false;
    _speech.stop();
    notifyListeners();
  }

  // FIX: Used when leaving the screen to prevent the red crash!
  void stopListeningSilent() {
    _isListening = false;
    _speech.stop();
    // Notice there is no notifyListeners() here.
  }

  void incrementCount() {
    if (_currentTask != null && !_currentTask!.isCompleted) {
      _currentTask!.currentCount++;
      if (_currentTask!.currentCount >= _currentTask!.targetCount) {
        _currentTask!.isCompleted = true;
        stopListening();
      }
      notifyListeners(); // Safe here
    }
  }
}