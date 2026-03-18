class ZikrTask {
  final String title;
  final List<String> targetWords; // Now accepts multiple variations!
  final int targetCount;
  int currentCount;
  bool isCompleted;

  ZikrTask({
    required this.title,
    required this.targetWords,
    required this.targetCount,
    this.currentCount = 0,
    this.isCompleted = false,
  });
}