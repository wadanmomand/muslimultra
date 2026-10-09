/// Classical Trilingual Tafsir entry for a single Ayah
class TafsirEntry {
  final String key;
  final int surah;
  final int ayah;
  final String en;
  final String ar;
  final String ur;

  const TafsirEntry({
    required this.key,
    required this.surah,
    required this.ayah,
    required this.en,
    required this.ar,
    required this.ur,
  });

  factory TafsirEntry.fromJson(Map<String, dynamic> json) {
    if (json['surah'] == null || json['ayah'] == null || json['en'] == null) {
      throw const FormatException('Missing required fields for TafsirEntry');
    }
    return TafsirEntry(
      key: json['key'] as String? ?? '${json['surah']}:${json['ayah']}',
      surah: json['surah'] is int ? json['surah'] as int : int.parse(json['surah'].toString()),
      ayah: json['ayah'] is int ? json['ayah'] as int : int.parse(json['ayah'].toString()),
      en: json['en'] as String? ?? '',
      ar: json['ar'] as String? ?? '',
      ur: json['ur'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'surah': surah,
      'ayah': ayah,
      'en': en,
      'ar': ar,
      'ur': ur,
    };
  }

  /// Whether classical Arabic commentary is available for this verse
  bool get hasArabic => ar.trim().isNotEmpty;

  /// Whether Urdu commentary (Bayan-ul-Quran) is available
  bool get hasUrdu => ur.trim().isNotEmpty;
}
