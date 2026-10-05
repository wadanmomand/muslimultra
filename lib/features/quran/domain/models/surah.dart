/// Surah Domain Model (Spec §3 M2)
class SurahModel {
  final int number;
  final String name; // Arabic Name (e.g. الفاتحة)
  final String englishName; // Transliteration (e.g. Al-Fatihah)
  final String englishNameTranslation; // Translation (e.g. The Opening)
  final int numberOfAyahs;
  final String revelationType; // Meccan / Medinan
  final int startJuz;

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.startJuz = 1,
  });
}
