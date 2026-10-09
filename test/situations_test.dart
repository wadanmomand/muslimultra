import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/situations/data/situations_repository.dart';
import 'package:muslim_ultra/features/situations/domain/models/situation.dart';
import 'package:muslim_ultra/features/situations/presentation/providers/situations_providers.dart';
import 'package:muslim_ultra/features/situations/presentation/screens/situations_screen.dart';

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

  late List<SituationModel> testSituations;
  late Map<int, int> quranSurahAyahCounts;

  setUpAll(() async {
    testEnL10n = AppLocalizations(const Locale('en'));
    await testEnL10n.load();
    testArL10n = AppLocalizations(const Locale('ar'));
    await testArL10n.load();
    testUrL10n = AppLocalizations(const Locale('ur'));
    await testUrL10n.load();

    SituationsRepository.clearCacheForTesting();
    final repo = SituationsRepository();
    testSituations = await repo.getAllSituations();

    // Load authentic Quran bundle for cross-check
    final quranJsonStr = await rootBundle.loadString('assets/quran/quran_full.json');
    final quranDecoded = json.decode(quranJsonStr) as Map<String, dynamic>;
    final surahsList = quranDecoded['surahs'] as List;
    quranSurahAyahCounts = {
      for (final s in surahsList)
        (s['number'] as int): (s['ayahs'] as List).length,
    };
  });

  setUp(() {
    SituationsRepository.clearCacheForTesting();
  });

  group('Situations Dataset & Repository Unit Tests', () {
    test('Dataset contains exactly 8 situations with unique IDs and non-empty trilingual fields', () {
      expect(testSituations.length, 8);

      final idSet = <String>{};
      for (final s in testSituations) {
        expect(idSet.contains(s.id), isFalse, reason: 'Duplicate ID: ${s.id}');
        idSet.add(s.id);

        expect(s.titleEn.trim(), isNotEmpty);
        expect(s.titleAr.trim(), isNotEmpty);
        expect(s.titleUr.trim(), isNotEmpty);

        expect(s.comfortEn.trim(), isNotEmpty);
        expect(s.comfortAr.trim(), isNotEmpty);
        expect(s.comfortUr.trim(), isNotEmpty);

        expect(s.dhikrEn.trim(), isNotEmpty);
        expect(s.dhikrAr.trim(), isNotEmpty);
        expect(s.dhikrUr.trim(), isNotEmpty);

        expect(s.ayat, isNotEmpty);
      }
    });

    test('Cross-check: Every Ayat reference exists in authentic assets/quran/quran_full.json', () {
      for (final s in testSituations) {
        for (final ref in s.ayat) {
          expect(
            quranSurahAyahCounts.containsKey(ref.surah),
            isTrue,
            reason: 'Surah ${ref.surah} in situation ${s.id} not found in Quran bundle',
          );
          final totalAyahs = quranSurahAyahCounts[ref.surah]!;
          expect(
            ref.ayah >= 1 && ref.ayah <= totalAyahs,
            isTrue,
            reason: 'Ayah ${ref.ayah} for Surah ${ref.surah} in situation ${s.id} exceeds total ($totalAyahs)',
          );
        }
      }
    });

    test('Corrupt JSON throws typed SituationsLoadException', () async {
      final repo = SituationsRepository();
      final mockBundle = _MockAssetBundle({'assets/situations/situations.json': '{"invalid": 123}'});

      expect(
        () async => repo.getAllSituations(bundle: mockBundle),
        throwsA(isA<SituationsLoadException>()),
      );
    });
  });

  group('Situations UI & Widget Flow Tests', () {
    testWidgets('SituationsScreen renders 8 cards and opens SituationDetailScreen', (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allSituationsProvider.overrideWith((ref) => Future.value(testSituations)),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              TestLocalizationsDelegate(Locale('en')),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const SituationsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Title & 8 cards rendered
      expect(find.text('Life Situations Guide'), findsOneWidget);
      expect(find.text('Grief & Loss'), findsOneWidget);
      expect(find.text('Anxiety & Worry'), findsOneWidget);
      expect(find.text('Debt & Financial Hardship'), findsOneWidget);
      expect(find.text('Illness'), findsOneWidget);

      // Tap Grief & Loss card
      final griefCard = find.byKey(const ValueKey('situation_card_grief'));
      expect(griefCard, findsOneWidget);
      await tester.tap(griefCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Detail Screen is open
      expect(find.text('Words of Comfort'), findsOneWidget);
      expect(find.textContaining('Losing someone you love'), findsOneWidget);
      expect(find.text('Recommended Dua & Dhikr'), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_copy_situation_dhikr')), findsOneWidget);

      // Tap copy dhikr button
      await tester.tap(find.byKey(const ValueKey('btn_copy_situation_dhikr')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      tester.takeException();
    });

    testWidgets('360px RTL smoke test on SituationsScreen in Arabic', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allSituationsProvider.overrideWith((ref) => Future.value(testSituations)),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              TestLocalizationsDelegate(Locale('ar')),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: SituationsScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SituationsScreen), findsOneWidget);
      expect(find.text('دليل مواقف الحياة'), findsOneWidget);
      expect(find.text('الحزن والفقد'), findsOneWidget);

      tester.takeException();
    });
  });
}

class _MockAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  _MockAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
    throw FlutterError('Unable to load asset: $key');
  }
}
