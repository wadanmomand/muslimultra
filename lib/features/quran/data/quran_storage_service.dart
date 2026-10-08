import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuranStorageService {
  static const String _keyLastSurah = 'quran_last_read_surah';
  static const String _keyLastAyah = 'quran_last_read_ayah';
  static const String _keyArabicFontSize = 'quran_arabic_font_size';
  static const String _keyTranslationFontSize = 'quran_translation_font_size';
  static const String _keyBookmarks = 'quran_bookmarks_list';
  static const String _keySelectedReciter = 'quran_selected_reciter_id';
  static const String _keySelectedTranslation = 'quran_selected_translation_code';
  static const String _keyReadingMode = 'quran_reading_mode';
  static const String _keyRepeatMode = 'quran_repeat_mode';
  static const String _keyPlaybackSpeed = 'quran_playback_speed';

  /// Save Quran Repeat Mode ('off', 'ayah', 'surah')
  static Future<void> saveRepeatMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRepeatMode, mode);
  }

  /// Load Quran Repeat Mode (defaults to 'off')
  static Future<String> loadRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRepeatMode) ?? 'off';
  }

  /// Save Quran Playback Speed
  static Future<void> savePlaybackSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyPlaybackSpeed, speed);
  }

  /// Load Quran Playback Speed (defaults to 1.0)
  static Future<double> loadPlaybackSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyPlaybackSpeed) ?? 1.0;
  }

  /// Save Quran Reading Mode ('translation' or 'mushaf')
  static Future<void> saveReadingMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReadingMode, mode);
  }

  /// Load Quran Reading Mode (defaults to 'translation')
  static Future<String> loadReadingMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReadingMode) ?? 'translation';
  }

  /// Save Selected Translation code (e.g. en.sahih or ur.jalandhry)
  static Future<void> saveTranslationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTranslation, code);
  }

  /// Load Selected Translation code
  static Future<String> loadTranslationCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedTranslation) ?? 'en.sahih';
  }

  /// Save last read position (Continue Reading)
  static Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSurah, surahNumber);
    await prefs.setInt(_keyLastAyah, ayahNumber);
  }

  /// Get last read position (defaults to Surah Al-Fatihah, Ayah 1)
  static Future<Map<String, int>> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getInt(_keyLastSurah) ?? 1;
    final a = prefs.getInt(_keyLastAyah) ?? 1;
    return {'surah': s, 'ayah': a};
  }

  /// Save Font Sizes
  static Future<void> saveFontSizes(double arabic, double translation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyArabicFontSize, arabic);
    await prefs.setDouble(_keyTranslationFontSize, translation);
  }

  /// Load Font Sizes
  static Future<Map<String, double>> loadFontSizes() async {
    final prefs = await SharedPreferences.getInstance();
    final a = prefs.getDouble(_keyArabicFontSize) ?? 24.0;
    final t = prefs.getDouble(_keyTranslationFontSize) ?? 14.0;
    return {'arabic': a, 'translation': t};
  }

  /// Toggle Bookmark
  static Future<List<String>> toggleBookmark(int surahNumber, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$surahNumber:$ayahNumber';
    List<String> bookmarks = prefs.getStringList(_keyBookmarks) ?? [];

    if (bookmarks.contains(key)) {
      bookmarks.remove(key);
    } else {
      bookmarks.add(key);
    }

    await prefs.setStringList(_keyBookmarks, bookmarks);
    return bookmarks;
  }

  /// Load Bookmarks
  static Future<List<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyBookmarks) ?? [];
  }

  /// Save Selected Reciter ID
  static Future<void> saveReciterId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedReciter, id);
  }

  /// Load Selected Reciter ID
  static Future<String> loadReciterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedReciter) ?? 'alafasy';
  }

  /// Save Cache of downloaded Surahs (for offline full text)
  static Future<void> cacheSurahData(int surahNumber, String edition, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_surah_${surahNumber}_$edition', json.encode(data));
  }

  /// Read Cache of downloaded Surah
  static Future<Map<String, dynamic>?> getCachedSurahData(int surahNumber, String edition) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cache_surah_${surahNumber}_$edition');
    if (raw != null) {
      return json.decode(raw) as Map<String, dynamic>;
    }
    return null;
  }
}
