/// Ayah Domain Model (Spec §3 M2)
class AyahModel {
  final int numberInSurah;
  final int numberInQuran;
  final int surahNumber;
  final String textUthmani;
  final String translationEnglish;
  final String translationUrdu;
  final int juz;
  final int page;
  final bool isBookmarked;

  const AyahModel({
    required this.numberInSurah,
    required this.numberInQuran,
    required this.surahNumber,
    required this.textUthmani,
    required this.translationEnglish,
    this.translationUrdu = '',
    this.juz = 1,
    this.page = 1,
    this.isBookmarked = false,
  });

  AyahModel copyWith({
    int? numberInSurah,
    int? numberInQuran,
    int? surahNumber,
    String? textUthmani,
    String? translationEnglish,
    String? translationUrdu,
    int? juz,
    int? page,
    bool? isBookmarked,
  }) {
    return AyahModel(
      numberInSurah: numberInSurah ?? this.numberInSurah,
      numberInQuran: numberInQuran ?? this.numberInQuran,
      surahNumber: surahNumber ?? this.surahNumber,
      textUthmani: textUthmani ?? this.textUthmani,
      translationEnglish: translationEnglish ?? this.translationEnglish,
      translationUrdu: translationUrdu ?? this.translationUrdu,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
