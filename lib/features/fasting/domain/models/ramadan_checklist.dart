/// Daily checklist model for Ramadan spiritual habits
class RamadanChecklist {
  final bool suhoor;
  final bool fastKept;
  final bool taraweeh;
  final bool quran;
  final bool dua;

  const RamadanChecklist({
    this.suhoor = false,
    this.fastKept = false,
    this.taraweeh = false,
    this.quran = false,
    this.dua = false,
  });

  int get completedCount =>
      (suhoor ? 1 : 0) +
      (fastKept ? 1 : 0) +
      (taraweeh ? 1 : 0) +
      (quran ? 1 : 0) +
      (dua ? 1 : 0);

  double get progressFraction => completedCount / 5.0;

  RamadanChecklist copyWith({
    bool? suhoor,
    bool? fastKept,
    bool? taraweeh,
    bool? quran,
    bool? dua,
  }) {
    return RamadanChecklist(
      suhoor: suhoor ?? this.suhoor,
      fastKept: fastKept ?? this.fastKept,
      taraweeh: taraweeh ?? this.taraweeh,
      quran: quran ?? this.quran,
      dua: dua ?? this.dua,
    );
  }

  Map<String, dynamic> toJson() => {
        'suhoor': suhoor,
        'fast_kept': fastKept,
        'taraweeh': taraweeh,
        'quran': quran,
        'dua': dua,
      };

  factory RamadanChecklist.fromJson(Map<String, dynamic> json) {
    return RamadanChecklist(
      suhoor: json['suhoor'] as bool? ?? false,
      fastKept: json['fast_kept'] as bool? ?? false,
      taraweeh: json['taraweeh'] as bool? ?? false,
      quran: json['quran'] as bool? ?? false,
      dua: json['dua'] as bool? ?? false,
    );
  }
}
