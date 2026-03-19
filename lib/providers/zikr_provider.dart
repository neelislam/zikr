import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import 'dart:math';
import '../models/zikr_model.dart';

class ZikrProvider extends ChangeNotifier {
  // --- UI STATE ---
  bool _isDarkMode = false;
  int _currentStreak = 12; // Example streak

  // Generating a fake 30-day history for the GitHub Calendar UI
  // 0 = no activity, 4 = high activity
  final List<int> activityHistory = List.generate(30, (index) => Random().nextInt(5));

  bool get isDarkMode => _isDarkMode;
  int get currentStreak => _currentStreak;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // --- SPEECH ENGINE STATE ---
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  bool _isStartingMic = false;
  bool _isProcessingMatch = false;
  String _lastWords = '';
  String debugMessage = "Ready to start";
  ZikrTask? _currentTask;
  DateTime _lastCountTime = DateTime.now();

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  ZikrTask? get currentTask => _currentTask;

  // --- CATEGORIZED DOA LIST ---
  List<ZikrTask> allMissions = [
    // 1. SELF CONTROL DOA
    ZikrTask(category: "Self Control", title: "Afini Fi Badani", arabicTitle: "اللَّهُمَّ عَافِنِي فِي بَدَنِي", targetWords: ["afini", "badani"], targetCount: 3),
    ZikrTask(category: "Self Control", title: "A'inni Ala Zikrika", arabicTitle: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ", targetWords: ["ainni", "zikrika"], targetCount: 1),
    ZikrTask(category: "Self Control", title: "Hassin Khalqi", arabicTitle: "اللَّهُمَّ حَسِّنْ خَلْقِي", targetWords: ["hassin", "khalqi"], targetCount: 1),

    // 2. DAILY DOA
    ZikrTask(category: "Daily Doa", title: "Sayyidul Istighfar", arabicTitle: "اللَّهُمَّ أَنْتَ رَبِّي", targetWords: ["anta rabbi", "faghfir li"], targetCount: 1),
    ZikrTask(category: "Daily Doa", title: "Social Status", arabicTitle: "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ", targetWords: ["hasbiyallahu", "tawakkaltu"], targetCount: 7),
    ZikrTask(category: "Daily Doa", title: "Riziq", arabicTitle: "اللَّهُمَّ ارْزُقْنِي رِزْقًا طَيِّبًا", targetWords: ["rizqan", "tayyiban"], targetCount: 1),
    ZikrTask(category: "Daily Doa", title: "Ya Wadudu Ya Jamiu", arabicTitle: "يا ودود يا جامع يا سلام", targetWords: ["wadudu", "jamiu", "salamu"], targetCount: 11),

    // 3. TARGET ZIKR
    ZikrTask(category: "Target Zikr", title: "Astaghfirullah", arabicTitle: "أَسْتَغْفِرُ اللَّهَ", targetWords: ["astagfir", "استغفر", "astaghfirullah"], targetCount: 100),
    ZikrTask(category: "Target Zikr", title: "Alhamdulillah", arabicTitle: "الْحَمْدُ لِلَّهِ", targetWords: ["alhamd", "الحمد", "alhamdulillah"], targetCount: 55),
    ZikrTask(category: "Target Zikr", title: "SubhanAllah", arabicTitle: "سُبْحَانَ اللَّهِ", targetWords: ["subhan", "سبحان", "subhanallah"], targetCount: 55),
    ZikrTask(category: "Target Zikr", title: "Allahu Akbar", arabicTitle: "اللَّهُ أَكْبَرُ", targetWords: ["allahu akbar", "akbar"], targetCount: 34),
    ZikrTask(category: "Target Zikr", title: "La Hawla Wala", arabicTitle: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ", targetWords: ["la hawla", "quwwata", "billah"], targetCount: 499),
  ];

  // Helper to group lists for the UI
  Map<String, List<ZikrTask>> get groupedMissions {
    Map<String, List<ZikrTask>> map = {};
    for (var task in allMissions) {
      if (!map.containsKey(task.category)) {
        map[task.category] = [];
      }
      map[task.category]!.add(task);
    }
    return map;
  }

  void _setDebug(String msg) {
    debugMessage = msg;
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
      _setDebug("Permissions Denied");
      return;
    }

    _isInitialized = await _speech.initialize(
      onStatus: (status) async {
        if ((status == 'done' || status == 'notListening') && _isListening && !_isStartingMic) {
          if (_currentTask != null && !_currentTask!.isCompleted) {
            await Future.delayed(const Duration(milliseconds: 600));
            _startListeningInternal();
          } else {
            _isListening = false;
            notifyListeners();
          }
        }
      },
      onError: (errorNotification) => _setDebug("Error: ${errorNotification.errorMsg}"),
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
      _setDebug("Restarting...");
    } finally {
      _isStartingMic = false;
    }
  }

  void _checkFuzzyMatch(String heardSentence) {
    if (_currentTask == null || _currentTask!.isCompleted || heardSentence.isEmpty || _isProcessingMatch) return;
    if (DateTime.now().difference(_lastCountTime).inMilliseconds < 1200) return;

    List<String> heardWords = heardSentence.toLowerCase().split(' ');
    bool matchFound = false;

    for (String heardWord in heardWords) {
      for (String targetWord in _currentTask!.targetWords) {
        double similarity = StringSimilarity.compareTwoStrings(heardWord, targetWord.toLowerCase());
        if (similarity > 0.65 || heardWord == targetWord.toLowerCase()) {
          matchFound = true;
          break;
        }
      }
      if (matchFound) break;
    }

    if (matchFound) {
      _lastCountTime = DateTime.now();
      _isProcessingMatch = true;
      incrementCount();
      _speech.stop();

      Future.delayed(const Duration(milliseconds: 1500), () {
        _isProcessingMatch = false;
      });
    }
  }

  void stopListening() {
    _isListening = false;
    _isStartingMic = false;
    _speech.stop();
    _setDebug("Paused");
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
      HapticFeedback.mediumImpact();
      if (_currentTask!.currentCount >= _currentTask!.targetCount) {
        _currentTask!.isCompleted = true;
        stopListening();
        HapticFeedback.heavyImpact();
      }
      notifyListeners();
    }
  }
}