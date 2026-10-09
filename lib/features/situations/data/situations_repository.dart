import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/situations/domain/models/situation.dart';

class SituationsLoadException implements Exception {
  final String message;
  final dynamic cause;

  const SituationsLoadException(this.message, [this.cause]);

  @override
  String toString() => 'SituationsLoadException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class SituationsRepository {
  static const String bundlePath = 'assets/situations/situations.json';
  static const String quranBundlePath = 'assets/quran/quran_full.json';

  List<SituationModel>? _cachedSituations;
  Map<String, AyahModel>? _cachedAyatMap;

  static void clearCacheForTesting() {
    _instance = null;
  }

  static SituationsRepository? _instance;
  factory SituationsRepository() => _instance ??= SituationsRepository._internal();
  SituationsRepository._internal();

  /// Loads all 8 situations from the verified bundle
  Future<List<SituationModel>> getAllSituations({AssetBundle? bundle}) async {
    if (_cachedSituations != null) {
      return _cachedSituations!;
    }

    final assetBundle = bundle ?? rootBundle;
    try {
      final jsonString = await assetBundle.loadString(bundlePath);
      final decoded = json.decode(jsonString);

      if (decoded is! Map || !decoded.containsKey('situations')) {
        throw const FormatException('Expected JSON map with "situations" key');
      }

      final rawList = decoded['situations'];
      if (rawList is! List) {
        throw const FormatException('Expected "situations" to be a List');
      }

      final situations = rawList
          .map((item) => SituationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _cachedSituations = situations;
      return situations;
    } catch (e, st) {
      throw SituationsLoadException('Failed to load situations bundle: $e', st);
    }
  }

  /// Gets a specific situation by id
  Future<SituationModel?> getSituationById(String id, {AssetBundle? bundle}) async {
    final list = await getAllSituations(bundle: bundle);
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Resolves an authentic AyahModel from bundled Quran full json
  Future<AyahModel?> resolveAyah(int surahNumber, int ayahNumber, {AssetBundle? bundle}) async {
    if (_cachedAyatMap == null) {
      final assetBundle = bundle ?? rootBundle;
      try {
        final quranJsonStr = await assetBundle.loadString(quranBundlePath);
        final quranDecoded = json.decode(quranJsonStr) as Map<String, dynamic>;
        final surahsList = quranDecoded['surahs'] as List<dynamic>;

        final map = <String, AyahModel>{};
        for (final s in surahsList) {
          final sMap = s as Map<String, dynamic>;
          final sNum = sMap['number'] as int;
          final ayahsList = sMap['ayahs'] as List<dynamic>;

          for (final a in ayahsList) {
            final aMap = a as Map<String, dynamic>;
            final aNum = aMap['numberInSurah'] as int;
            final key = '$sNum:$aNum';

            map[key] = AyahModel(
              surahNumber: sNum,
              numberInSurah: aNum,
              numberInQuran: (aMap['number'] as num?)?.toInt() ?? 0,
              juz: (aMap['juz'] as num?)?.toInt() ?? 1,
              page: (aMap['page'] as num?)?.toInt() ?? 1,
              textUthmani: (aMap['text'] as String?) ?? '',
              translationEnglish: (aMap['translation_en'] as String?) ?? '',
              translationUrdu: (aMap['translation_ur'] as String?) ?? '',
            );
          }
        }
        _cachedAyatMap = map;
      } catch (_) {
        return null;
      }
    }

    return _cachedAyatMap?['$surahNumber:$ayahNumber'];
  }
}
