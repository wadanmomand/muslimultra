/// Represents the current fasting phase of the day
enum FastingCountdownStage {
  beforeSuhoor, // Prior to Fajr — Suhoor countdown
  fasting,      // Between Fajr and Maghrib — Iftar countdown
  completed,    // After Maghrib — Fasting completed for the day
}

/// Snapshot of the live fasting countdown state
class FastingCountdownState {
  final FastingCountdownStage stage;
  final DateTime targetTime;
  final Duration remainingDuration;
  final String formattedCountdown;
  final DateTime fajrTime;
  final DateTime maghribTime;
  final double progressFraction; // 0.0 to 1.0

  const FastingCountdownState({
    required this.stage,
    required this.targetTime,
    required this.remainingDuration,
    required this.formattedCountdown,
    required this.fajrTime,
    required this.maghribTime,
    this.progressFraction = 0.0,
  });

  bool get isFastingHours => stage == FastingCountdownStage.fasting;
  bool get isBeforeSuhoor => stage == FastingCountdownStage.beforeSuhoor;
  bool get isCompleted => stage == FastingCountdownStage.completed;

  /// Pure helper to compute countdown state for any given [now] and [fajr], [maghrib]
  static FastingCountdownState compute({
    required DateTime now,
    required DateTime fajr,
    required DateTime maghrib,
  }) {
    if (now.isBefore(fajr)) {
      final diff = fajr.difference(now);
      return FastingCountdownState(
        stage: FastingCountdownStage.beforeSuhoor,
        targetTime: fajr,
        remainingDuration: diff,
        formattedCountdown: _formatDuration(diff),
        fajrTime: fajr,
        maghribTime: maghrib,
        progressFraction: 0.0,
      );
    } else if (now.isBefore(maghrib)) {
      final diff = maghrib.difference(now);
      final totalFasting = maghrib.difference(fajr).inSeconds;
      final elapsed = now.difference(fajr).inSeconds;
      final progress = totalFasting > 0 ? (elapsed / totalFasting).clamp(0.0, 1.0) : 0.0;

      return FastingCountdownState(
        stage: FastingCountdownStage.fasting,
        targetTime: maghrib,
        remainingDuration: diff,
        formattedCountdown: _formatDuration(diff),
        fajrTime: fajr,
        maghribTime: maghrib,
        progressFraction: progress,
      );
    } else {
      // Completed for today; next target is tomorrow's Fajr
      final tomorrowFajr = fajr.add(const Duration(days: 1));
      final diff = tomorrowFajr.difference(now);
      return FastingCountdownState(
        stage: FastingCountdownStage.completed,
        targetTime: tomorrowFajr,
        remainingDuration: diff,
        formattedCountdown: _formatDuration(diff),
        fajrTime: fajr,
        maghribTime: maghrib,
        progressFraction: 1.0,
      );
    }
  }

  static String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
