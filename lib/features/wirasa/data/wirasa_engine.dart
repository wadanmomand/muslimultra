import 'package:muslim_ultra/features/wirasa/domain/madhhab.dart';
import 'package:muslim_ultra/features/wirasa/domain/heirs.dart';

class WirasaEngine {
  /// Pure-Dart Islamic Inheritance Calculation Engine
  /// Returns auditable calculation results according to the selected Fiqh Madhhab.
  static CalculationResult calculate({
    required HeirsInput input,
    required FiqhMadhhab madhhab,
  }) {
    // 1. Validation Checks
    if (input.isEmpty) {
      return CalculationResult(
        isCovered: true,
        madhhab: madhhab,
        shares: [],
        notesEn: ['No heirs entered.'],
        notesAr: ['لم يتم إدخال ورثة.'],
        notesUr: ['کوئی وارث درج نہیں کیا گیا۔'],
      );
    }

    if (input.husband > 0 && input.wives > 0) {
      return CalculationResult.uncovered(
        madhhab: madhhab,
        reason: 'Invalid input: Husband and Wife cannot both be heirs of the same deceased.',
      );
    }

    final notesEn = <String>[];
    final notesAr = <String>[];
    final notesUr = <String>[];

    // Track fixed Quranic shares (Dhawu al-Furud)
    final fixedShares = <String, double>{};
    final baseFractions = <String, String>{};
    final quranBases = <String, String>{};
    final heirCounts = <String, int>{};

    // -------------------------------------------------------------
    // STEP 1: SPOUSE SHARE (ZAWJ / ZAWJAH) - Agreed in Quran 4:12
    // -------------------------------------------------------------
    if (input.husband > 0) {
      heirCounts['husband'] = 1;
      if (input.hasChildren) {
        fixedShares['husband'] = 1.0 / 4.0;
        baseFractions['husband'] = '1/4';
        quranBases['husband'] = 'Surah An-Nisa 4:12';
      } else {
        fixedShares['husband'] = 1.0 / 2.0;
        baseFractions['husband'] = '1/2';
        quranBases['husband'] = 'Surah An-Nisa 4:12';
      }
    } else if (input.wives > 0) {
      heirCounts['wives'] = input.wives;
      if (input.hasChildren) {
        fixedShares['wives'] = 1.0 / 8.0;
        baseFractions['wives'] = '1/8';
        quranBases['wives'] = 'Surah An-Nisa 4:12';
      } else {
        fixedShares['wives'] = 1.0 / 4.0;
        baseFractions['wives'] = '1/4';
        quranBases['wives'] = 'Surah An-Nisa 4:12';
      }
    }

    // -------------------------------------------------------------
    // STEP 2: MOTHER & FATHER (PARENTS) - Agreed in Quran 4:11
    // -------------------------------------------------------------
    // Check Umariyyatan (Gharrawayn) Special Case: Spouse + Mother + Father only
    final isUmariyyatan = (input.husband > 0 || input.wives > 0) &&
        input.father == 1 &&
        input.mother == 1 &&
        !input.hasChildren &&
        input.totalSiblingsCount == 0;

    if (input.mother == 1) {
      heirCounts['mother'] = 1;
      if (input.hasChildren || input.hasMultipleSiblings) {
        fixedShares['mother'] = 1.0 / 6.0;
        baseFractions['mother'] = '1/6';
        quranBases['mother'] = 'Surah An-Nisa 4:11';
      } else if (isUmariyyatan) {
        // Mother receives 1/3 of the remainder after the spouse share (Umar's precedent)
        final spouseShare = fixedShares['husband'] ?? fixedShares['wives'] ?? 0.0;
        final remainder = 1.0 - spouseShare;
        fixedShares['mother'] = remainder * (1.0 / 3.0);
        baseFractions['mother'] = '1/3 Remainder';
        quranBases['mother'] = 'Umariyyatan Consensus';
        notesEn.add('Umariyyatan case: Mother receives 1/3 of the remaining estate after spouse share.');
        notesAr.add('المسألة العمرية: للأم ثلث الباقي بعد نصيب أحد الزوجين.');
        notesUr.add('مسئلہ عمریہ: ماں کو شریکِ حیات کے حصے کے بعد باقی کا ایک تہائی ملتا ہے۔');
      } else {
        fixedShares['mother'] = 1.0 / 3.0;
        baseFractions['mother'] = '1/3';
        quranBases['mother'] = 'Surah An-Nisa 4:11';
      }
    }

    // Father handling:
    // - With male child: fixed 1/6
    // - With female child only (no sons): fixed 1/6 + 'asaba
    // - Without children: pure 'asaba (takes remainder)
    var fatherIsAsaba = false;
    if (input.father == 1) {
      heirCounts['father'] = 1;
      if (input.hasMaleChild) {
        fixedShares['father'] = 1.0 / 6.0;
        baseFractions['father'] = '1/6';
        quranBases['father'] = 'Surah An-Nisa 4:11';
      } else if (input.hasFemaleChild) {
        fixedShares['father'] = 1.0 / 6.0;
        baseFractions['father'] = '1/6 + Residue';
        quranBases['father'] = 'Surah An-Nisa 4:11';
        fatherIsAsaba = true;
      } else {
        fatherIsAsaba = true;
        baseFractions['father'] = 'Residue (\'Asaba)';
        quranBases['father'] = 'Surah An-Nisa 4:11';
      }
    }

    // -------------------------------------------------------------
    // STEP 3: GRANDPARENTS (When parents absent)
    // -------------------------------------------------------------
    // Maternal Grandmother: Excluded by Mother
    if (input.maternalGrandmother == 1 && input.mother == 0) {
      heirCounts['maternalGrandmother'] = 1;
      fixedShares['maternalGrandmother'] = 1.0 / 6.0;
      baseFractions['maternalGrandmother'] = '1/6';
      quranBases['maternalGrandmother'] = 'Sunnah Precedent';
    }

    // Paternal Grandmother: Excluded by Mother, and by Father
    if (input.paternalGrandmother == 1 && input.mother == 0 && input.father == 0) {
      if (fixedShares.containsKey('maternalGrandmother')) {
        // Both grandmothers share the 1/6 equally
        heirCounts['paternalGrandmother'] = 1;
        fixedShares['maternalGrandmother'] = 1.0 / 12.0;
        fixedShares['paternalGrandmother'] = 1.0 / 12.0;
        baseFractions['maternalGrandmother'] = '1/12 (1/2 of 1/6)';
        baseFractions['paternalGrandmother'] = '1/12 (1/2 of 1/6)';
        quranBases['paternalGrandmother'] = 'Sunnah Precedent';
      } else {
        heirCounts['paternalGrandmother'] = 1;
        fixedShares['paternalGrandmother'] = 1.0 / 6.0;
        baseFractions['paternalGrandmother'] = '1/6';
        quranBases['paternalGrandmother'] = 'Sunnah Precedent';
      }
    }

    // Paternal Grandfather (when Father is absent)
    var grandfatherIsAsaba = false;
    var grandfatherSharesWithBrothers = false;

    if (input.paternalGrandfather == 1 && input.father == 0) {
      heirCounts['paternalGrandfather'] = 1;
      final hasBrothersOrSisters = (input.fullBrothers + input.fullSisters + input.paternalBrothers + input.paternalSisters) > 0;

      if (hasBrothersOrSisters) {
        // IKHTILAF: Hanafi vs Maliki / Shafi'i / Hanbali
        if (madhhab == FiqhMadhhab.hanafi) {
          notesEn.add('Hanafi Fiqh: Grandfather excludes all brothers and sisters entirely (view of Abu Hanifa & Abu Bakr).');
          notesAr.add('المذهب الحنفي: الجد يحجب جميع الإخوة والأخوات كالأب (قول أبي بكر وأبي حنيفة).');
          notesUr.add('فقہ حنفی: دادا تمام بھائیوں اور بہنوں کو مکمل طور پر وراثت سے محجوب کرتا ہے۔');
          if (input.hasMaleChild) {
            fixedShares['paternalGrandfather'] = 1.0 / 6.0;
            baseFractions['paternalGrandfather'] = '1/6';
            quranBases['paternalGrandfather'] = 'Analogy to Father';
          } else if (input.hasFemaleChild) {
            fixedShares['paternalGrandfather'] = 1.0 / 6.0;
            baseFractions['paternalGrandfather'] = '1/6 + Residue';
            quranBases['paternalGrandfather'] = 'Analogy to Father';
            grandfatherIsAsaba = true;
          } else {
            grandfatherIsAsaba = true;
            baseFractions['paternalGrandfather'] = 'Residue (\'Asaba)';
            quranBases['paternalGrandfather'] = 'Analogy to Father';
          }
        } else {
          // Maliki, Shafi'i, Hanbali: Grandfather shares with siblings (Muqasama)
          grandfatherSharesWithBrothers = true;
          notesEn.add('Maliki/Shafi\'i/Hanbali Fiqh: Grandfather shares with siblings (Muqasama, minimum 1/3 or 1/6).');
          notesAr.add('الجمهور (مالك، الشافعي، أحمد): الجد يقاسم الإخوة الأشقاء أو اللأب (المقاسمة بما لا يقل عن الثلث أو السدس).');
          notesUr.add('جمہور (مالکی، شافعی، حنبلی): دادا بھائیوں کے ساتھ مقاسمہ کرتا ہے۔');
        }
      } else {
        if (input.hasMaleChild) {
          fixedShares['paternalGrandfather'] = 1.0 / 6.0;
          baseFractions['paternalGrandfather'] = '1/6';
          quranBases['paternalGrandfather'] = 'Analogy to Father';
        } else if (input.hasFemaleChild) {
          fixedShares['paternalGrandfather'] = 1.0 / 6.0;
          baseFractions['paternalGrandfather'] = '1/6 + Residue';
          quranBases['paternalGrandfather'] = 'Analogy to Father';
          grandfatherIsAsaba = true;
        } else {
          grandfatherIsAsaba = true;
          baseFractions['paternalGrandfather'] = 'Residue (\'Asaba)';
          quranBases['paternalGrandfather'] = 'Analogy to Father';
        }
      }
    }

    // -------------------------------------------------------------
    // STEP 4: DAUGHTERS & SONS (DESCENDANTS)
    // -------------------------------------------------------------
    var sonsAreAsaba = false;
    if (input.sons > 0) {
      heirCounts['sons'] = input.sons;
      if (input.daughters > 0) {
        heirCounts['daughters'] = input.daughters;
      }
      sonsAreAsaba = true;
      baseFractions['sons'] = 'Residue (\'Asaba 2:1)';
      quranBases['sons'] = 'Surah An-Nisa 4:11';
      if (input.daughters > 0) {
        baseFractions['daughters'] = 'Residue (\'Asaba 2:1)';
        quranBases['daughters'] = 'Surah An-Nisa 4:11';
      }
    } else if (input.daughters > 0) {
      heirCounts['daughters'] = input.daughters;
      if (input.daughters == 1) {
        fixedShares['daughters'] = 1.0 / 2.0;
        baseFractions['daughters'] = '1/2';
        quranBases['daughters'] = 'Surah An-Nisa 4:11';
      } else {
        fixedShares['daughters'] = 2.0 / 3.0;
        baseFractions['daughters'] = '2/3';
        quranBases['daughters'] = 'Surah An-Nisa 4:11';
      }
    }

    // -------------------------------------------------------------
    // STEP 5: MATERNAL SIBLINGS - Agreed in Quran 4:12
    // Excluded by Father, Grandfather, and Children/Son's Children
    // -------------------------------------------------------------
    final maternalSiblingsExcluded = input.father > 0 ||
        input.paternalGrandfather > 0 ||
        input.hasChildren;

    if (input.maternalSiblings > 0 && !maternalSiblingsExcluded) {
      heirCounts['maternalSiblings'] = input.maternalSiblings;
      if (input.maternalSiblings == 1) {
        fixedShares['maternalSiblings'] = 1.0 / 6.0;
        baseFractions['maternalSiblings'] = '1/6';
        quranBases['maternalSiblings'] = 'Surah An-Nisa 4:12';
      } else {
        fixedShares['maternalSiblings'] = 1.0 / 3.0;
        baseFractions['maternalSiblings'] = '1/3 (Equal Male & Female)';
        quranBases['maternalSiblings'] = 'Surah An-Nisa 4:12';
      }
    }

    // -------------------------------------------------------------
    // STEP 6: FULL SIBLINGS (When not excluded)
    // -------------------------------------------------------------
    final fullSiblingsExcluded = input.father > 0 ||
        input.hasMaleChild ||
        (input.paternalGrandfather > 0 && madhhab == FiqhMadhhab.hanafi);

    var fullBrothersAreAsaba = false;
    if (!fullSiblingsExcluded) {
      if (input.fullBrothers > 0) {
        heirCounts['fullBrothers'] = input.fullBrothers;
        fullBrothersAreAsaba = true;
        baseFractions['fullBrothers'] = 'Residue (\'Asaba)';
        quranBases['fullBrothers'] = 'Surah An-Nisa 4:176';
        if (input.fullSisters > 0) {
          heirCounts['fullSisters'] = input.fullSisters;
          baseFractions['fullSisters'] = 'Residue (\'Asaba 2:1)';
          quranBases['fullSisters'] = 'Surah An-Nisa 4:176';
        }
      } else if (input.fullSisters > 0) {
        heirCounts['fullSisters'] = input.fullSisters;
        if (input.daughters > 0) {
          // Sisters become 'Asaba with daughters ('Asaba ma'a Ghayriha)
          fullBrothersAreAsaba = true;
          baseFractions['fullSisters'] = 'Residue (\'Asaba with Daughters)';
          quranBases['fullSisters'] = 'Hadith of Ibn Mas\'ud';
        } else if (!input.hasChildren) {
          if (input.fullSisters == 1) {
            fixedShares['fullSisters'] = 1.0 / 2.0;
            baseFractions['fullSisters'] = '1/2';
            quranBases['fullSisters'] = 'Surah An-Nisa 4:176';
          } else {
            fixedShares['fullSisters'] = 2.0 / 3.0;
            baseFractions['fullSisters'] = '2/3';
            quranBases['fullSisters'] = 'Surah An-Nisa 4:176';
          }
        }
      }
    }

    // Grandfather sharing with brothers calculation (Maliki/Shafi'i/Hanbali)
    if (grandfatherSharesWithBrothers) {
      // Calculate grandfather + full brothers/sisters as 'asaba unit
      fullBrothersAreAsaba = true;
      heirCounts['paternalGrandfather'] = 1;
      if (input.fullBrothers > 0) heirCounts['fullBrothers'] = input.fullBrothers;
      if (input.fullSisters > 0) heirCounts['fullSisters'] = input.fullSisters;
      baseFractions['paternalGrandfather'] = 'Muqasama (\'Asaba)';
      quranBases['paternalGrandfather'] = 'Zayd ibn Thabit Precedent';
    }

    // -------------------------------------------------------------
    // STEP 7: TOTAL FIXED SHARES, 'AWL & RADD RESOLUTION
    // -------------------------------------------------------------
    var totalFixedShare = 0.0;
    fixedShares.forEach((_, share) => totalFixedShare += share);

    final sharesResult = <HeirShare>[];
    var awlApplied = false;
    var raddApplied = false;

    if (totalFixedShare > 1.0001) {
      // -------------------------------------------------------
      // 'AWL (Proportional Reduction) - Precedent of Ali & Umar
      // -------------------------------------------------------
      awlApplied = true;
      notesEn.add('\'Awl applied: Total fixed shares exceeded 1.0 (${totalFixedShare.toStringAsFixed(3)}) — shares proportionally reduced.');
      notesAr.add('تم تطبيق العول: مجموع الفروض تجاوز أصل المسألة — تم تقليص السهام بالتناسب.');
      notesUr.add('عول لاگو ہوا: کل حصے 1 سے تجاوز کر گئے، لہٰذا تمام حصص متناسب طور پر کم کیے گئے۔');

      fixedShares.forEach((heirKey, share) {
        final scaledShare = share / totalFixedShare;
        final count = heirCounts[heirKey] ?? 1;
        final perPerson = (scaledShare * 100.0) / count;
        final totalPct = scaledShare * 100.0;

        sharesResult.add(
          _createHeirShare(
            heirKey: heirKey,
            count: count,
            baseFraction: baseFractions[heirKey] ?? '',
            totalFraction: scaledShare,
            perPersonPercentage: perPerson,
            totalPercentage: totalPct,
            quranBasis: quranBases[heirKey] ?? 'Quran / Sunnah',
          ),
        );
      });
    } else if (totalFixedShare < 0.9999) {
      final residue = 1.0 - totalFixedShare;

      // Check for 'Asaba heirs who inherit the residue
      if (sonsAreAsaba) {
        // Direct sons + daughters 2:1
        final sonUnits = input.sons * 2;
        final daughterUnits = input.daughters * 1;
        final totalUnits = sonUnits + daughterUnits;

        // Add fixed shares first
        fixedShares.forEach((heirKey, share) {
          final count = heirCounts[heirKey] ?? 1;
          sharesResult.add(_createHeirShare(
            heirKey: heirKey,
            count: count,
            baseFraction: baseFractions[heirKey] ?? '',
            totalFraction: share,
            perPersonPercentage: (share * 100.0) / count,
            totalPercentage: share * 100.0,
            quranBasis: quranBases[heirKey] ?? 'Quran / Sunnah',
          ));
        });

        if (input.sons > 0 && totalUnits > 0) {
          final sonsFraction = residue * (sonUnits / totalUnits);
          final perSonPct = (sonsFraction * 100.0) / input.sons;
          sharesResult.add(_createHeirShare(
            heirKey: 'sons',
            count: input.sons,
            baseFraction: 'Residue (\'Asaba 2:1)',
            totalFraction: sonsFraction,
            perPersonPercentage: perSonPct,
            totalPercentage: sonsFraction * 100.0,
            quranBasis: 'Surah An-Nisa 4:11',
          ));
        }

        if (input.daughters > 0 && totalUnits > 0) {
          final daughtersFraction = residue * (daughterUnits / totalUnits);
          final perDaughterPct = (daughtersFraction * 100.0) / input.daughters;
          sharesResult.add(_createHeirShare(
            heirKey: 'daughters',
            count: input.daughters,
            baseFraction: 'Residue (\'Asaba 2:1)',
            totalFraction: daughtersFraction,
            perPersonPercentage: perDaughterPct,
            totalPercentage: daughtersFraction * 100.0,
            quranBasis: 'Surah An-Nisa 4:11',
          ));
        }
      } else if (fatherIsAsaba) {
        // Father takes residue (or 1/6 + residue)
        fixedShares.forEach((heirKey, share) {
          if (heirKey != 'father') {
            final count = heirCounts[heirKey] ?? 1;
            sharesResult.add(_createHeirShare(
              heirKey: heirKey,
              count: count,
              baseFraction: baseFractions[heirKey] ?? '',
              totalFraction: share,
              perPersonPercentage: (share * 100.0) / count,
              totalPercentage: share * 100.0,
              quranBasis: quranBases[heirKey] ?? 'Quran / Sunnah',
            ));
          }
        });

        final fatherFixed = fixedShares['father'] ?? 0.0;
        final totalFatherShare = fatherFixed + residue;
        sharesResult.add(_createHeirShare(
          heirKey: 'father',
          count: 1,
          baseFraction: baseFractions['father'] ?? 'Residue (\'Asaba)',
          totalFraction: totalFatherShare,
          perPersonPercentage: totalFatherShare * 100.0,
          totalPercentage: totalFatherShare * 100.0,
          quranBasis: 'Surah An-Nisa 4:11',
        ));
      } else if (grandfatherIsAsaba) {
        // Grandfather takes residue
        fixedShares.forEach((heirKey, share) {
          if (heirKey != 'paternalGrandfather') {
            final count = heirCounts[heirKey] ?? 1;
            sharesResult.add(_createHeirShare(
              heirKey: heirKey,
              count: count,
              baseFraction: baseFractions[heirKey] ?? '',
              totalFraction: share,
              perPersonPercentage: (share * 100.0) / count,
              totalPercentage: share * 100.0,
              quranBasis: quranBases[heirKey] ?? 'Quran / Sunnah',
            ));
          }
        });

        final gfFixed = fixedShares['paternalGrandfather'] ?? 0.0;
        final totalGfShare = gfFixed + residue;
        sharesResult.add(_createHeirShare(
          heirKey: 'paternalGrandfather',
          count: 1,
          baseFraction: baseFractions['paternalGrandfather'] ?? 'Residue (\'Asaba)',
          totalFraction: totalGfShare,
          perPersonPercentage: totalGfShare * 100.0,
          totalPercentage: totalGfShare * 100.0,
          quranBasis: 'Analogy to Father',
        ));
      } else if (grandfatherSharesWithBrothers) {
        // Grandfather shares residue with brothers/sisters (Muqasama)
        fixedShares.forEach((heirKey, share) {
          final count = heirCounts[heirKey] ?? 1;
          sharesResult.add(_createHeirShare(
            heirKey: heirKey,
            count: count,
            baseFraction: baseFractions[heirKey] ?? '',
            totalFraction: share,
            perPersonPercentage: (share * 100.0) / count,
            totalPercentage: share * 100.0,
            quranBasis: quranBases[heirKey] ?? 'Quran / Sunnah',
          ));
        });

        final gfUnits = 2; // Grandfather counts as 1 brother (2 shares)
        final brUnits = input.fullBrothers * 2;
        final sisUnits = input.fullSisters * 1;
        final totalUnits = gfUnits + brUnits + sisUnits;

        final gfShare = residue * (gfUnits / totalUnits);
        sharesResult.add(_createHeirShare(
          heirKey: 'paternalGrandfather',
          count: 1,
          baseFraction: 'Muqasama (\'Asaba)',
          totalFraction: gfShare,
          perPersonPercentage: gfShare * 100.0,
          totalPercentage: gfShare * 100.0,
          quranBasis: 'Zayd ibn Thabit Precedent',
        ));

        if (input.fullBrothers > 0) {
          final brShare = residue * (brUnits / totalUnits);
          sharesResult.add(_createHeirShare(
            heirKey: 'fullBrothers',
            count: input.fullBrothers,
            baseFraction: 'Muqasama (\'Asaba 2:1)',
            totalFraction: brShare,
            perPersonPercentage: (brShare * 100.0) / input.fullBrothers,
            totalPercentage: brShare * 100.0,
            quranBasis: 'Zayd ibn Thabit Precedent',
          ));
        }

        if (input.fullSisters > 0) {
          final sisShare = residue * (sisUnits / totalUnits);
          sharesResult.add(_createHeirShare(
            heirKey: 'fullSisters',
            count: input.fullSisters,
            baseFraction: 'Muqasama (\'Asaba 2:1)',
            totalFraction: sisShare,
            perPersonPercentage: (sisShare * 100.0) / input.fullSisters,
            totalPercentage: sisShare * 100.0,
            quranBasis: 'Zayd ibn Thabit Precedent',
          ));
        }
      } else if (fullBrothersAreAsaba) {
        // Full brothers & sisters inherit the residue
        fixedShares.forEach((heirKey, share) {
          final count = heirCounts[heirKey] ?? 1;
          sharesResult.add(_createHeirShare(
            heirKey: heirKey,
            count: count,
            baseFraction: baseFractions[heirKey] ?? '',
            totalFraction: share,
            perPersonPercentage: (share * 100.0) / count,
            totalPercentage: share * 100.0,
            quranBasis: quranBases[heirKey] ?? 'Quran / Sunnah',
          ));
        });

        final brUnits = input.fullBrothers * 2;
        final sisUnits = input.fullSisters * (input.fullBrothers > 0 ? 1 : 1);
        final totalUnits = brUnits + sisUnits;

        if (input.fullBrothers > 0 && totalUnits > 0) {
          final brFraction = residue * (brUnits / totalUnits);
          sharesResult.add(_createHeirShare(
            heirKey: 'fullBrothers',
            count: input.fullBrothers,
            baseFraction: 'Residue (\'Asaba)',
            totalFraction: brFraction,
            perPersonPercentage: (brFraction * 100.0) / input.fullBrothers,
            totalPercentage: brFraction * 100.0,
            quranBasis: 'Surah An-Nisa 4:176',
          ));
        }

        if (input.fullSisters > 0 && totalUnits > 0) {
          final sisFraction = residue * (sisUnits / totalUnits);
          sharesResult.add(_createHeirShare(
            heirKey: 'fullSisters',
            count: input.fullSisters,
            baseFraction: input.daughters > 0 ? 'Residue (\'Asaba with Daughters)' : 'Residue (\'Asaba 2:1)',
            totalFraction: sisFraction,
            perPersonPercentage: (sisFraction * 100.0) / input.fullSisters,
            totalPercentage: sisFraction * 100.0,
            quranBasis: input.daughters > 0 ? 'Hadith of Ibn Mas\'ud' : 'Surah An-Nisa 4:176',
          ));
        }
      } else {
        // -------------------------------------------------------
        // RADD (Surplus Return) - No 'Asaba heirs
        // -------------------------------------------------------
        raddApplied = true;
        notesEn.add('Radd applied: Surplus returned to non-spouse fixed heirs proportionally (majority view).');
        notesAr.add('تم تطبيق الرد: تم رد الفائض على ذوي الفروض عدا الزوجين بنسبة سهامهم (قول الجمهور).');
        notesUr.add('رد لاگو ہوا: باقی ماندہ ترکہ غیر زوجین ورثہ میں ان کے حصوں کے تناسب سے تقسیم کیا گیا۔');

        final spouseKey = input.husband > 0 ? 'husband' : (input.wives > 0 ? 'wives' : null);
        final spouseShare = spouseKey != null ? (fixedShares[spouseKey] ?? 0.0) : 0.0;

        if (spouseKey != null) {
          final count = heirCounts[spouseKey] ?? 1;
          sharesResult.add(_createHeirShare(
            heirKey: spouseKey,
            count: count,
            baseFraction: baseFractions[spouseKey] ?? '',
            totalFraction: spouseShare,
            perPersonPercentage: (spouseShare * 100.0) / count,
            totalPercentage: spouseShare * 100.0,
            quranBasis: quranBases[spouseKey] ?? 'Surah An-Nisa 4:12',
          ));
        }

        final nonSpouseShares = <String, double>{};
        var nonSpouseSum = 0.0;
        fixedShares.forEach((k, v) {
          if (k != 'husband' && k != 'wives') {
            nonSpouseShares[k] = v;
            nonSpouseSum += v;
          }
        });

        final remainingEstate = 1.0 - spouseShare;
        nonSpouseShares.forEach((k, v) {
          final ratio = nonSpouseSum > 0 ? (v / nonSpouseSum) : 1.0;
          final raddFraction = remainingEstate * ratio;
          final count = heirCounts[k] ?? 1;
          sharesResult.add(_createHeirShare(
            heirKey: k,
            count: count,
            baseFraction: '${baseFractions[k]} + Radd',
            totalFraction: raddFraction,
            perPersonPercentage: (raddFraction * 100.0) / count,
            totalPercentage: raddFraction * 100.0,
            quranBasis: '${quranBases[k]} & Consensus on Radd',
          ));
        });
      }
    } else {
      // Total fixed shares exactly 1.0
      fixedShares.forEach((heirKey, share) {
        final count = heirCounts[heirKey] ?? 1;
        sharesResult.add(_createHeirShare(
          heirKey: heirKey,
          count: count,
          baseFraction: baseFractions[heirKey] ?? '',
          totalFraction: share,
          perPersonPercentage: (share * 100.0) / count,
          totalPercentage: share * 100.0,
          quranBasis: quranBases[heirKey] ?? 'Quran / Sunnah',
        ));
      });
    }

    return CalculationResult(
      isCovered: true,
      madhhab: madhhab,
      shares: sharesResult,
      notesEn: notesEn,
      notesAr: notesAr,
      notesUr: notesUr,
      awlApplied: awlApplied,
      raddApplied: raddApplied,
    );
  }

  static HeirShare _createHeirShare({
    required String heirKey,
    required int count,
    required String baseFraction,
    required double totalFraction,
    required double perPersonPercentage,
    required double totalPercentage,
    required String quranBasis,
  }) {
    final titles = _getHeirTitles(heirKey, count);
    return HeirShare(
      heirKey: heirKey,
      heirTitleEn: titles['en']!,
      heirTitleAr: titles['ar']!,
      heirTitleUr: titles['ur']!,
      count: count,
      baseFraction: baseFraction,
      totalFraction: totalFraction,
      perPersonPercentage: perPersonPercentage,
      totalPercentage: totalPercentage,
      quranicBasis: quranBasis,
    );
  }

  static Map<String, String> _getHeirTitles(String key, int count) {
    switch (key) {
      case 'husband':
        return {'en': 'Husband', 'ar': 'الزوج', 'ur': 'شوہر'};
      case 'wives':
        return {
          'en': count > 1 ? 'Wives ($count)' : 'Wife',
          'ar': count > 1 ? 'الزوجات ($count)' : 'الزوجة',
          'ur': count > 1 ? 'بیویاں ($count)' : 'بیوی',
        };
      case 'father':
        return {'en': 'Father', 'ar': 'الأب', 'ur': 'والد'};
      case 'mother':
        return {'en': 'Mother', 'ar': 'الأم', 'ur': 'والدہ'};
      case 'sons':
        return {
          'en': count > 1 ? 'Sons ($count)' : 'Son',
          'ar': count > 1 ? 'الأبناء ($count)' : 'الابن',
          'ur': count > 1 ? 'بیٹے ($count)' : 'بیٹا',
        };
      case 'daughters':
        return {
          'en': count > 1 ? 'Daughters ($count)' : 'Daughter',
          'ar': count > 1 ? 'البنات ($count)' : 'البنت',
          'ur': count > 1 ? 'بیٹیاں ($count)' : 'بیٹی',
        };
      case 'paternalGrandfather':
        return {'en': 'Paternal Grandfather', 'ar': 'الجد الصحيح (لأب)', 'ur': 'دادا'};
      case 'paternalGrandmother':
        return {'en': 'Paternal Grandmother', 'ar': 'الجدة (لأب)', 'ur': 'دادی'};
      case 'maternalGrandmother':
        return {'en': 'Maternal Grandmother', 'ar': 'الجدة (لأم)', 'ur': 'نانی'};
      case 'fullBrothers':
        return {
          'en': count > 1 ? 'Full Brothers ($count)' : 'Full Brother',
          'ar': count > 1 ? 'الإخوة الأشقاء ($count)' : 'الأخ الشقيق',
          'ur': count > 1 ? 'حقیقی بھائی ($count)' : 'حقیقی بھائی',
        };
      case 'fullSisters':
        return {
          'en': count > 1 ? 'Full Sisters ($count)' : 'Full Sister',
          'ar': count > 1 ? 'الأخوات الشقيقات ($count)' : 'الأخت الشقيقة',
          'ur': count > 1 ? 'حقیقی بہنیں ($count)' : 'حقیقی بہن',
        };
      case 'maternalSiblings':
        return {
          'en': count > 1 ? 'Maternal Siblings ($count)' : 'Maternal Sibling',
          'ar': count > 1 ? 'الإخوة لأم ($count)' : 'الأخ لأم',
          'ur': count > 1 ? 'اخیافی بہن بھائی ($count)' : 'اخیافی بھائی/بہن',
        };
      default:
        return {'en': key, 'ar': key, 'ur': key};
    }
  }
}
