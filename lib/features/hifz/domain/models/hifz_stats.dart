class HifzStats {
  final int memorizedCount;
  final int learningCount;
  final int dueCount;
  final int streakDays;

  const HifzStats({
    required this.memorizedCount,
    required this.learningCount,
    required this.dueCount,
    required this.streakDays,
  });

  factory HifzStats.empty() {
    return const HifzStats(
      memorizedCount: 0,
      learningCount: 0,
      dueCount: 0,
      streakDays: 0,
    );
  }
}
