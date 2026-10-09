class AsmaName {
  final int n;
  final String ar;
  final String tr;
  final String en;
  final String ur;

  const AsmaName({
    required this.n,
    required this.ar,
    required this.tr,
    required this.en,
    required this.ur,
  });

  factory AsmaName.fromJson(Map<String, dynamic> json) {
    return AsmaName(
      n: json['n'] as int? ?? 0,
      ar: json['ar'] as String? ?? '',
      tr: json['tr'] as String? ?? '',
      en: json['en'] as String? ?? '',
      ur: json['ur'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'n': n,
      'ar': ar,
      'tr': tr,
      'en': en,
      'ur': ur,
    };
  }
}
