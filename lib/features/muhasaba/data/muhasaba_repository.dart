import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/muhasaba/domain/models/muhasaba_questions.dart';

class MuhasabaLoadException implements Exception {
  final String message;
  final dynamic cause;

  const MuhasabaLoadException(this.message, [this.cause]);

  @override
  String toString() => 'MuhasabaLoadException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class MuhasabaRepository {
  static const String keyMuhasabaStorage = 'muhasaba_v1';

  final SharedPreferences? prefs;

  MuhasabaRepository({this.prefs});

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  /// Internal helper to load all stored entries map
  Future<Map<String, MuhasabaEntry>> _loadAllEntries() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(keyMuhasabaStorage);
    if (rawJson == null || rawJson.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = json.decode(rawJson);
      if (decoded is! Map) {
        throw const FormatException('Expected JSON Map at root of muhasaba storage');
      }

      final result = <String, MuhasabaEntry>{};
      for (final entry in decoded.entries) {
        final dateKey = entry.key.toString();
        if (entry.value is! Map) {
          throw FormatException('Invalid entry for date $dateKey: expected Map');
        }
        final entryMap = Map<String, dynamic>.from(entry.value as Map);
        result[dateKey] = MuhasabaEntry.fromJson(entryMap);
      }
      return result;
    } catch (e, st) {
      debugPrint('MuhasabaRepository: Failed to parse stored entries: $e\n$st');
      throw MuhasabaLoadException('Failed to load Muhasaba entries', e);
    }
  }

  /// Saves a single day's reflection
  Future<void> saveEntry(String date, Map<String, int?> answers) async {
    final prefs = await _getPrefs();
    Map<String, MuhasabaEntry> allEntries;
    try {
      allEntries = await _loadAllEntries();
    } catch (_) {
      allEntries = {};
    }

    final sanitizedAnswers = <String, int?>{};
    for (final q in MuhasabaQuestions.list) {
      final val = answers[q.id];
      if (val == 0 || val == 1 || val == 2) {
        sanitizedAnswers[q.id] = val;
      } else {
        sanitizedAnswers[q.id] = null;
      }
    }

    allEntries[date] = MuhasabaEntry(
      date: date,
      answers: sanitizedAnswers,
    );

    final encoded = json.encode({
      for (final e in allEntries.entries) e.key: e.value.toJson(),
    });

    await prefs.setString(keyMuhasabaStorage, encoded);
  }

  /// Retrieves entry for a specific date (yyyy-MM-dd)
  Future<MuhasabaEntry?> getEntry(String date) async {
    final allEntries = await _loadAllEntries();
    return allEntries[date];
  }

  /// Returns entries for the last 7 days ending at [referenceDate] (or today)
  /// Index 0 is referenceDate - 6 days, Index 6 is referenceDate
  Future<List<MuhasabaEntry?>> getWeekEntries([DateTime? referenceDate]) async {
    final allEntries = await _loadAllEntries();
    final ref = referenceDate ?? DateTime.now();

    final list = <MuhasabaEntry?>[];
    for (int i = 6; i >= 0; i--) {
      final day = ref.subtract(Duration(days: i));
      final dateKey = formatDate(day);
      list.add(allEntries[dateKey]);
    }
    return list;
  }

  /// Returns entries for the last 14 days ending at [referenceDate] (or today)
  /// Index 0 is referenceDate (Today), Index 13 is referenceDate - 13 days
  Future<List<MapEntry<DateTime, MuhasabaEntry?>>> getLast14Days([DateTime? referenceDate]) async {
    final allEntries = await _loadAllEntries();
    final ref = referenceDate ?? DateTime.now();

    final list = <MapEntry<DateTime, MuhasabaEntry?>>[];
    for (int i = 0; i < 14; i++) {
      final day = ref.subtract(Duration(days: i));
      final dateKey = formatDate(day);
      list.add(MapEntry(day, allEntries[dateKey]));
    }
    return list;
  }

  /// Calculates consecutive completion streak (consecutive days with all 6 answered)
  /// Informational only, never shaming.
  Future<int> completionStreak([DateTime? referenceDate]) async {
    final allEntries = await _loadAllEntries();
    final now = referenceDate ?? DateTime.now();

    int streak = 0;
    DateTime checkDate = now;

    // Check if today is completed
    final todayKey = formatDate(checkDate);
    final todayEntry = allEntries[todayKey];

    if (todayEntry != null && todayEntry.isCompleted) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // Check if yesterday was completed to avoid resetting streak before night reflection
      final yesterday = checkDate.subtract(const Duration(days: 1));
      final yesterdayKey = formatDate(yesterday);
      final yesterdayEntry = allEntries[yesterdayKey];
      if (yesterdayEntry != null && yesterdayEntry.isCompleted) {
        checkDate = yesterday;
      } else {
        return 0;
      }
    }

    while (true) {
      final dateKey = formatDate(checkDate);
      final entry = allEntries[dateKey];
      if (entry != null && entry.isCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Helper to format DateTime as yyyy-MM-dd
  static String formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
