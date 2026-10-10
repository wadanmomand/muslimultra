class Book {
  final String id;
  final String titleEn;
  final String titleAr;
  final String titleUr;
  final String lang;
  final double sizeMb;
  final String url;
  final String descEn;
  final String descAr;
  final String descUr;

  const Book({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.titleUr,
    required this.lang,
    required this.sizeMb,
    required this.url,
    required this.descEn,
    required this.descAr,
    required this.descUr,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      titleAr: json['title_ar'] as String? ?? '',
      titleUr: json['title_ur'] as String? ?? '',
      lang: json['lang'] as String? ?? 'en',
      sizeMb: (json['size_mb'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] as String? ?? '',
      descEn: json['desc_en'] as String? ?? '',
      descAr: json['desc_ar'] as String? ?? '',
      descUr: json['desc_ur'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_ar': titleAr,
      'title_ur': titleUr,
      'lang': lang,
      'size_mb': sizeMb,
      'url': url,
      'desc_en': descEn,
      'desc_ar': descAr,
      'desc_ur': descUr,
    };
  }

  String localizedTitle(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return titleAr.isNotEmpty ? titleAr : titleEn;
      case 'ur':
        return titleUr.isNotEmpty ? titleUr : titleEn;
      default:
        return titleEn.isNotEmpty ? titleEn : titleAr;
    }
  }

  String localizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return descAr.isNotEmpty ? descAr : descEn;
      case 'ur':
        return descUr.isNotEmpty ? descUr : descEn;
      default:
        return descEn.isNotEmpty ? descEn : descAr;
    }
  }

  bool get isLargeFile => sizeMb > 10.0;
}
