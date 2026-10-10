class HifzItem {
  final int surahNumber;
  final int ayahNumber;
  final int status; // 0=new, 1=learning, 2=memorized
  final int stability; // days until next review [1, 3, 7, 14, 30, 60, 120]
  final DateTime lastReviewed;
  final String? arabicText;
  final String? surahName;

  const HifzItem({
    required this.surahNumber,
    required this.ayahNumber,
    required this.status,
    required this.stability,
    required this.lastReviewed,
    this.arabicText,
    this.surahName,
  });

  String get key => '$surahNumber:$ayahNumber';

  DateTime get dueDate => lastReviewed.add(Duration(days: stability));

  bool get isDue {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return dueDate.isBefore(todayEnd) || dueDate.isAtSameMomentAs(todayEnd);
  }

  factory HifzItem.fromJson(
    String key,
    Map<String, dynamic> json, {
    String? arabicText,
    String? surahName,
  }) {
    final parts = key.split(':');
    final surah = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 1 : 1;
    final ayah = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;

    final status = (json['status'] as num?)?.toInt() ?? 1;
    final stability = (json['stability'] as num?)?.toInt() ?? 1;
    final lastStr = json['last'] as String?;
    final last = lastStr != null
        ? DateTime.tryParse(lastStr) ?? DateTime.now()
        : DateTime.now();

    return HifzItem(
      surahNumber: surah,
      ayahNumber: ayah,
      status: status,
      stability: stability,
      lastReviewed: last,
      arabicText: arabicText,
      surahName: surahName,
    );
  }

  Map<String, dynamic> toJson() {
    final y = lastReviewed.year.toString().padLeft(4, '0');
    final m = lastReviewed.month.toString().padLeft(2, '0');
    final d = lastReviewed.day.toString().padLeft(2, '0');
    return {
      'status': status,
      'stability': stability,
      'last': '$y-$m-$d',
    };
  }

  HifzItem copyWith({
    int? surahNumber,
    int? ayahNumber,
    int? status,
    int? stability,
    DateTime? lastReviewed,
    String? arabicText,
    String? surahName,
  }) {
    return HifzItem(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      status: status ?? this.status,
      stability: stability ?? this.stability,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      arabicText: arabicText ?? this.arabicText,
      surahName: surahName ?? this.surahName,
    );
  }
}
