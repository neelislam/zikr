class ZikrTask {
  final String category;
  final String title;
  final String arabicTitle;
  final List<String> targetWords;
  final int targetCount;
  int currentCount;
  bool isCompleted;

  ZikrTask({
    required this.category,
    required this.title,
    required this.arabicTitle,
    required this.targetWords,
    required this.targetCount,
    this.currentCount = 0,
    this.isCompleted = false,
  });
}