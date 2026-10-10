import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/wirasa/domain/madhhab.dart';
import 'package:muslim_ultra/features/wirasa/domain/heirs.dart';
import 'package:muslim_ultra/features/wirasa/data/wirasa_engine.dart';
import 'package:muslim_ultra/features/wirasa/presentation/screens/wirasa_screen.dart';

late AppLocalizations testEnL10n;
late AppLocalizations testArL10n;
late AppLocalizations testUrL10n;

class TestLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale locale;
  const TestLocalizationsDelegate(this.locale);

  @override
  bool isSupported(Locale l) => true;

  @override
  Future<AppLocalizations> load(Locale l) {
    if (locale.languageCode == 'ar') return SynchronousFuture(testArL10n);
    if (locale.languageCode == 'ur') return SynchronousFuture(testUrL10n);
    return SynchronousFuture(testEnL10n);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    testEnL10n = AppLocalizations(const Locale('en'));
    await testEnL10n.load();
    testArL10n = AppLocalizations(const Locale('ar'));
    await testArL10n.load();
    testUrL10n = AppLocalizations(const Locale('ur'));
    await testUrL10n.load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Part D: Wirasa Engine Math & Fiqh Rules', () {
    test('Classic Awl case: Husband + 2 Daughters + Father + Mother', () {
      // Husband = 1/4 (with children)
      // Daughters (2) = 2/3
      // Father = 1/6
      // Mother = 1/6
      // Sum = 3/12 + 8/12 + 2/12 + 2/12 = 15/12 = 1.25 > 1.0 -> 'Awl to 15
      final input = const HeirsInput(
        husband: 1,
        daughters: 2,
        father: 1,
        mother: 1,
      );

      final result = WirasaEngine.calculate(
        input: input,
        madhhab: FiqhMadhhab.hanafi,
      );

      expect(result.isCovered, isTrue);
      expect(result.awlApplied, isTrue);
      expect(result.shares.length, 4);

      // Total of scaled shares must sum to 1.0 (100%)
      var totalPct = 0.0;
      for (final s in result.shares) {
        totalPct += s.totalPercentage;
      }
      expect(totalPct, closeTo(100.0, 0.01));

      final husbandShare = result.shares.firstWhere((s) => s.heirKey == 'husband');
      // 3/15 = 20%
      expect(husbandShare.totalPercentage, closeTo(20.0, 0.01));

      final daughtersShare = result.shares.firstWhere((s) => s.heirKey == 'daughters');
      // 8/15 = 53.333%
      expect(daughtersShare.totalPercentage, closeTo(53.33, 0.05));
      expect(daughtersShare.perPersonPercentage, closeTo(26.67, 0.05));
    });

    test('Wife + Mother + 2 Daughters case with Radd', () {
      // Wife = 1/8
      // Mother = 1/6
      // Daughters = 2/3
      // Sum = 3/24 + 4/24 + 16/24 = 23/24 = 0.95833
      // Remainder = 1/24. Under Radd (majority), surplus returned proportionally to Mother & Daughters
      final input = const HeirsInput(
        wives: 1,
        mother: 1,
        daughters: 2,
      );

      final result = WirasaEngine.calculate(
        input: input,
        madhhab: FiqhMadhhab.hanafi,
      );

      expect(result.isCovered, isTrue);
      expect(result.raddApplied, isTrue);

      final wifeShare = result.shares.firstWhere((s) => s.heirKey == 'wives');
      // Wife gets fixed 1/8 = 12.5% (no radd to spouse in majority view)
      expect(wifeShare.totalPercentage, closeTo(12.5, 0.01));

      var totalPct = 0.0;
      for (final s in result.shares) {
        totalPct += s.totalPercentage;
      }
      expect(totalPct, closeTo(100.0, 0.01));
    });

    test('Sons + Daughters 2:1 Asaba distribution', () {
      // Wife = 1/8 (12.5%)
      // Remainder = 7/8 (87.5%)
      // 2 Sons (4 units) + 1 Daughter (1 unit) = 5 units total
      final input = const HeirsInput(
        wives: 1,
        sons: 2,
        daughters: 1,
      );

      final result = WirasaEngine.calculate(
        input: input,
        madhhab: FiqhMadhhab.hanafi,
      );

      expect(result.isCovered, isTrue);

      final wifeShare = result.shares.firstWhere((s) => s.heirKey == 'wives');
      expect(wifeShare.totalPercentage, closeTo(12.5, 0.01));

      final sonsShare = result.shares.firstWhere((s) => s.heirKey == 'sons');
      final daughtersShare = result.shares.firstWhere((s) => s.heirKey == 'daughters');

      // Sons get 4/5 of 87.5% = 70% total (35% each)
      // Daughter gets 1/5 of 87.5% = 17.5%
      expect(sonsShare.totalPercentage, closeTo(70.0, 0.01));
      expect(sonsShare.perPersonPercentage, closeTo(35.0, 0.01));
      expect(daughtersShare.totalPercentage, closeTo(17.5, 0.01));
      expect(sonsShare.perPersonPercentage, closeTo(daughtersShare.perPersonPercentage * 2, 0.01));
    });

    test('Grandfather + Brothers Ikhtilaf: Hanafi vs Shafi\'i/Maliki/Hanbali', () {
      final input = const HeirsInput(
        paternalGrandfather: 1,
        fullBrothers: 2,
      );

      // Hanafi: Grandfather excludes brothers completely, takes 100%
      final hanafiResult = WirasaEngine.calculate(
        input: input,
        madhhab: FiqhMadhhab.hanafi,
      );
      expect(hanafiResult.shares.length, 1);
      expect(hanafiResult.shares.first.heirKey, 'paternalGrandfather');
      expect(hanafiResult.shares.first.totalPercentage, closeTo(100.0, 0.01));

      // Shafi'i: Grandfather shares with 2 brothers (Muqasama) -> 3 equal male shares = 33.33% each
      final shafiiResult = WirasaEngine.calculate(
        input: input,
        madhhab: FiqhMadhhab.shafii,
      );
      expect(shafiiResult.shares.length, 2);
      final gfShare = shafiiResult.shares.firstWhere((s) => s.heirKey == 'paternalGrandfather');
      final brShare = shafiiResult.shares.firstWhere((s) => s.heirKey == 'fullBrothers');
      expect(gfShare.totalPercentage, closeTo(33.33, 0.1));
      expect(brShare.totalPercentage, closeTo(66.67, 0.1));
      expect(brShare.perPersonPercentage, closeTo(33.33, 0.1));
    });

    test('Unsupported combination returns isCovered: false with no numbers', () {
      final invalidInput = const HeirsInput(
        husband: 1,
        wives: 1,
      );

      final result = WirasaEngine.calculate(
        input: invalidInput,
        madhhab: FiqhMadhhab.hanafi,
      );

      expect(result.isCovered, isFalse);
      expect(result.shares, isEmpty);
    });

    test('All 4 Madhhabs contain Imam names in 3 locales', () {
      for (final madhhab in FiqhMadhhab.values) {
        final details = MadhhabDetails.forType(madhhab);
        expect(details.localizedName('en'), isNotEmpty);
        expect(details.localizedName('ar'), isNotEmpty);
        expect(details.localizedName('ur'), isNotEmpty);

        expect(details.localizedImam('en'), isNotEmpty);
        expect(details.localizedImam('ar'), isNotEmpty);
        expect(details.localizedImam('ur'), isNotEmpty);
      }
    });
  });

  group('Part D: Wirasa Screen Widget Tests', () {
    testWidgets('Renders Madhhab picker, heir steppers, calculate and disclaimer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              TestLocalizationsDelegate(Locale('en')),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
              Locale('ur', ''),
            ],
            home: const WirasaScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('madhhab_dropdown')), findsOneWidget);
      final calcBtnFinder = find.byKey(const Key('calculate_button'));
      expect(calcBtnFinder, findsOneWidget);

      // Scroll to and tap calculate
      await tester.ensureVisible(calcBtnFinder);
      await tester.tap(calcBtnFinder);
      await tester.pumpAndSettle();

      // Disclaimer MUST be present
      final disclaimerFinder = find.byKey(const Key('scholar_disclaimer'));
      await tester.ensureVisible(disclaimerFinder);
      expect(disclaimerFinder, findsOneWidget);
    });

    testWidgets('360px RTL smoke test without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              TestLocalizationsDelegate(Locale('ar')),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
              Locale('ur', ''),
            ],
            home: const WirasaScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('calculate_button')), findsOneWidget);
    });
  });
}
