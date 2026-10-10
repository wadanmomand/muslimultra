import 'package:muslim_ultra/features/wirasa/domain/madhhab.dart';

class HeirsInput {
  final int husband; // 0 or 1
  final int wives; // 0 to 4
  final int father; // 0 or 1
  final int mother; // 0 or 1
  final int sons; // >= 0
  final int daughters; // >= 0
  final int paternalGrandfather; // 0 or 1
  final int paternalGrandmother; // 0 or 1
  final int maternalGrandmother; // 0 or 1
  final int fullBrothers; // >= 0
  final int fullSisters; // >= 0
  final int paternalBrothers; // >= 0
  final int paternalSisters; // >= 0
  final int maternalSiblings; // >= 0 (both male and female share equally in 1/3)
  final int sonsSons; // >= 0
  final int sonsDaughters; // >= 0

  const HeirsInput({
    this.husband = 0,
    this.wives = 0,
    this.father = 0,
    this.mother = 0,
    this.sons = 0,
    this.daughters = 0,
    this.paternalGrandfather = 0,
    this.paternalGrandmother = 0,
    this.maternalGrandmother = 0,
    this.fullBrothers = 0,
    this.fullSisters = 0,
    this.paternalBrothers = 0,
    this.paternalSisters = 0,
    this.maternalSiblings = 0,
    this.sonsSons = 0,
    this.sonsDaughters = 0,
  });

  bool get hasChildren => (sons + daughters + sonsSons + sonsDaughters) > 0;
  bool get hasMaleChild => (sons + sonsSons) > 0;
  bool get hasFemaleChild => (daughters + sonsDaughters) > 0;
  bool get hasDirectSons => sons > 0;
  bool get hasDirectDaughters => daughters > 0;

  int get totalSiblingsCount =>
      fullBrothers + fullSisters + paternalBrothers + paternalSisters + maternalSiblings;

  bool get hasMultipleSiblings => totalSiblingsCount >= 2;

  bool get isEmpty =>
      husband == 0 &&
      wives == 0 &&
      father == 0 &&
      mother == 0 &&
      sons == 0 &&
      daughters == 0 &&
      paternalGrandfather == 0 &&
      paternalGrandmother == 0 &&
      maternalGrandmother == 0 &&
      fullBrothers == 0 &&
      fullSisters == 0 &&
      paternalBrothers == 0 &&
      paternalSisters == 0 &&
      maternalSiblings == 0 &&
      sonsSons == 0 &&
      sonsDaughters == 0;

  HeirsInput copyWith({
    int? husband,
    int? wives,
    int? father,
    int? mother,
    int? sons,
    int? daughters,
    int? paternalGrandfather,
    int? paternalGrandmother,
    int? maternalGrandmother,
    int? fullBrothers,
    int? fullSisters,
    int? paternalBrothers,
    int? paternalSisters,
    int? maternalSiblings,
    int? sonsSons,
    int? sonsDaughters,
  }) {
    return HeirsInput(
      husband: husband ?? this.husband,
      wives: wives ?? this.wives,
      father: father ?? this.father,
      mother: mother ?? this.mother,
      sons: sons ?? this.sons,
      daughters: daughters ?? this.daughters,
      paternalGrandfather: paternalGrandfather ?? this.paternalGrandfather,
      paternalGrandmother: paternalGrandmother ?? this.paternalGrandmother,
      maternalGrandmother: maternalGrandmother ?? this.maternalGrandmother,
      fullBrothers: fullBrothers ?? this.fullBrothers,
      fullSisters: fullSisters ?? this.fullSisters,
      paternalBrothers: paternalBrothers ?? this.paternalBrothers,
      paternalSisters: paternalSisters ?? this.paternalSisters,
      maternalSiblings: maternalSiblings ?? this.maternalSiblings,
      sonsSons: sonsSons ?? this.sonsSons,
      sonsDaughters: sonsDaughters ?? this.sonsDaughters,
    );
  }
}

class HeirShare {
  final String heirKey;
  final String heirTitleEn;
  final String heirTitleAr;
  final String heirTitleUr;
  final int count;
  final String baseFraction; // e.g. "1/8", "2/3", "Residue ('Asaba)"
  final double totalFraction; // decimal 0.0 to 1.0
  final double perPersonPercentage; // percentage per individual
  final double totalPercentage; // total percentage for this heir group
  final String quranicBasis; // e.g. "Surah An-Nisa 4:11"

  const HeirShare({
    required this.heirKey,
    required this.heirTitleEn,
    required this.heirTitleAr,
    required this.heirTitleUr,
    required this.count,
    required this.baseFraction,
    required this.totalFraction,
    required this.perPersonPercentage,
    required this.totalPercentage,
    required this.quranicBasis,
  });

  String localizedTitle(String lang) {
    switch (lang) {
      case 'ar':
        return heirTitleAr;
      case 'ur':
        return heirTitleUr;
      default:
        return heirTitleEn;
    }
  }
}

class CalculationResult {
  final bool isCovered;
  final FiqhMadhhab madhhab;
  final List<HeirShare> shares;
  final List<String> notesEn;
  final List<String> notesAr;
  final List<String> notesUr;
  final bool awlApplied;
  final bool raddApplied;
  final String? unhandledReason;

  const CalculationResult({
    required this.isCovered,
    required this.madhhab,
    this.shares = const [],
    this.notesEn = const [],
    this.notesAr = const [],
    this.notesUr = const [],
    this.awlApplied = false,
    this.raddApplied = false,
    this.unhandledReason,
  });

  factory CalculationResult.uncovered({
    required FiqhMadhhab madhhab,
    String? reason,
  }) {
    return CalculationResult(
      isCovered: false,
      madhhab: madhhab,
      unhandledReason: reason,
    );
  }
}
