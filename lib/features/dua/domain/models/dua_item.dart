class DuaItemModel {
  final int id;
  final String category;
  final String arabic;
  final String translationEnglish;
  final String translationUrdu;
  final String reference;

  const DuaItemModel({
    required this.id,
    required this.category,
    required this.arabic,
    required this.translationEnglish,
    required this.translationUrdu,
    required this.reference,
  });

  factory DuaItemModel.fromJson(Map<String, dynamic> json, int index) {
    return DuaItemModel(
      id: index + 1,
      category: (json['category'] as String? ?? 'General').trim(),
      arabic: (json['ar'] as String? ?? '').trim(),
      translationEnglish: (json['en'] as String? ?? '').trim(),
      translationUrdu: (json['ur'] as String? ?? '').trim(),
      reference: (json['ref'] as String? ?? '').trim(),
    );
  }

  /// Complete plain text representation suitable for copying and sharing
  String toShareableString() {
    final buffer = StringBuffer();
    buffer.writeln(arabic);
    buffer.writeln();
    if (translationEnglish.isNotEmpty) {
      buffer.writeln('English: $translationEnglish');
    }
    if (translationUrdu.isNotEmpty) {
      buffer.writeln('Urdu: $translationUrdu');
    }
    if (reference.isNotEmpty) {
      buffer.writeln('Reference: $reference');
    }
    buffer.writeln('— Hisn-ul-Muslim (Muslim Ultra)');
    return buffer.toString().trim();
  }
}
