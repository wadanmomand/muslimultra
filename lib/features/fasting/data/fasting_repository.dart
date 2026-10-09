import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fast_log_entry.dart';

class FastingRepository {
  static const String _storageKey = 'muslim_ultra_fast_log_v1';
  static const String _intentionPrefix = 'muslim_ultra_fast_intention_';

  /// Loads all fast log entries from SharedPreferences
  Future<List<FastLogEntry>> loadLogEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final list = decoded
          .map((item) => FastLogEntry.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort newest first
      list.sort((a, b) => b.gregorianDate.compareTo(a.gregorianDate));
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Saves or updates a fast log entry
  Future<void> saveLogEntry(FastLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadLogEntries();

    final existingIndex = entries.indexWhere((e) => e.dateKey == entry.dateKey);
    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }

    entries.sort((a, b) => b.gregorianDate.compareTo(a.gregorianDate));
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Deletes a fast log entry by date key
  Future<void> deleteLogEntry(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadLogEntries();
    entries.removeWhere((e) => e.dateKey == dateKey);

    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Retrieves user's fasting intention for a specific date
  Future<bool> getFastingIntention(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_intentionPrefix$dateKey') ?? false;
  }

  /// Sets user's fasting intention for a specific date
  Future<void> setFastingIntention(String dateKey, bool isFasting) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_intentionPrefix$dateKey', isFasting);
  }

  /// Computes consecutive fasting streak (days)
  static int calculateStreak(List<FastLogEntry> entries, {DateTime? referenceToday}) {
    if (entries.isEmpty) return 0;

    final now = referenceToday ?? DateTime.now();
    final todayClean = DateTime(now.year, now.month, now.day);
    final todayKey = _dateToKey(todayClean);

    final entryMap = {for (final e in entries) e.dateKey: e};

    int streak = 0;
    DateTime checkDay = todayClean;

    // If today is marked kept/qada, start from today
    final todayEntry = entryMap[todayKey];
    if (todayEntry != null && (todayEntry.isKept || todayEntry.isQada)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    } else {
      // If today is not marked or missed, check if yesterday was kept
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    // Traverse backwards consecutively
    while (true) {
      final key = _dateToKey(checkDay);
      final entry = entryMap[key];
      if (entry != null && (entry.isKept || entry.isQada)) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Computes total fasts kept in the specified Hijri month & year
  static int calculateFastsThisMonth(
    List<FastLogEntry> entries,
    int hijriMonth,
    int hijriYear,
  ) {
    return entries.where((e) {
      return e.hijriMonth == hijriMonth &&
          e.hijriYear == hijriYear &&
          (e.isKept || e.isQada);
    }).length;
  }

  /// Computes total makeup (qada) days owed
  static int calculateMakeupDaysOwed(List<FastLogEntry> entries) {
    final missedCount = entries.where((e) => e.isMissed).length;
    final qadaCount = entries.where((e) => e.isQada).length;
    final owed = missedCount - qadaCount;
    return owed < 0 ? 0 : owed;
  }

  static String _dateToKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
