import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';

/// Repository for persisting and computing prayer logs, streaks, and statistics.
class PrayerTrackingRepository {
  static const String storageKey = 'prayer_log_v1';

  static String formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// Loads all stored prayer log entries
  Future<List<PrayerLogEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = json.decode(raw);
      return decoded
          .map((item) => PrayerLogEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves a list of prayer log entries
  Future<void> _saveAllEntries(List<PrayerLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  /// Logs or updates a prayer entry for a given date and prayer
  Future<void> logPrayer(PrayerLogEntry entry) async {
    final entries = await getAllEntries();
    final index = entries.indexWhere(
      (e) => e.date == entry.date && e.prayer.toLowerCase() == entry.prayer.toLowerCase(),
    );

    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }

    await _saveAllEntries(entries);
  }

  /// Removes a logged prayer entry
  Future<void> removePrayerLog(String date, String prayer) async {
    final entries = await getAllEntries();
    entries.removeWhere(
      (e) => e.date == date && e.prayer.toLowerCase() == prayer.toLowerCase(),
    );
    await _saveAllEntries(entries);
  }

  /// Gets a specific entry for a date and prayer
  Future<PrayerLogEntry?> getEntry(String date, String prayer) async {
    final entries = await getAllEntries();
    for (final e in entries) {
      if (e.date == date && e.prayer.toLowerCase() == prayer.toLowerCase()) {
        return e;
      }
    }
    return null;
  }

  /// Gets all entries for a specific date as a Map keyed by prayer name
  Future<Map<String, PrayerLogEntry>> getEntriesForDate(String date) async {
    final entries = await getAllEntries();
    final map = <String, PrayerLogEntry>{};
    for (final e in entries) {
      if (e.date == date) {
        map[e.prayer.toLowerCase()] = e;
      }
    }
    return map;
  }

  /// Gets all entries for the 7 days ending on [forDate] (default: today)
  Future<List<PrayerLogEntry>> getWeekEntries([DateTime? forDate]) async {
    final end = forDate ?? DateTime.now();
    final weekDates = <String>{};
    for (var i = 0; i < 7; i++) {
      final day = end.subtract(Duration(days: i));
      weekDates.add(formatDate(day));
    }

    final entries = await getAllEntries();
    return entries.where((e) => weekDates.contains(e.date)).toList();
  }

  /// Checks whether all 5 obligatory prayers were marked as [PrayerLogStatus.prayed] on a given date
  bool isDayFullyPrayed(String date, List<PrayerLogEntry> allEntries) {
    final dayEntries = allEntries.where((e) => e.date == date).toList();
    for (final prayer in TrackedPrayer.all) {
      final entry = dayEntries.firstWhere(
        (e) => e.prayer.toLowerCase() == prayer.keyName,
        orElse: () => PrayerLogEntry(
          date: date,
          prayer: prayer.keyName,
          status: PrayerLogStatus.missed,
          timestamp: DateTime.now(),
        ),
      );
      if (entry.status != PrayerLogStatus.prayed) {
        return false;
      }
    }
    return true;
  }

  /// Computes the current consecutive days streak of all 5 prayers prayed.
  /// If today has all 5 prayed, today counts.
  /// If today is in progress, but yesterday was fully prayed, the streak counts back from yesterday.
  /// If yesterday wasn't fully prayed (and today isn't yet), streak is 0.
  Future<int> currentStreak([DateTime? asOfDate]) async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return 0;

    final today = asOfDate ?? DateTime.now();
    final todayStr = formatDate(today);
    final yesterdayStr = formatDate(today.subtract(const Duration(days: 1)));

    var streak = 0;
    DateTime checkDate;

    if (isDayFullyPrayed(todayStr, entries)) {
      streak = 1;
      checkDate = today.subtract(const Duration(days: 1));
    } else if (isDayFullyPrayed(yesterdayStr, entries)) {
      streak = 0;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    // Traverse backwards
    while (true) {
      final dateStr = formatDate(checkDate);
      if (isDayFullyPrayed(dateStr, entries)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Computes the all-time best streak (maximum consecutive fully prayed days)
  Future<int> bestStreak() async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return 0;

    // Collect all distinct dates present in entries
    final dates = entries.map((e) => e.date).toSet().toList()..sort();
    if (dates.isEmpty) return 0;

    var maxStreak = 0;
    var currentRun = 0;
    DateTime? lastDate;

    for (final dateStr in dates) {
      if (isDayFullyPrayed(dateStr, entries)) {
        final parsedDate = DateTime.tryParse(dateStr);
        if (parsedDate == null) continue;

        if (lastDate == null) {
          currentRun = 1;
        } else {
          final diff = parsedDate.difference(lastDate).inDays;
          if (diff == 1) {
            currentRun++;
          } else {
            currentRun = 1;
          }
        }
        lastDate = parsedDate;
        if (currentRun > maxStreak) {
          maxStreak = currentRun;
        }
      }
    }

    return maxStreak;
  }

  /// Computes weekly statistics for the 7 days ending on [asOfDate].
  /// Returns daily prayed counts (0 to 5 for each of the 7 days from oldest to newest)
  /// and total prayed/missed/qada counts.
  Future<Map<String, dynamic>> weeklyStats([DateTime? asOfDate]) async {
    final end = asOfDate ?? DateTime.now();
    final entries = await getAllEntries();

    var totalPrayed = 0;
    var totalMissed = 0;
    var totalQada = 0;
    final dailyPrayedCounts = <int>[];
    final dailyLabels = <String>[];

    // From 6 days ago to today (7 days chronological)
    for (var i = 6; i >= 0; i--) {
      final dt = end.subtract(Duration(days: i));
      final dateStr = formatDate(dt);
      dailyLabels.add(DateFormat('E').format(dt)); // e.g. Mon, Tue

      final dayEntries = entries.where((e) => e.date == dateStr).toList();
      var dayPrayed = 0;

      for (final e in dayEntries) {
        if (e.status == PrayerLogStatus.prayed) {
          dayPrayed++;
          totalPrayed++;
        } else if (e.status == PrayerLogStatus.missed) {
          totalMissed++;
        } else if (e.status == PrayerLogStatus.qada) {
          totalQada++;
        }
      }

      dailyPrayedCounts.add(dayPrayed);
    }

    return {
      'totalPrayed': totalPrayed,
      'totalMissed': totalMissed,
      'totalQada': totalQada,
      'dailyPrayedCounts': dailyPrayedCounts,
      'dailyLabels': dailyLabels,
    };
  }

  /// Computes monthly consistency percentage for the month of [asOfDate].
  /// Ratio = (total prayed this month) / (days elapsed in month * 5).
  /// Safely handles empty months (returns 0.0, avoiding division by zero).
  Future<double> monthlyConsistency([DateTime? asOfDate]) async {
    final target = asOfDate ?? DateTime.now();
    final entries = await getAllEntries();

    final daysElapsed = target.day;
    if (daysElapsed <= 0) return 0.0;

    final expectedPrayers = daysElapsed * 5;
    if (expectedPrayers <= 0) return 0.0;

    final yearMonthPrefix = DateFormat('yyyy-MM').format(target);
    final monthEntries = entries.where(
      (e) => e.date.startsWith(yearMonthPrefix) && e.status == PrayerLogStatus.prayed,
    );

    final actualPrayed = monthEntries.length;
    final ratio = actualPrayed / expectedPrayers;
    return ratio.clamp(0.0, 1.0);
  }
}
