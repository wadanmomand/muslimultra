import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_item.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_stats.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';

class HifzRepository {
  static const String storageKey = 'hifz_v1';
  static const List<int> intervals = [1, 3, 7, 14, 30, 60, 120];

  final SharedPreferences? prefs;
  final AssetBundle? bundle;

  // In-memory cache of Quran ayahs for rapid Arabic snippet lookup
  static Map<String, String>? _quranAyahCache;

  HifzRepository({
    this.prefs,
    this.bundle,
  });

  Future<SharedPreferences> _getPrefs() async {
    if (prefs != null) return prefs!;
    return await SharedPreferences.getInstance();
  }

  /// Loads all touched Hifz items from sparse SharedPreferences storage
  Future<Map<String, HifzItem>> getAllItems() async {
    try {
      final p = await _getPrefs();
      final raw = p.getString(storageKey);
      if (raw == null || raw.isEmpty) return {};

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};

      await _ensureQuranCacheLoaded();

      final result = <String, HifzItem>{};
      decoded.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          final parts = key.split(':');
          final surahNum = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 1 : 1;
          final ayahNum = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
          final arabic = _quranAyahCache?['$surahNum:$ayahNum'];
          final surahModel = TanzilQuranData.allSurahs.firstWhere(
            (s) => s.number == surahNum,
            orElse: () => TanzilQuranData.allSurahs.first,
          );

          result[key] = HifzItem.fromJson(
            key,
            val,
            arabicText: arabic,
            surahName: surahModel.name,
          );
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  /// Retrieves a single touched Hifz item, or creates a default new item if untouched
  Future<HifzItem?> getItem(int surahNumber, int ayahNumber) async {
    final all = await getAllItems();
    return all['$surahNumber:$ayahNumber'];
  }

  /// Sets the status of an Ayah explicitly (0=new, 1=learning, 2=memorized)
  Future<void> setStatus(int surahNumber, int ayahNumber, int status) async {
    final all = await getAllItems();
    final key = '$surahNumber:$ayahNumber';
    final existing = all[key];

    final updated = existing != null
        ? existing.copyWith(
            status: status,
            stability: status == 2 ? (existing.stability < 7 ? 7 : existing.stability) : (status == 1 ? 1 : 0),
            lastReviewed: DateTime.now(),
          )
        : HifzItem(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            status: status,
            stability: status == 2 ? 7 : 1,
            lastReviewed: DateTime.now(),
          );

    all[key] = updated;
    await _saveAllItems(all);
  }

  /// Reviews an Ayah with spaced repetition:
  /// - If remembered: stability advances to next in [1, 3, 7, 14, 30, 60, 120]
  /// - If forgotten: stability resets to 1, status drops back to 1 (learning)
  Future<HifzItem> review(int surahNumber, int ayahNumber, bool remembered) async {
    final all = await getAllItems();
    final key = '$surahNumber:$ayahNumber';
    final existing = all[key] ??
        HifzItem(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          status: 1,
          stability: 1,
          lastReviewed: DateTime.now(),
        );

    final HifzItem updated;
    if (remembered) {
      final currentStability = existing.stability;
      final currentIdx = intervals.indexOf(currentStability);
      final nextStability = currentIdx >= 0 && currentIdx < intervals.length - 1
          ? intervals[currentIdx + 1]
          : (currentIdx >= 0 ? intervals.last : _findNextInterval(currentStability));

      final newStatus = nextStability >= 7 ? 2 : existing.status;
      updated = existing.copyWith(
        stability: nextStability,
        status: newStatus,
        lastReviewed: DateTime.now(),
      );
    } else {
      updated = existing.copyWith(
        stability: 1,
        status: 1, // Drops back to learning
        lastReviewed: DateTime.now(),
      );
    }

    all[key] = updated;
    await _saveAllItems(all);
    return updated;
  }

  int _findNextInterval(int current) {
    for (final interval in intervals) {
      if (interval > current) return interval;
    }
    return intervals.last;
  }

  /// Starts a new lesson range (Sabq) marking all ayat in the range as learning (status 1)
  Future<void> startLesson(int surahNumber, int fromAyah, int toAyah) async {
    final all = await getAllItems();
    final now = DateTime.now();

    for (int ayah = fromAyah; ayah <= toAyah; ayah++) {
      final key = '$surahNumber:$ayah';
      all[key] = HifzItem(
        surahNumber: surahNumber,
        ayahNumber: ayah,
        status: 1, // Learning
        stability: 1,
        lastReviewed: now,
      );
    }

    await _saveAllItems(all);
  }

  /// Returns items due today or overdue, sorted by due date ascending
  Future<List<HifzItem>> getDueTodayItems() async {
    final all = await getAllItems();
    final dueItems = all.values.where((item) => item.status > 0 && item.isDue).toList();
    dueItems.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return dueItems;
  }

  /// Returns Sabq items (actively learning, status == 1)
  Future<List<HifzItem>> getSabqItems() async {
    final all = await getAllItems();
    final items = all.values.where((item) => item.status == 1).toList();
    items.sort((a, b) {
      if (a.surahNumber != b.surahNumber) return a.surahNumber.compareTo(b.surahNumber);
      return a.ayahNumber.compareTo(b.ayahNumber);
    });
    return items;
  }

  /// Returns Sabqi items (recent review: touched with stability < 14)
  Future<List<HifzItem>> getSabqiItems() async {
    final all = await getAllItems();
    final items = all.values.where((item) => item.status > 0 && item.stability < 14).toList();
    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  /// Returns Manzil items (solid memorized: status == 2 with stability >= 14)
  Future<List<HifzItem>> getManzilItems() async {
    final all = await getAllItems();
    final items = all.values.where((item) => item.status == 2 && item.stability >= 14).toList();
    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  /// Computes memorization statistics & streak
  Future<HifzStats> getStats() async {
    final all = await getAllItems();
    var memorized = 0;
    var learning = 0;
    var due = 0;

    final reviewDates = <String>{};

    for (final item in all.values) {
      if (item.status == 2) memorized++;
      if (item.status == 1) learning++;
      if (item.status > 0 && item.isDue) due++;

      final y = item.lastReviewed.year.toString().padLeft(4, '0');
      final m = item.lastReviewed.month.toString().padLeft(2, '0');
      final d = item.lastReviewed.day.toString().padLeft(2, '0');
      reviewDates.add('$y-$m-$d');
    }

    // Calculate streak days
    final streak = _calculateStreak(reviewDates);

    return HifzStats(
      memorizedCount: memorized,
      learningCount: learning,
      dueCount: due,
      streakDays: streak,
    );
  }

  int _calculateStreak(Set<String> reviewDates) {
    if (reviewDates.isEmpty) return 0;

    var streak = 0;
    var checkDate = DateTime.now();

    while (true) {
      final y = checkDate.year.toString().padLeft(4, '0');
      final m = checkDate.month.toString().padLeft(2, '0');
      final d = checkDate.day.toString().padLeft(2, '0');
      final key = '$y-$m-$d';

      if (reviewDates.contains(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Allow streak to continue if today hasn't been reviewed yet but yesterday was
        if (streak == 0) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          final yPrev = checkDate.year.toString().padLeft(4, '0');
          final mPrev = checkDate.month.toString().padLeft(2, '0');
          final dPrev = checkDate.day.toString().padLeft(2, '0');
          if (reviewDates.contains('$yPrev-$mPrev-$dPrev')) {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
            continue;
          }
        }
        break;
      }
    }
    return streak;
  }

  Future<void> _saveAllItems(Map<String, HifzItem> items) async {
    try {
      final p = await _getPrefs();
      final mapData = <String, dynamic>{};
      items.forEach((k, v) {
        mapData[k] = v.toJson();
      });
      await p.setString(storageKey, jsonEncode(mapData));
    } catch (_) {}
  }

  Future<void> _ensureQuranCacheLoaded() async {
    if (_quranAyahCache != null) return;

    try {
      final b = bundle ?? rootBundle;
      final jsonStr = await b.loadString('assets/quran/quran_full.json');
      final dynamic decoded = jsonDecode(jsonStr);

      if (decoded is Map<String, dynamic> && decoded['surahs'] is List) {
        final cache = <String, String>{};
        for (final s in decoded['surahs'] as List) {
          if (s is Map<String, dynamic>) {
            final surahNum = (s['number'] as num?)?.toInt() ?? 1;
            final ayahs = s['ayahs'] as List?;
            if (ayahs != null) {
              for (final a in ayahs) {
                if (a is Map<String, dynamic>) {
                  final ayahNum = (a['numberInSurah'] as num?)?.toInt() ?? 1;
                  final text = a['text']?.toString() ?? a['textUthmani']?.toString() ?? '';
                  cache['$surahNum:$ayahNum'] = text;
                }
              }
            }
          }
        }
        _quranAyahCache = cache;
      }
    } catch (_) {
      _quranAyahCache = {};
    }
  }

  /// Helper for testing to inject custom Quran cache
  static void setMockQuranCacheForTesting(Map<String, String> cache) {
    _quranAyahCache = cache;
  }

  /// Helper for testing to clear cache
  static void clearCacheForTesting() {
    _quranAyahCache = null;
  }
}
