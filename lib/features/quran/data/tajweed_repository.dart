import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:muslim_ultra/features/quran/domain/models/tajweed_rule.dart';

class TajweedRepository {
  static Map<int, Map<int, List<TajweedAnnotation>>>? _cachedTajweed;

  /// Loads and caches all tajweed annotations from bundled JSON
  Future<Map<int, Map<int, List<TajweedAnnotation>>>> loadTajweedData() async {
    if (_cachedTajweed != null) {
      return _cachedTajweed!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/tajweed/tajweed.json');
      final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
      final List<dynamic> ayahsRaw = data['ayahs'] as List<dynamic>;

      final Map<int, Map<int, List<TajweedAnnotation>>> map = {};

      for (final item in ayahsRaw) {
        final List<dynamic> tuple = item as List<dynamic>;
        final int surah = tuple[0] as int;
        final int ayah = tuple[1] as int;
        final List<dynamic> annotationsRaw = tuple[2] as List<dynamic>;

        final List<TajweedAnnotation> annotations = annotationsRaw.map((a) {
          return TajweedAnnotation.fromRawTuple(a as List<dynamic>);
        }).toList();

        map.putIfAbsent(surah, () => {})[ayah] = annotations;
      }

      _cachedTajweed = map;
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Get annotations for a specific Surah
  Future<Map<int, List<TajweedAnnotation>>> getSurahAnnotations(int surahNumber) async {
    final all = await loadTajweedData();
    return all[surahNumber] ?? const {};
  }

  /// Synchronous retrieval if cache is already loaded
  List<TajweedAnnotation>? getAyahAnnotationsSync(int surahNumber, int ayahNumber) {
    return _cachedTajweed?[surahNumber]?[ayahNumber];
  }

  /// Clears cache (useful for testing)
  static void clearCacheForTesting() {
    _cachedTajweed = null;
  }
}
