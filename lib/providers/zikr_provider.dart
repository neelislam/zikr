import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import '../models/zikr_model.dart';

class ZikrProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  bool _isStartingMic = false;
  String _lastWords = '';
  String debugMessage = "Waiting to start...";
  ZikrTask? _currentTask;

  // Track the last time a count happened to prevent double-counting
  DateTime _lastCountTime = DateTime.now();

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  ZikrTask? get currentTask => _currentTask;

  List<ZikrTask> dailyMissions = [
    ZikrTask(title: "Morning Astagfirullah", targetWords: ["astagfir", "استغفر", "astaghfirullah", "aas tak", "phir"], targetCount: 100),
    ZikrTask(title: "Morning Alhamdulillah", targetWords: ["alhamd", "الحمد", "alhamdulillah", "al hum"], targetCount: 50),
    ZikrTask(title: "Morning Subhanallah", targetWords: ["subhan", "سبحان", "subhanallah", "soup on"], targetCount: 33),
  ];

  void _setDebug(String msg) {
    debugMessage = msg;
    print("ZIKR DEBUG: $msg");
    notifyListeners();
  }

  void setCurrentTask(ZikrTask task) {
    _currentTask = task;
    notifyListeners();
  }

  void startListening() async {
    if (_isListening || _isStartingMic) return;
    _isListening = true;
    notifyListeners();
    await _startListeningInternal();
  }

  Future<void> initSpeech() async {
    var micStatus = await Permission.microphone.request();
    var speechStatus = await Permission.speech.request();

    if (micStatus != PermissionStatus.granted || speechStatus != PermissionStatus.granted) {
      _setDebug("ERROR: Permissions Denied");
      return;
    }

    _isInitialized = await _speech.initialize(
      onStatus: (status) async {
        _setDebug("Mic Status: $status");
        if ((status == 'done' || status == 'notListening') && _isListening && !_isStartingMic) {
          if (_currentTask != null && !_currentTask!.isCompleted) {
            await Future.delayed(const Duration(milliseconds: 600)); // Breathing room
            _startListeningInternal();
          }
        }
      },
      onError: (errorNotification) => _setDebug("MIC ERROR: ${errorNotification.errorMsg}"),
    );
  }

  Future<void> _startListeningInternal() async {
    if (_isStartingMic) return;
    _isStartingMic = true;

    if (!_isInitialized) {
      await initSpeech();
      if (!_isInitialized) { _isStartingMic = false; return; }
    }

    _setDebug("Listening...");
    try {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _checkFuzzyMatch(_lastWords);
          notifyListeners();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: false),
      );
    } catch (e) {
      _setDebug("RESTARTING ENGINE...");
    } finally {
      _isStartingMic = false;
    }
  }

  void _checkFuzzyMatch(String heardSentence) {
    if (_currentTask == null || _currentTask!.isCompleted || heardSentence.isEmpty) return;

    // COOLDOWN: Must wait 1.2 seconds between counts
    if (DateTime.now().difference(_lastCountTime).inMilliseconds < 1200) return;

    List<String> heardWords = heardSentence.toLowerCase().split(' ');
    bool matchFound = false;

    for (String heardWord in heardWords) {
      for (String targetWord in _currentTask!.targetWords) {
        double similarity = StringSimilarity.compareTwoStrings(heardWord, targetWord.toLowerCase());
        if (similarity > 0.35 || heardWord.contains(targetWord.toLowerCase())) {
          matchFound = true;
          break;
        }
      }
      if (matchFound) break;
    }

    if (matchFound) {
      _lastCountTime = DateTime.now();
      incrementCount();
      _speech.stop(); // Stop to clear the buffer for the next count
    }
  }

  void stopListening() {
    _isListening = false;
    _isStartingMic = false;
    _speech.stop();
    _setDebug("Stopped.");
    notifyListeners();
  }

  void stopListeningSilent() {
    _isListening = false;
    _isStartingMic = false;
    _speech.stop();
  }

  void incrementCount() {
    if (_currentTask != null && !_currentTask!.isCompleted) {
      _currentTask!.currentCount++;
      HapticFeedback.mediumImpact(); // Vibrate iPhone
      if (_currentTask!.currentCount >= _currentTask!.targetCount) {
        _currentTask!.isCompleted = true;
        stopListening();
      }
      notifyListeners();
    }
  }
}