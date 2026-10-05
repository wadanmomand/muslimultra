/// EveryAyah CDN Audio URL Builder (Spec §3 M2)
/// Pattern: https://everyayah.com/data/{reciter_subpath}/{surah_3_digits}{ayah_3_digits}.mp3
class AudioUrlBuilder {
  static const String cdnBaseUrl = 'https://everyayah.com/data';

  /// Builds the 3-digit padded filename (e.g. Surah 1, Ayah 1 -> "001001.mp3", Surah 2, Ayah 10 -> "002010.mp3")
  static String buildFilename(int surahNumber, int ayahNumber) {
    final sStr = surahNumber.toString().padLeft(3, '0');
    final aStr = ayahNumber.toString().padLeft(3, '0');
    return '$sStr$aStr.mp3';
  }

  /// Builds the complete EveryAyah CDN URL
  static String buildAyahAudioUrl({
    required String reciterSubpath,
    required int surahNumber,
    required int ayahNumber,
  }) {
    final filename = buildFilename(surahNumber, ayahNumber);
    return '$cdnBaseUrl/$reciterSubpath/$filename';
  }
}
