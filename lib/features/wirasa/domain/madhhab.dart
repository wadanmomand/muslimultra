enum FiqhMadhhab {
  hanafi,
  maliki,
  shafii,
  hanbali,
}

class MadhhabDetails {
  final FiqhMadhhab madhhab;
  final String nameEn;
  final String nameAr;
  final String nameUr;
  final String imamNameEn;
  final String imamNameAr;
  final String imamNameUr;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionUr;

  const MadhhabDetails({
    required this.madhhab,
    required this.nameEn,
    required this.nameAr,
    required this.nameUr,
    required this.imamNameEn,
    required this.imamNameAr,
    required this.imamNameUr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionUr,
  });

  String localizedName(String lang) {
    switch (lang) {
      case 'ar':
        return nameAr;
      case 'ur':
        return nameUr;
      default:
        return nameEn;
    }
  }

  String localizedImam(String lang) {
    switch (lang) {
      case 'ar':
        return imamNameAr;
      case 'ur':
        return imamNameUr;
      default:
        return imamNameEn;
    }
  }

  String localizedDescription(String lang) {
    switch (lang) {
      case 'ar':
        return descriptionAr;
      case 'ur':
        return descriptionUr;
      default:
        return descriptionEn;
    }
  }

  static const List<MadhhabDetails> all = [
    MadhhabDetails(
      madhhab: FiqhMadhhab.hanafi,
      nameEn: 'Hanafi',
      nameAr: 'الحنفي',
      nameUr: 'حنفی',
      imamNameEn: 'Imam Abu Hanifa (Nu\'man ibn Thabit)',
      imamNameAr: 'الإمام أبو حنيفة (النعمان بن ثابت)',
      imamNameUr: 'امام ابو حنیفہ (نعمان بن ثابت)',
      descriptionEn: 'Grandfather excludes brothers. Standard Radd to non-spouse heirs.',
      descriptionAr: 'الجد يحجب الإخوة تماماً كالأب. الرد على أصحاب الفروض عدا الزوجين.',
      descriptionUr: 'دادا بھائیوں کو محروم کرتا ہے۔ میاں بیوی کے علاوہ دیگر ورثہ پر رد۔',
    ),
    MadhhabDetails(
      madhhab: FiqhMadhhab.maliki,
      nameEn: 'Maliki',
      nameAr: 'المالكي',
      nameUr: 'مالکی',
      imamNameEn: 'Imam Malik ibn Anas',
      imamNameAr: 'الإمام مالك بن أنس',
      imamNameUr: 'امام مالک بن انس',
      descriptionEn: 'Grandfather shares with brothers (Muqasama). Classical Bayt al-Mal rules.',
      descriptionAr: 'الجد يقاسم الإخوة الأشقاء واللأب. أحكام بيت المال الكلاسيكية.',
      descriptionUr: 'دادا حقیقی اور علاتی بھائیوں کے ساتھ وراثت میں شریک ہوتا ہے۔',
    ),
    MadhhabDetails(
      madhhab: FiqhMadhhab.shafii,
      nameEn: 'Shafi\'i',
      nameAr: 'الشافعي',
      nameUr: 'شافعی',
      imamNameEn: 'Imam al-Shafi\'i (Muhammad ibn Idris)',
      imamNameAr: 'الإمام الشافعي (محمد بن إدريس)',
      imamNameUr: 'امام شافعی (محمد بن ادریس)',
      descriptionEn: 'Grandfather shares with brothers (Muqasama / minimum 1/3). Radd applied in later fatwa.',
      descriptionAr: 'الجد يقاسم الإخوة (المقاسمة أو ثلث التركة). الرد معمول به بفتوى المتأخرين.',
      descriptionUr: 'دادا بھائیوں کے ساتھ شریک یا کم از کم ایک تہائی حصہ پاتا ہے۔',
    ),
    MadhhabDetails(
      madhhab: FiqhMadhhab.hanbali,
      nameEn: 'Hanbali',
      nameAr: 'الحنبلي',
      nameUr: 'حنبلی',
      imamNameEn: 'Imam Ahmad ibn Hanbal',
      imamNameAr: 'الإمام أحمد بن حنبل',
      imamNameUr: 'امام احمد بن حنبل',
      descriptionEn: 'Grandfather shares with brothers. Proportional Radd to non-spouse heirs.',
      descriptionAr: 'الجد يقاسم الإخوة. الرد على ذوي الفروض بنسبة سهامهم.',
      descriptionUr: 'دادا بھائیوں کے ساتھ شریک ہوتا ہے اور غیر زوجین پر رد لاگو ہوتا ہے۔',
    ),
  ];

  static MadhhabDetails forType(FiqhMadhhab type) {
    return all.firstWhere((m) => m.madhhab == type, orElse: () => all.first);
  }
}
