import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/deen/domain/models/deen_xp.dart';

/// Result of awarding XP
class AwardXpResult {
  final int newTotalXp;
  final bool leveledUp;
  final DeenLevel newLevel;
  final int amountAwarded;

  const AwardXpResult({
    required this.newTotalXp,
    required this.leveledUp,
    required this.newLevel,
    required this.amountAwarded,
  });
}

/// Daily checklist progress state
class DailyDeenState {
  final String date;
  final int quranMinutes;
  final bool morningDhikr;
  final bool eveningDhikr;
  final bool learningViewed;
  final bool quizAnswered;
  final bool fullDeenClaimed;

  const DailyDeenState({
    required this.date,
    this.quranMinutes = 0,
    this.morningDhikr = false,
    this.eveningDhikr = false,
    this.learningViewed = false,
    this.quizAnswered = false,
    this.fullDeenClaimed = false,
  });

  factory DailyDeenState.fromJson(Map<String, dynamic> json) {
    return DailyDeenState(
      date: (json['date'] as String?) ?? '',
      quranMinutes: (json['quranMinutes'] as num?)?.toInt() ?? 0,
      morningDhikr: (json['morningDhikr'] as bool?) ?? false,
      eveningDhikr: (json['eveningDhikr'] as bool?) ?? false,
      learningViewed: (json['learningViewed'] as bool?) ?? false,
      quizAnswered: (json['quizAnswered'] as bool?) ?? false,
      fullDeenClaimed: (json['fullDeenClaimed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'quranMinutes': quranMinutes,
        'morningDhikr': morningDhikr,
        'eveningDhikr': eveningDhikr,
        'learningViewed': learningViewed,
        'quizAnswered': quizAnswered,
        'fullDeenClaimed': fullDeenClaimed,
      };

  DailyDeenState copyWith({
    String? date,
    int? quranMinutes,
    bool? morningDhikr,
    bool? eveningDhikr,
    bool? learningViewed,
    bool? quizAnswered,
    bool? fullDeenClaimed,
  }) {
    return DailyDeenState(
      date: date ?? this.date,
      quranMinutes: quranMinutes ?? this.quranMinutes,
      morningDhikr: morningDhikr ?? this.morningDhikr,
      eveningDhikr: eveningDhikr ?? this.eveningDhikr,
      learningViewed: learningViewed ?? this.learningViewed,
      quizAnswered: quizAnswered ?? this.quizAnswered,
      fullDeenClaimed: fullDeenClaimed ?? this.fullDeenClaimed,
    );
  }
}

/// Central repository managing Deen XP, daily checklists, and streak freeze protections
class DeenRepository {
  static const String keyTotalXp = 'deen_xp_v1_total';
  static const String keyAwardedReasons = 'deen_xp_v1_reasons';
  static const String keyDailyStatePrefix = 'deen_daily_v1_';
  static const String keyFrozenDays = 'deen_frozen_days_v1';
  static const String keyUsedFreezeWeeks = 'deen_freeze_weeks_v1';

  static String formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// Helper to get Monday-based ISO week key e.g. "2026-W41"
  static String formatWeekKey(DateTime dt) {
    // Find the Monday of the current week
    final daysToMonday = dt.weekday - DateTime.monday;
    final monday = dt.subtract(Duration(days: daysToMonday));
    return 'W_${DateFormat('yyyy-MM-dd').format(monday)}';
  }

  /// Gets the user's total XP
  Future<DeenXp> getDeenXp() async {
    final prefs = await SharedPreferences.getInstance();
    final total = prefs.getInt(keyTotalXp) ?? 0;
    return DeenXp(totalXp: total);
  }

  /// Awards XP idempotently for a given unique reason key.
  /// If [reason] has already been awarded, returns 0 XP awarded with current total.
  Future<AwardXpResult> awardXp(int amount, String reason) async {
    if (amount <= 0) {
      final current = await getDeenXp();
      return AwardXpResult(
        newTotalXp: current.totalXp,
        leveledUp: false,
        newLevel: current.level,
        amountAwarded: 0,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> awarded = prefs.getStringList(keyAwardedReasons) ?? [];

    if (awarded.contains(reason)) {
      final current = await getDeenXp();
      return AwardXpResult(
        newTotalXp: current.totalXp,
        leveledUp: false,
        newLevel: current.level,
        amountAwarded: 0,
      );
    }

    // Award XP
    final currentTotal = prefs.getInt(keyTotalXp) ?? 0;
    final oldLevel = DeenLevel.levelFor(currentTotal);
    final newTotal = currentTotal + amount;
    final newLevel = DeenLevel.levelFor(newTotal);

    awarded.add(reason);
    await prefs.setStringList(keyAwardedReasons, awarded);
    await prefs.setInt(keyTotalXp, newTotal);

    return AwardXpResult(
      newTotalXp: newTotal,
      leveledUp: newLevel.index > oldLevel.index,
      newLevel: newLevel,
      amountAwarded: amount,
    );
  }

  /// Retrieves the daily state for [forDate] (default today)
  Future<DailyDeenState> getDailyState([DateTime? forDate]) async {
    final target = forDate ?? DateTime.now();
    final dateStr = formatDate(target);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$keyDailyStatePrefix$dateStr');
    if (raw == null || raw.isEmpty) {
      return DailyDeenState(date: dateStr);
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return DailyDeenState.fromJson(map);
    } catch (_) {
      return DailyDeenState(date: dateStr);
    }
  }

  /// Retrieves all recorded daily states
  Future<Map<String, DailyDeenState>> getAllDailyStates() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final result = <String, DailyDeenState>{};

    for (final key in keys) {
      if (key.startsWith(keyDailyStatePrefix)) {
        final dateStr = key.substring(keyDailyStatePrefix.length);
        final raw = prefs.getString(key);
        if (raw != null && raw.isNotEmpty) {
          try {
            final map = json.decode(raw) as Map<String, dynamic>;
            result[dateStr] = DailyDeenState.fromJson(map);
          } catch (_) {}
        }
      }
    }
    return result;
  }

  /// Saves daily state

  Future<void> _saveDailyState(DailyDeenState state) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(state.toJson());
    await prefs.setString('$keyDailyStatePrefix${state.date}', encoded);
  }

  /// Sets morning dhikr state and awards XP on completion
  Future<void> setMorningDhikr(bool done, [DateTime? date]) async {
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final state = await getDailyState(target);
    final updated = state.copyWith(morningDhikr: done);
    await _saveDailyState(updated);

    if (done) {
      await awardXp(10, 'dhikr_morning_$dateStr');
      await checkAndAwardFullDeen(target);
    }
  }

  /// Sets evening dhikr state and awards XP on completion
  Future<void> setEveningDhikr(bool done, [DateTime? date]) async {
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final state = await getDailyState(target);
    final updated = state.copyWith(eveningDhikr: done);
    await _saveDailyState(updated);

    if (done) {
      await awardXp(10, 'dhikr_evening_$dateStr');
      await checkAndAwardFullDeen(target);
    }
  }

  /// Adds reading minutes to Quran daily goal and awards 1 XP per minute (up to 30/day)
  Future<void> addQuranMinutes(int minutes, [DateTime? date]) async {
    if (minutes <= 0) return;
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final state = await getDailyState(target);

    final previousMinutes = state.quranMinutes;
    final newMinutes = previousMinutes + minutes;
    await _saveDailyState(state.copyWith(quranMinutes: newMinutes));

    // Award XP for each minute up to cap of 30 min per day
    for (var m = previousMinutes + 1; m <= newMinutes && m <= 30; m++) {
      await awardXp(1, 'quran_min_${dateStr}_$m');
    }

    await checkAndAwardFullDeen(target);
  }

  /// Marks today's learning as viewed and awards +5 XP
  Future<void> setLearningViewed([DateTime? date]) async {
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final state = await getDailyState(target);
    if (!state.learningViewed) {
      await _saveDailyState(state.copyWith(learningViewed: true));
      await awardXp(5, 'learning_$dateStr');
    }
  }

  /// Checks if full Deen requirements are met (5 prayers + >=10m Quran + morning & evening dhikr)
  /// and awards +25 XP bonus
  Future<bool> checkAndAwardFullDeen([DateTime? date, int prayedPrayersCount = 0]) async {
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final state = await getDailyState(target);

    if (state.fullDeenClaimed) return true;

    final hasPrayers = prayedPrayersCount >= 5;
    final hasQuran = state.quranMinutes >= 10;
    final hasDhikr = state.morningDhikr && state.eveningDhikr;

    if (hasPrayers && hasQuran && hasDhikr) {
      await _saveDailyState(state.copyWith(fullDeenClaimed: true));
      await awardXp(25, 'full_deen_$dateStr');
      return true;
    }
    return false;
  }

  // ================= STREAK FREEZE (PART 6) =================

  /// Checks if a streak freeze is available for the current week (1 per week, resets Monday)
  Future<bool> isFreezeAvailable([DateTime? forDate]) async {
    final target = forDate ?? DateTime.now();
    final weekKey = formatWeekKey(target);
    final prefs = await SharedPreferences.getInstance();
    final List<String> usedWeeks = prefs.getStringList(keyUsedFreezeWeeks) ?? [];
    return !usedWeeks.contains(weekKey);
  }

  /// Applies a streak freeze to [date], protecting yesterday/missed day from breaking streaks.
  Future<bool> useFreeze(DateTime date) async {
    final canUse = await isFreezeAvailable(date);
    if (!canUse) return false;

    final dateStr = formatDate(date);
    final weekKey = formatWeekKey(date);

    final prefs = await SharedPreferences.getInstance();
    final List<String> frozen = prefs.getStringList(keyFrozenDays) ?? [];
    if (!frozen.contains(dateStr)) {
      frozen.add(dateStr);
      await prefs.setStringList(keyFrozenDays, frozen);
    }

    final List<String> usedWeeks = prefs.getStringList(keyUsedFreezeWeeks) ?? [];
    if (!usedWeeks.contains(weekKey)) {
      usedWeeks.add(weekKey);
      await prefs.setStringList(keyUsedFreezeWeeks, usedWeeks);
    }

    return true;
  }

  /// Checks if a specific date was protected by a streak freeze
  Future<bool> isDayFrozen(DateTime date) async {
    final dateStr = formatDate(date);
    final prefs = await SharedPreferences.getInstance();
    final List<String> frozen = prefs.getStringList(keyFrozenDays) ?? [];
    return frozen.contains(dateStr);
  }

  /// Gets all dates (yyyy-MM-dd) protected by a streak freeze
  Future<Set<String>> getFrozenDays() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> frozen = prefs.getStringList(keyFrozenDays) ?? [];
    return frozen.toSet();
  }
}
