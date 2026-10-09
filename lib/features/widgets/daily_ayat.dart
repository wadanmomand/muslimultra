import 'dart:convert';
import 'package:flutter/services.dart';

/// Reference to a specific Ayah in the Quran (Surah number, Ayah number in surah)
class DailyAyahRef {
  final int surah;
  final int ayah;

  const DailyAyahRef(this.surah, this.ayah);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyAyahRef &&
          runtimeType == other.runtimeType &&
          surah == other.surah &&
          ayah == other.ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => '$surah:$ayah';
}

/// Resolved Ayah content matching the bundled offline Quran exactly
class ResolvedDailyAyah {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String arabic;
  final String english;
  final String urdu;

  const ResolvedDailyAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.arabic,
    required this.english,
    required this.urdu,
  });

  String get referenceText => 'Surah $surahNumber:$ayahNumber';
}

/// Curated deterministic daily Ayah rotation for Home-Screen Widgets and Daily Inspiration
class DailyAyatService {
  static const String quranAssetPath = 'assets/quran/quran_full.json';
  static Map<String, dynamic>? _cachedQuranJson;

  /// Curated collection of 30 short, hopeful, and foundational Quranic verses
  static const List<DailyAyahRef> curated30 = [
    DailyAyahRef(1, 2),   // All praise is due to Allah, Lord of the worlds
    DailyAyahRef(2, 152), // So remember Me; I will remember you
    DailyAyahRef(2, 186), // And when My servants ask you concerning Me, indeed I am near
    DailyAyahRef(2, 286), // Allah does not charge a soul except with that within its capacity
    DailyAyahRef(3, 139), // So do not weaken and do not grieve, and you will be superior if you are [true] believers
    DailyAyahRef(3, 159), // Indeed, Allah loves those who rely [upon Him]
    DailyAyahRef(3, 200), // O you who have believed, persevere and endure and remain stationed and fear Allah
    DailyAyahRef(6, 162), // Say, "Indeed, my prayer, my rites of sacrifice, my living and my dying are for Allah"
    DailyAyahRef(7, 199), // Take what is given freely, enjoin what is good, and turn away from the ignorant
    DailyAyahRef(9, 51),  // Say, "Never will we be struck except by what Allah has decreed for us"
    DailyAyahRef(10, 62), // Unquestionably, [for] the allies of Allah there will be no fear concerning them
    DailyAyahRef(13, 28), // Unquestionably, by the remembrance of Allah hearts are assured
    DailyAyahRef(14, 7),  // If you are grateful, I will surely increase you [in favor]
    DailyAyahRef(16, 90), // Indeed, Allah orders justice and good conduct and giving to relatives
    DailyAyahRef(16, 128),// Indeed, Allah is with those who fear Him and those who are doers of good
    DailyAyahRef(21, 87), // There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers
    DailyAyahRef(24, 35), // Allah is the Light of the heavens and the earth
    DailyAyahRef(25, 63), // And the servants of the Most Merciful are those who walk upon the earth easily
    DailyAyahRef(29, 69), // And those who strive for Us - We will surely guide them to Our ways
    DailyAyahRef(39, 53), // Say, "O My servants who have transgressed against themselves, do not despair of the mercy of Allah"
    DailyAyahRef(40, 60), // And your Lord says, "Call upon Me; I will respond to you"
    DailyAyahRef(49, 13), // Indeed, the most noble of you in the sight of Allah is the most righteous of you
    DailyAyahRef(55, 60), // Is the reward for good [anything] but good?
    DailyAyahRef(65, 2),  // And whoever fears Allah - He will make for him a way out
    DailyAyahRef(65, 3),  // And will provide for him from where he does not expect
    DailyAyahRef(93, 3),  // Your Lord has not taken leave of you, [O Muhammad], nor has He detested [you]
    DailyAyahRef(93, 5),  // And your Lord is going to give you, and you will be satisfied
    DailyAyahRef(94, 5),  // For indeed, with hardship [will be] ease
    DailyAyahRef(94, 6),  // Indeed, with hardship [will be] ease
    DailyAyahRef(103, 3), // Except for those who have believed and done righteous deeds and advised each other to truth
  ];

  /// Returns the deterministic Ayah reference for a given date.
  /// (Cycles through the 30 curated ayat without repeat within any 30-day window).
  static DailyAyahRef getRefForDate(DateTime date) {
    // Date-only UTC representation prevents local hour/DST offsets from skewing day count
    final dateOnly = DateTime.utc(date.year, date.month, date.day);
    final baseDate = DateTime.utc(2026, 1, 1);
    final days = dateOnly.difference(baseDate).inDays;
    final index = (days % curated30.length + curated30.length) % curated30.length;
    return curated30[index];
  }

  /// Clears in-memory cache for tests
  static void clearCacheForTesting() {
    _cachedQuranJson = null;
  }

  /// Resolves the Ayah reference against the bundled offline Quran
  static Future<ResolvedDailyAyah> resolveAyah(
    DailyAyahRef ref, {
    AssetBundle? bundle,
  }) async {
    Map<String, dynamic> quranMap;
    if (_cachedQuranJson != null) {
      quranMap = _cachedQuranJson!;
    } else {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(quranAssetPath);
      quranMap = json.decode(jsonString) as Map<String, dynamic>;
      _cachedQuranJson = quranMap;
    }

    final surahs = quranMap['surahs'] as List<dynamic>;
    final surahObj = surahs.firstWhere(
      (s) => (s as Map<String, dynamic>)['number'] == ref.surah,
      orElse: () => throw Exception('Surah #${ref.surah} not found in offline bundle'),
    ) as Map<String, dynamic>;

    final ayahs = surahObj['ayahs'] as List<dynamic>;
    final ayahObj = ayahs.firstWhere(
      (a) => (a as Map<String, dynamic>)['n'] == ref.ayah,
      orElse: () => throw Exception('Ayah #${ref.ayah} in Surah #${ref.surah} not found in bundle'),
    ) as Map<String, dynamic>;

    var rawArabic = (ayahObj['t'] as String?)?.trim() ?? '';
    // Strip leading BOM or zero-width non-breaking space if present
    if (rawArabic.startsWith('\uFEFF') || rawArabic.startsWith('\u200B')) {
      rawArabic = rawArabic.substring(1).trim();
    }

    return ResolvedDailyAyah(
      surahNumber: ref.surah,
      ayahNumber: ref.ayah,
      surahName: (surahObj['name'] as String?)?.trim() ?? '',
      arabic: rawArabic,
      english: (ayahObj['en'] as String?)?.trim() ?? '',
      urdu: (ayahObj['ur'] as String?)?.trim() ?? '',
    );
  }
}
