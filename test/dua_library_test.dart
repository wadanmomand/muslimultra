import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/main.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/dua/data/dua_repository.dart';
import 'package:muslim_ultra/features/dua/domain/models/dua_item.dart';
import 'package:muslim_ultra/features/dua/presentation/screens/dua_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<DuaItemModel> testDuas;

  setUpAll(() async {
    final file = File('assets/duas/duas.json');
    final content = await file.readAsString();
    final decoded = json.decode(content) as Map<String, dynamic>;
    final rawList = decoded['duas'] as List<dynamic>;
    testDuas = rawList.asMap().entries.map((e) => DuaItemModel.fromJson(e.value, e.key)).toList();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DuaRepository.setCacheForTesting(testDuas);
  });

  group('Dua Bundle & Data Layer Tests', () {
    test('JSON asset exists, is valid JSON and contains exactly 43 authentic duas', () async {
      final file = File('assets/duas/duas.json');
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      final decoded = json.decode(content) as Map<String, dynamic>;

      expect(decoded['meta']['count'], 43);
      final duasList = decoded['duas'] as List<dynamic>;
      expect(duasList.length, 43);

      for (var i = 0; i < duasList.length; i++) {
        final item = duasList[i] as Map<String, dynamic>;
        expect(item['ar'], isNotNull);
        expect((item['ar'] as String).trim().isNotEmpty, isTrue, reason: 'Dua #$i has empty Arabic');
        expect((item['ar'] as String).contains('...'), isFalse, reason: 'Dua #$i contains ... ellipsis');
        expect((item['ar'] as String).contains('…'), isFalse, reason: 'Dua #$i contains unicode ellipsis');

        expect(item['en'], isNotNull);
        expect((item['en'] as String).trim().isNotEmpty, isTrue, reason: 'Dua #$i has empty English');

        expect(item['ur'], isNotNull);
        expect((item['ur'] as String).trim().isNotEmpty, isTrue, reason: 'Dua #$i has empty Urdu');

        expect(item['ref'], isNotNull);
        expect((item['ref'] as String).trim().isNotEmpty, isTrue, reason: 'Dua #$i has empty Reference');

        expect(item['category'], isNotNull);
        expect((item['category'] as String).trim().isNotEmpty, isTrue, reason: 'Dua #$i has empty Category');
      }
    });

    test('DuaRepository parses 43 DuaItemModel objects and unique categories', () async {
      final duas = await DuaRepository.loadAllDuas();
      final categories = await DuaRepository.getCategories();

      expect(duas.length, 43);
      expect(categories.isNotEmpty, isTrue);
      expect(categories.contains('Morning & Evening Adhkar'), isTrue);
      expect(categories.contains('Breaking Fast (Iftar)'), isTrue);
      expect(categories.contains('Repentance'), isTrue);
    });

    test('Multi-language and reference search filtering logic', () async {
      final iftarDuas = await DuaRepository.filterDuas(query: 'thirst');
      expect(iftarDuas.length, 1);
      expect(iftarDuas.first.reference, 'Sunan Abi Dawud 2357');

      // Test Urdu search
      final urduDuas = await DuaRepository.filterDuas(query: 'پیاس');
      expect(urduDuas.length, 1);

      // Test Arabic search with and without diacritics
      final arabicExact = await DuaRepository.filterDuas(query: 'الظَّمَأُ');
      expect(arabicExact.length, 1);
      final arabicNormalized = await DuaRepository.filterDuas(query: 'الظمأ');
      expect(arabicNormalized.length, 1);

      // Test Reference search
      final bukhariDuas = await DuaRepository.filterDuas(query: 'bukhari');
      expect(bukhariDuas.isNotEmpty, isTrue);

      // Test Category filter
      final fastingDuas = await DuaRepository.filterDuas(category: 'Fasting');
      expect(fastingDuas.length, 1);
    });
  });

  group('DuaScreen Integration & 360px Tests', () {
    testWidgets('Full flow: Navigate to Dua tab, search, category filter, 360px layout', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MuslimUltraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Dua tab (index 3)
      container.read(bottomNavIndexProvider.notifier).state = 3;
      await tester.pumpAndSettle();

      expect(find.byType(DuaScreen), findsOneWidget);
      expect(find.text('Hisn-ul-Muslim'), findsOneWidget);
      expect(find.text('All Duas'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify search
      await tester.enterText(find.byType(TextField), 'thirst');
      await tester.pumpAndSettle();

      expect(find.textContaining('thirst has gone'), findsOneWidget);
      expect(find.text('Sunan Abi Dawud 2357'), findsOneWidget);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL Arabic and Urdu switching in Dua tab on 360px', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MuslimUltraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Arabic
      container.read(localeProvider.notifier).setLanguage('ar');
      container.read(bottomNavIndexProvider.notifier).state = 3;
      await tester.pumpAndSettle();

      expect(find.text('حصن المسلم'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch to Urdu
      container.read(localeProvider.notifier).setLanguage('ur');
      await tester.pumpAndSettle();

      expect(find.text('حصن المسلم'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
