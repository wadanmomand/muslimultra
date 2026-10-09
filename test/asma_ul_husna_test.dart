import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/asma/data/asma_repository.dart';
import 'package:muslim_ultra/features/asma/domain/models/asma_name.dart';
import 'package:muslim_ultra/features/asma/presentation/screens/asma_list_screen.dart';
import 'package:muslim_ultra/features/asma/presentation/screens/asma_detail_screen.dart';

late AppLocalizations testEnL10n;
late AppLocalizations testArL10n;
late AppLocalizations testUrL10n;
late List<AsmaName> testNames;
late AsmaMeta testMeta;

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

    final file = File('assets/asma/asma_ul_husna.json');
    final content = await file.readAsString();
    final decoded = json.decode(content) as Map<String, dynamic>;
    testMeta = AsmaMeta.fromJson(decoded['meta'] as Map<String, dynamic>);
    final rawList = decoded['names'] as List<dynamic>;
    testNames = rawList.map((item) => AsmaName.fromJson(item as Map<String, dynamic>)).toList();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AsmaRepository.setCacheForTesting(testNames, meta: testMeta);
  });

  group('Asma ul Husna Bundle & Data Layer Tests', () {
    test('JSON asset exists and contains exactly 99 names with Tirmidhi 3507 metadata', () {
      final file = File('assets/asma/asma_ul_husna.json');
      expect(file.existsSync(), isTrue);

      expect(testMeta.count, 99);
      expect(testMeta.source.contains('3507'), isTrue);
      expect(testNames.length, 99);
    });

    test('All 99 names are sequentially numbered 1..99 with complete fields in all languages', () {
      expect(testNames.first.n, 1);
      expect(testNames.first.ar, 'الله');
      expect(testNames.first.tr, 'Allah');

      expect(testNames.last.n, 99);
      expect(testNames.last.ar, 'الصبور');
      expect(testNames.last.tr, 'As-Sabur');

      for (var i = 0; i < testNames.length; i++) {
        final item = testNames[i];
        expect(item.n, i + 1, reason: 'Index ${i + 1} does not match name number ${item.n}');
        expect(item.ar.trim().isNotEmpty, isTrue, reason: 'Name #${item.n} has empty Arabic');
        expect(item.tr.trim().isNotEmpty, isTrue, reason: 'Name #${item.n} has empty Transliteration');
        expect(item.en.trim().isNotEmpty, isTrue, reason: 'Name #${item.n} has empty English');
        expect(item.ur.trim().isNotEmpty, isTrue, reason: 'Name #${item.n} has empty Urdu');
      }
    });

    test('Search matches across Arabic, Transliteration, English, and Urdu', () {
      final repo = AsmaRepository();

      // Search by Transliteration
      final matchTr = repo.searchNames(testNames, 'Rahman');
      expect(matchTr.any((n) => n.n == 2), isTrue);

      // Search by English
      final matchEn = repo.searchNames(testNames, 'Creator');
      expect(matchEn.any((n) => n.n == 12), isTrue); // Al-Khaliq

      // Search by Arabic
      final matchAr = repo.searchNames(testNames, 'القدوس');
      expect(matchAr.any((n) => n.n == 5), isTrue); // Al-Quddus

      // Search by Urdu
      final matchUr = repo.searchNames(testNames, 'سلامتی');
      expect(matchUr.any((n) => n.n == 6), isTrue); // As-Salam

      // Search by Number
      final matchNum = repo.searchNames(testNames, '99');
      expect(matchNum.length, 1);
      expect(matchNum.first.n, 99);
    });

    test('Repository saves and retrieves last viewed index in SharedPreferences', () async {
      final repo = AsmaRepository();
      await repo.saveLastViewedIndex(42);
      final loaded = await repo.getLastViewedIndex();
      expect(loaded, 42);
    });
  });

  group('Asma ul Husna UI & Navigation Flow Tests', () {
    Widget buildTestWidget({required Widget child, Locale locale = const Locale('en')}) {
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
          home: child,
        ),
      );
    }

    testWidgets('AsmaListScreen renders list on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(child: const AsmaListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Asma ul Husna'), findsOneWidget);
      expect(find.text('Allah'), findsOneWidget);
      expect(find.text('Ar-Rahman'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Search filters list correctly in AsmaListScreen', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const AsmaListScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Peace');
      await tester.pumpAndSettle();

      expect(find.text('As-Salam'), findsOneWidget);
      expect(find.text('The Source of Peace'), findsOneWidget);
      expect(find.text('Ar-Rahman'), findsNothing);
    });

    testWidgets('Tapping a name opens AsmaDetailScreen with calligraphy and meanings', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const AsmaListScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ar-Rahman'));
      await tester.pumpAndSettle();

      expect(find.byType(AsmaDetailScreen), findsOneWidget);
      expect(find.text('The Most Gracious'), findsOneWidget);
      expect(find.text('2 of 99'), findsOneWidget);
    });

    testWidgets('AsmaDetailScreen navigation buttons move between names', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: AsmaDetailScreen(initialIndex: 0, names: testNames),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Allah'), findsOneWidget);
      expect(find.text('1 of 99'), findsOneWidget);

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Ar-Rahman'), findsOneWidget);
      expect(find.text('2 of 99'), findsOneWidget);

      // Tap Previous
      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();

      expect(find.text('Allah'), findsOneWidget);
    });

    testWidgets('AsmaListScreen renders in Arabic (RTL) without overflow on 360px', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(child: const AsmaListScreen(), locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('أسماء الله الحسنى'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AsmaListScreen renders in Urdu (RTL) without overflow on 360px', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(child: const AsmaListScreen(), locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('اسمائے حسنیٰ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
