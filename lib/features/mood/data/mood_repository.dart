import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/mood/domain/models/mood_item.dart';

class MoodRepository {
  static const String assetPath = 'assets/mood/mood_dhikr.json';
  static const String storageKey = 'mood_v1';

  static List<MoodItem>? _cachedMoods;

  static void clearCacheForTesting() {
    _cachedMoods = null;
  }

  static String formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// Loads the 8 moods from bundled JSON
  Future<List<MoodItem>> getAllMoods({AssetBundle? bundle}) async {
    if (_cachedMoods != null) return _cachedMoods!;

    final b = bundle ?? rootBundle;
    final jsonString = await b.loadString(assetPath);
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final list = map['moods'] as List<dynamic>;

    final parsed = list
        .map((item) => MoodItem.fromJson(item as Map<String, dynamic>))
        .toList();

    _cachedMoods = parsed;
    return parsed;
  }

  /// Finds mood by English key name (case-insensitive)
  Future<MoodItem?> moodFor(String key, {AssetBundle? bundle}) async {
    final list = await getAllMoods(bundle: bundle);
    try {
      return list.firstWhere(
        (m) => m.moodEn.toLowerCase() == key.toLowerCase().trim(),
      );
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }

  /// Logs today's mood (one per day, overwritable)
  Future<void> logMood(String moodKey, [DateTime? date]) async {
    final prefs = await SharedPreferences.getInstance();
    final dt = date ?? DateTime.now();
    final dateKey = formatDate(dt);

    final raw = prefs.getString(storageKey);
    final map = raw != null && raw.isNotEmpty
        ? (json.decode(raw) as Map<String, dynamic>)
        : <String, dynamic>{};

    map[dateKey] = moodKey;
    await prefs.setString(storageKey, json.encode(map));
  }

  /// Gets the logged mood for a given date
  Future<String?> getLoggedMoodKey([DateTime? date]) async {
    final prefs = await SharedPreferences.getInstance();
    final dt = date ?? DateTime.now();
    final dateKey = formatDate(dt);

    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return map[dateKey] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Gets the full MoodItem logged for today
  Future<MoodItem?> getTodayMood([DateTime? date]) async {
    final key = await getLoggedMoodKey(date);
    if (key == null) return null;
    return moodFor(key);
  }
}
