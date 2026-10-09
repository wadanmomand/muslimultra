/// Hijri Date Domain Model
class HijriDate {
  final int year;
  final int month;
  final int day;
  final String monthNameEn;
  final String monthNameAr;
  final String? monthNameUr;
  final String dayOfWeek;
  final int offsetApplied;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthNameEn,
    required this.monthNameAr,
    this.monthNameUr,
    required this.dayOfWeek,
    this.offsetApplied = 0,
  });

  static const List<String> monthsEn = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah',
  ];

  static const List<String> monthsAr = [
    'محرّم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوّال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<String> monthsUr = [
    'محرم',
    'صفر',
    'ربیع الاول',
    'ربیع الثانی',
    'جمادی الاولی',
    'جمادی الثانیہ',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذوالقعدہ',
    'ذوالحجہ',
  ];

  String formattedEn() => '$day $monthNameEn $year AH';
  String formattedAr() => '$day $monthNameAr $year هـ';
  String formattedUr() => '$day ${monthNameUr ?? monthsUr[(month - 1).clamp(0, 11)]} $year ھ';
}
