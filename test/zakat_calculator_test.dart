import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/zakat/data/zakat_storage_service.dart';
import 'package:muslim_ultra/features/zakat/domain/models/zakat_input.dart';
import 'package:muslim_ultra/features/zakat/domain/services/zakat_calculator.dart';
import 'package:muslim_ultra/features/zakat/presentation/screens/zakat_calculator_screen.dart';

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
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => true;
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

  group('Zakat Calculator Pure Engine Tests (Verified Fiqh Math)', () {
    test('Hand-calculated Example 1: Net wealth below Silver Nisab → NOT eligible, Zakat 0', () {
      // Cash 100,000 + Gold 50g @ 20,000/g = 1,000,000 -> Total Assets = 1,100,000
      // Debts = 100,000 -> Net Wealth = 1,000,000
      // Silver rate = 2,500/g -> Silver Nisab (612.36g * 2,500) = 1,530,900
      // Net Wealth (1,000,000) < Nisab (1,530,900) -> Eligible = false, Zakat = 0.0
      const input = ZakatInput(
        nisabStandard: NisabStandard.silver,
        currency: 'PKR',
        goldPricePerGram: 20000.0,
        silverPricePerGram: 2500.0,
        cashInHand: 100000.0,
        goldGrams: 50.0,
        debts: 100000.0,
      );

      final result = ZakatCalculator.calculate(input);

      expect(result.goldValue, 1000000.0);
      expect(result.totalAssets, 1100000.0);
      expect(result.totalDebtsAndLiabilities, 1000000.0 * 0.1); // 100,000.0
      expect(result.netWealth, 1000000.0);
      expect(result.nisabValue, 1530900.0); // 612.36 * 2500
      expect(result.isEligible, isFalse);
      expect(result.zakatDue, 0.0);
    });

    test('Hand-calculated Example 2: Net wealth above Silver Nisab → Exactly 2.5% Zakat', () {
      // Cash 2,000,000, Debts 200,000 -> Net Wealth = 1,800,000
      // Silver Nisab = 612.36 * 2,500 = 1,530,900
      // Net Wealth (1,800,000) >= Nisab (1,530,900) -> Eligible = true
      // Zakat = 1,800,000 * 0.025 = 45,000.0
      const input = ZakatInput(
        nisabStandard: NisabStandard.silver,
        currency: 'PKR',
        silverPricePerGram: 2500.0,
        cashInHand: 2000000.0,
        debts: 200000.0,
      );

      final result = ZakatCalculator.calculate(input);

      expect(result.totalAssets, 2000000.0);
      expect(result.totalDebtsAndLiabilities, 200000.0);
      expect(result.netWealth, 1800000.0);
      expect(result.nisabValue, 1530900.0);
      expect(result.isEligible, isTrue);
      expect(result.zakatDue, 45000.0); // 1,800,000 * 0.025
    });

    test('Gold Nisab standard calculates against 87.48g threshold', () {
      // Gold Price: 75.0 USD/g -> Gold Nisab (87.48 * 75.0) = 6561.0 USD
      // Net Wealth: 10,000 USD -> Eligible -> Zakat = 10,000 * 0.025 = 250.0 USD
      const input = ZakatInput(
        nisabStandard: NisabStandard.gold,
        currency: 'USD',
        goldPricePerGram: 75.0,
        cashInHand: 10000.0,
      );

      final result = ZakatCalculator.calculate(input);

      expect(result.nisabGrams, 87.48);
      expect(result.nisabValue, 87.48 * 75.0); // 6561.0
      expect(result.isEligible, isTrue);
      expect(result.zakatDue, 250.0);
    });

    test('Debts exceeding assets produces zero net wealth (never negative) and zero zakat', () {
      const input = ZakatInput(
        nisabStandard: NisabStandard.silver,
        silverPricePerGram: 1.0,
        cashInHand: 500.0,
        debts: 2000.0,
      );

      final result = ZakatCalculator.calculate(input);

      expect(result.totalAssets, 500.0);
      expect(result.totalDebtsAndLiabilities, 2000.0);
      expect(result.netWealth, 0.0);
      expect(result.isEligible, isFalse);
      expect(result.zakatDue, 0.0);
    });

    test('Empty and negative inputs are sanitized to zero', () {
      const input = ZakatInput(
        cashInHand: -500.0,
        bankSavings: 0.0,
        goldGrams: -10.0,
        debts: -300.0,
      );

      final result = ZakatCalculator.calculate(input);

      expect(result.totalAssets, 0.0);
      expect(result.totalDebtsAndLiabilities, 0.0);
      expect(result.netWealth, 0.0);
      expect(result.isEligible, isFalse);
      expect(result.zakatDue, 0.0);
    });

    test('Comprehensive asset categories sum up accurately', () {
      const input = ZakatInput(
        cashInHand: 1000.0,
        bankSavings: 4000.0,
        goldGrams: 10.0,
        goldPricePerGram: 70.0, // 700.0
        silverGrams: 100.0,
        silverPricePerGram: 1.0, // 100.0
        investments: 5000.0,
        businessInventory: 3000.0,
        moneyOwedToYou: 1200.0,
        debts: 2000.0,
        immediateExpenses: 1000.0,
      );

      final result = ZakatCalculator.calculate(input);

      // Total Assets = 1000 + 4000 + 700 + 100 + 5000 + 3000 + 1200 = 15,000.0
      expect(result.totalAssets, 15000.0);
      // Total Debts = 2000 + 1000 = 3,000.0
      expect(result.totalDebtsAndLiabilities, 3000.0);
      // Net Wealth = 12,000.0
      expect(result.netWealth, 12000.0);
      // Silver Nisab = 612.36 * 1.0 = 612.36
      expect(result.isEligible, isTrue);
      // Zakat = 12,000 * 0.025 = 300.0
      expect(result.zakatDue, 300.0);
    });
  });

  group('Zakat Storage Service Tests', () {
    test('Persists and loads inputs across sessions', () async {
      final storage = ZakatStorageService();
      const input = ZakatInput(
        currency: 'AED',
        goldPricePerGram: 280.0,
        silverPricePerGram: 3.5,
        cashInHand: 50000.0,
      );

      await storage.saveZakatInput(input);
      final loaded = await storage.loadZakatInput();

      expect(loaded.currency, 'AED');
      expect(loaded.goldPricePerGram, 280.0);
      expect(loaded.silverPricePerGram, 3.5);
      expect(loaded.cashInHand, 50000.0);
    });

    test('clearInputsPreservingPrices clears asset/debt values but keeps rates and currency', () async {
      final storage = ZakatStorageService();
      const input = ZakatInput(
        currency: 'SAR',
        goldPricePerGram: 290.0,
        silverPricePerGram: 4.0,
        cashInHand: 70000.0,
        debts: 10000.0,
      );

      await storage.saveZakatInput(input);
      await storage.clearInputsPreservingPrices();
      final loaded = await storage.loadZakatInput();

      expect(loaded.currency, 'SAR');
      expect(loaded.goldPricePerGram, 290.0);
      expect(loaded.silverPricePerGram, 4.0);
      expect(loaded.cashInHand, 0.0);
      expect(loaded.debts, 0.0);
    });
  });

  group('Zakat UI & Responsive Flow Tests', () {
    Widget buildTestWidget({Locale locale = const Locale('en')}) {
      return ProviderScope(
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: [
            TestLocalizationsDelegate(locale),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ZakatCalculatorScreen(),
        ),
      );
    }

    testWidgets('ZakatCalculatorScreen renders on 360px without overflow in English', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Zakat Calculator'), findsOneWidget);
      expect(find.text('Gold & Silver Market Rates'), findsOneWidget);
      expect(find.text('Zakatable Assets'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Zakat Calculation Summary'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Zakat Calculation Summary'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ZakatCalculatorScreen renders in Arabic (RTL) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('حاسبة الزكاة'), findsOneWidget);
      expect(find.byType(ZakatCalculatorScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ZakatCalculatorScreen renders in Urdu (RTL) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('زکوٰۃ کیلکولیٹر'), findsOneWidget);
      expect(find.byType(ZakatCalculatorScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Info guidelines bottom sheet displays religious rules and disclaimer', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      final infoIcon = find.byIcon(Icons.info_outline_rounded);
      expect(infoIcon, findsOneWidget);
      await tester.tap(infoIcon);
      await tester.pumpAndSettle();

      expect(find.text('Zakat Guidelines & Rules'), findsOneWidget);
      expect(find.text('Zakat Rate: 2.5%'), findsOneWidget);
      expect(find.text('Exempt Items (Non-Zakatable)'), findsOneWidget);
    });
  });
}
