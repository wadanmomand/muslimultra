import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/hadith/domain/models/hadith_entry.dart';
import 'package:muslim_ultra/features/hadith/data/hadith_repository.dart';
import 'package:muslim_ultra/features/hadith/presentation/providers/hadith_providers.dart';
import 'package:muslim_ultra/features/hadith/presentation/screens/hadith_library_screen.dart';
import 'package:muslim_ultra/features/hadith/presentation/screens/hadith_detail_screen.dart';
import 'package:muslim_ultra/features/hadith/presentation/widgets/hadith_card.dart';

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

Widget buildTestWidget({
  required Widget child,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ur'),
      ],
      localizationsDelegates: [
        TestLocalizationsDelegate(locale),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
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
    HadithRepository.clearCacheForTesting();
  });

  group('Hadith Dataset & Bundle Verification Tests', () {
    test('Bundle asset is present, valid JSON, and has exactly 42 Hadith', () {
      final file = File('assets/hadith/hadith.json');
      expect(file.existsSync(), isTrue, reason: 'assets/hadith/hadith.json must exist');

      final content = file.readAsStringSync();
      final decoded = json.decode(content) as Map<String, dynamic>;
      expect(decoded.containsKey('hadith'), isTrue);

      final list = decoded['hadith'] as List;
      expect(list.length, 42, reason: 'Must contain exactly 42 Hadiths');

      for (var i = 0; i < list.length; i++) {
        final item = list[i] as Map<String, dynamic>;
        expect(item['number'], i + 1);
        expect((item['title_en'] as String).trim().isNotEmpty, isTrue);
        expect((item['source'] as String).trim().isNotEmpty, isTrue);
        expect((item['arabic'] as String).trim().isNotEmpty, isTrue);
        expect((item['english'] as String).trim().isNotEmpty, isTrue);
        expect((item['urdu'] as String).trim().isNotEmpty, isTrue);
        expect(item['categories'], isA<List>());
      }
    });

    test('parseHadithJson correctly builds HadithEntry models and extracts categories', () {
      final file = File('assets/hadith/hadith.json');
      final content = file.readAsStringSync();

      final entries = HadithRepository.parseHadithJson(content);
      expect(entries.length, 42);
      expect(entries.first.number, 1);
      expect(entries.first.titleEn, 'Actions Are By Intention');
      expect(entries.first.narrator, 'ʿUmar bin al-Khaṭṭāb');
      expect(entries.first.source, contains('al-Bukhārī'));
      expect(entries.last.number, 42);
    });

    test('Repository throws HadithLoadException on corrupted or empty JSON', () {
      expect(
        () => HadithRepository.parseHadithJson('{}'),
        throwsA(isA<HadithLoadException>()),
      );

      expect(
        () => HadithRepository.parseHadithJson('{"hadith": []}'),
        throwsA(isA<HadithLoadException>()),
      );

      expect(
        () => HadithRepository.parseHadithJson('{"hadith": [{"number": 1, "arabic": ""}]}'),
        throwsA(isA<HadithLoadException>()),
      );
    });
  });

  group('Hadith Search & Category Filter Logic Tests', () {
    late List<HadithEntry> allEntries;

    setUp(() {
      final file = File('assets/hadith/hadith.json');
      allEntries = HadithRepository.parseHadithJson(file.readAsStringSync());
    });

    test('Search finds Hadith 1 by English "intention"', () async {
      final results = await HadithRepository.search('intention');
      expect(results.any((h) => h.number == 1), isTrue);
    });

    test('Search finds Hadith 1 by exact Arabic "النِّيَّات"', () async {
      final results = await HadithRepository.search('النِّيَّات');
      expect(results.any((h) => h.number == 1), isTrue);
    });

    test('Search finds Hadith 1 by normalized Arabic without tashkeel "النيات"', () async {
      final results = await HadithRepository.search('النيات');
      expect(results.any((h) => h.number == 1), isTrue);
    });

    test('Search finds Hadith by narrator (e.g. "Abu Hurairah" / "Abū Hurayrah")', () async {
      final results = await HadithRepository.search('Hurayrah');
      expect(results.isNotEmpty, isTrue);
    });

    test('Search by sequential number "#2" or "2"', () async {
      final results = await HadithRepository.search('#2');
      expect(results.length, 1);
      expect(results.first.number, 2);
    });

    test('Category filter returns non-empty for "character"', () async {
      final results = await HadithRepository.byCategory('character');
      expect(results.isNotEmpty, isTrue);
      for (final h in results) {
        expect(h.categories.map((c) => c.toLowerCase()), contains('character'));
      }
    });

    test('Category filter combined with search works accurately', () async {
      final results = await HadithRepository.search('Muslim', category: 'pillars');
      expect(results.isNotEmpty, isTrue);
      for (final h in results) {
        expect(h.categories.map((c) => c.toLowerCase()), contains('pillars'));
      }
    });

    test('HadithEntry equality and hashCode', () {
      final h1 = allEntries[0];
      final h1Copy = HadithEntry(
        number: h1.number,
        titleEn: h1.titleEn,
        narrator: h1.narrator,
        source: h1.source,
        categories: List.from(h1.categories),
        arabic: h1.arabic,
        english: h1.english,
        urdu: h1.urdu,
      );

      expect(h1, equals(h1Copy));
      expect(h1.hashCode, equals(h1Copy.hashCode));
    });
  });

  group('Hadith UI & Widget Tests', () {
    late List<HadithEntry> sampleHadiths;

    setUp(() {
      final file = File('assets/hadith/hadith.json');
      sampleHadiths = HadithRepository.parseHadithJson(file.readAsStringSync());
    });

    testWidgets('HadithCard renders number, title, narrator, source, and arabic snippet',
        (tester) async {
      final hadith = sampleHadiths[0];
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: Scaffold(
            body: HadithCard(
              hadith: hadith,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Actions Are By Intention'), findsOneWidget);
      expect(find.textContaining('ʿUmar bin al-Khaṭṭāb'), findsOneWidget);
      expect(find.textContaining('al-Bukhārī'), findsOneWidget);
      expect(find.textContaining('عَنْ أَمِيرِ الْمُؤْمِنِينَ'), findsOneWidget);

      await tester.tap(find.byType(HadithCard));
      expect(tapped, isTrue);
    });

    testWidgets('HadithLibraryScreen renders list of cards and category chips',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            hadithListProvider.overrideWith((ref) => Future.value(sampleHadiths)),
            hadithCategoriesProvider.overrideWith(
                (ref) => Future.value(['intention', 'worship', 'character', 'pillars'])),
            filteredHadithProvider.overrideWith((ref) {
              final query = ref.watch(hadithSearchQueryProvider);
              final category = ref.watch(hadithCategoryFilterProvider);
              return HadithRepository.search(query, category: category);
            }),
          ],
          child: const HadithLibraryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('hadith_search_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('hadith_card_1')), findsOneWidget);
      expect(find.text('Actions Are By Intention'), findsOneWidget);

      // Tap on Category Chip "Intention"
      final intentionChip = find.byKey(const ValueKey('category_chip_intention'));
      expect(intentionChip, findsOneWidget);
      await tester.tap(intentionChip);
      await tester.pumpAndSettle();

      // Hadith 1 should be present
      expect(find.text('Actions Are By Intention'), findsOneWidget);

      // Reset to All
      final allChip = find.byKey(const ValueKey('category_chip_all'));
      expect(allChip, findsOneWidget);
      await tester.tap(allChip);
      await tester.pumpAndSettle();

      // Search field test
      await tester.enterText(find.byKey(const ValueKey('hadith_search_field')), 'Five Pillars');
      await tester.pumpAndSettle();

      expect(find.text('The Five Pillars of Islām'), findsOneWidget);
    });

    testWidgets('HadithDetailScreen displays Arabic, English, Urdu and copy action works',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final hadith = sampleHadiths[0];

      await tester.pumpWidget(
        buildTestWidget(
          child: HadithDetailScreen(
            hadith: hadith,
            allHadiths: sampleHadiths.take(3).toList(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Actions Are By Intention'), findsOneWidget);
      expect(find.text('Arabic Text'), findsOneWidget);
      expect(find.text('English Translation'), findsOneWidget);
      expect(find.text('Urdu Translation'), findsOneWidget);
      expect(find.textContaining('ʿUmar bin al-Khaṭṭāb'), findsOneWidget);

      // Tap Copy action in AppBar
      final copyAction = find.byKey(const ValueKey('hadith_detail_copy_action'));
      expect(copyAction, findsOneWidget);
      await tester.tap(copyAction);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Hadith copied to clipboard'), findsOneWidget);

      // Test next button
      final nextBtn = find.byKey(const ValueKey('btn_next_hadith'));
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('The Levels of the Religion'), findsOneWidget);
    });

    testWidgets('HadithLibraryScreen renders cleanly in Arabic (RTL) without overflow on 360px',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ar'),
          overrides: [
            hadithListProvider.overrideWith((ref) => Future.value(sampleHadiths)),
            hadithCategoriesProvider.overrideWith(
                (ref) => Future.value(['intention', 'worship', 'character'])),
            filteredHadithProvider.overrideWith((ref) => Future.value(sampleHadiths)),
          ],
          child: const HadithLibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مكتبة الحديث'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HadithLibraryScreen renders cleanly in Urdu (RTL) without overflow on 360px',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ur'),
          overrides: [
            hadithListProvider.overrideWith((ref) => Future.value(sampleHadiths)),
            hadithCategoriesProvider.overrideWith(
                (ref) => Future.value(['intention', 'worship', 'character'])),
            filteredHadithProvider.overrideWith((ref) => Future.value(sampleHadiths)),
          ],
          child: const HadithLibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('حدیث لائبریری'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
