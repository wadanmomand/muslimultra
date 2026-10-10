class ScholarKeywords {
  /// English keywords requiring qualified scholar advisory
  static const List<String> keywordsEn = [
    'talaq',
    'divorce',
    'khula',
    'khul',
    'iddah',
    'inheritance',
    'wirasa',
    'mirath',
    'estate division',
    'shares of inheritance',
    'fatwa',
    'fatawa',
    'halal or haram',
    'is it halal',
    'is it haram',
    'is this halal',
    'is this haram',
    'is eating',
    'ruling on',
    'hukm',
  ];

  /// Arabic keywords requiring qualified scholar advisory
  static const List<String> keywordsAr = [
    'طلاق',
    'خلع',
    'تفريق',
    'فسخ',
    'عدة',
    'وراثة',
    'ميراث',
    'وارث',
    'تركة',
    'تقسيم الميراث',
    'فتوى',
    'فتاوى',
    'حلال أم حرام',
    'حلال ام حرام',
    'حكم الشرع',
    'ما حكم',
    'هل يجوز',
    'هل يحرم',
    'حرام أم حلال',
  ];

  /// Urdu keywords requiring qualified scholar advisory
  static const List<String> keywordsUr = [
    'طلاق',
    'خلع',
    'تفریق',
    'عدت',
    'وراثت',
    'میراث',
    'ترکہ',
    'ورثاء',
    'تقسیم جائیداد',
    'فتویٰ',
    'فتوی',
    'حلال ہے یا حرام',
    'حرام ہے یا حلال',
    'شرعی حکم',
    'کیا یہ حلال ہے',
    'کیا یہ حرام ہے',
    'جائز ہے یا ناجائز',
  ];

  /// Checks if [query] contains any scholar referral keywords in EN/AR/UR
  static bool matches(String query) {
    final normalized = query.toLowerCase().trim();
    if (normalized.isEmpty) return false;

    for (final kw in [...keywordsEn, ...keywordsAr, ...keywordsUr]) {
      if (normalized.contains(kw.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}
