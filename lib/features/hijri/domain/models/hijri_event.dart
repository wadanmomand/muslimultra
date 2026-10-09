/// Domain model for an Islamic Event or observance
class HijriEvent {
  final String id;
  final int hijriMonth;
  final int hijriDay;
  final String nameEn;
  final String nameAr;
  final String nameUr;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionUr;
  final bool isMajor;
  final bool isNewMonthMarker;

  const HijriEvent({
    required this.id,
    required this.hijriMonth,
    required this.hijriDay,
    required this.nameEn,
    required this.nameAr,
    required this.nameUr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionUr,
    this.isMajor = false,
    this.isNewMonthMarker = false,
  });

  String localizedName(String langCode) {
    if (langCode.startsWith('ar')) return nameAr;
    if (langCode.startsWith('ur')) return nameUr;
    return nameEn;
  }

  String localizedDescription(String langCode) {
    if (langCode.startsWith('ar')) return descriptionAr;
    if (langCode.startsWith('ur')) return descriptionUr;
    return descriptionEn;
  }
}
