import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/tafsir/data/tafsir_repository.dart';
import 'package:muslim_ultra/features/tafsir/domain/models/tafsir_entry.dart';
import 'package:muslim_ultra/features/tafsir/presentation/providers/tafsir_providers.dart';
import 'package:muslim_ultra/features/tafsir/presentation/widgets/tafsir_sheet.dart';

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
    if (l.languageCode == 'ar' || locale.languageCode == 'ar') return SynchronousFuture(testArL10n);
    if (l.languageCode == 'ur' || locale.languageCode == 'ur') return SynchronousFuture(testUrL10n);
    return SynchronousFuture(testEnL10n);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, TafsirEntry> testMuyassarMap;
  late Map<String, TafsirEntry> testJalalaynMap;
  late Map<int, int> quranSurahAyahCounts;

  setUpAll(() async {
    testEnL10n = AppLocalizations(const Locale('en'));
    await testEnL10n.load();
    testArL10n = AppLocalizations(const Locale('ar'));
    await testArL10n.load();
    testUrL10n = AppLocalizations(const Locale('ur'));
    await testUrL10n.load();

    TafsirRepository.clearCacheForTesting();
    final repo = TafsirRepository();
    testMuyassarMap = await repo.loadMuyassar();
    testJalalaynMap = await repo.loadAll();

    // Load quran_full.json to verify every tafsir key against authentic Quran bundle
    final quranJsonStr = await rootBundle.loadString('assets/quran/quran_full.json');
    final quranDecoded = json.decode(quranJsonStr) as Map<String, dynamic>;
    final surahsList = quranDecoded['surahs'] as List;
    quranSurahAyahCounts = {
      for (final s in surahsList)
        (s['number'] as int): (s['ayahs'] as List).length,
    };
  });

  setUp(() {
    TafsirRepository.clearCacheForTesting();
  });

  group('Tafsir al-Muyassar Repository & Dataset Tests', () {
    test('Bundle loads exactly 857 entries with non-empty Arabic text and unique keys', () async {
      final repo = TafsirRepository();
      final entries = await repo.loadMuyassar();

      expect(entries.length, 857);

      final keySet = <String>{};
      for (final entry in entries.values) {
        // Unique keys
        expect(keySet.contains(entry.key), isFalse, reason: 'Duplicate key found: ${entry.key}');
        keySet.add(entry.key);

        // Arabic text is always present and non-empty
        expect(entry.ar.trim(), isNotEmpty, reason: 'Empty Arabic for key ${entry.key}');
        expect(entry.hasArabic, isTrue);

        // Surah and ayah match key
        expect('${entry.surah}:${entry.ayah}', entry.key);
      }
    });

    test('Cross-check: Every Muyassar Tafsir key exists in authentic Quran bundle (assets/quran/quran_full.json)', () async {
      for (final entry in testMuyassarMap.values) {
        expect(
          quranSurahAyahCounts.containsKey(entry.surah),
          isTrue,
          reason: 'Tafsir surah ${entry.surah} does not exist in Quran bundle',
        );

        final totalAyahsInSurah = quranSurahAyahCounts[entry.surah]!;
        expect(
          entry.ayah >= 1 && entry.ayah <= totalAyahsInSurah,
          isTrue,
          reason: 'Tafsir key ${entry.key} has invalid ayah ${entry.ayah} (Surah total: $totalAyahsInSurah)',
        );
      }
    });

    test('getTafsir with TafsirSource.muyassar retrieves correct verse commentary', () async {
      final repo = TafsirRepository();

      // Covered in Muyassar: 1:1, 2:1, 2:286, 78:1, 114:1..6
      final fatihah1 = await repo.getTafsir(1, 1, source: TafsirSource.muyassar);
      expect(fatihah1, isNotNull);
      expect(fatihah1!.ar, contains('أبتدئ قراءة القرآن باسم الله'));

      final baqarah1 = await repo.getTafsir(2, 1, source: TafsirSource.muyassar);
      expect(baqarah1, isNotNull);
      expect(baqarah1!.ar, isNotEmpty);

      final nas6 = await repo.getTafsir(114, 6, source: TafsirSource.muyassar);
      expect(nas6, isNotNull);
      expect(nas6!.ar, isNotEmpty);

      // Uncovered in Muyassar (e.g. Surah 3 Ali 'Imran is not in 39 surahs)
      final aliImran1 = await repo.getTafsir(3, 1, source: TafsirSource.muyassar);
      expect(aliImran1, isNull);

      // hasTafsir checks
      expect(await repo.hasTafsir(1, 1, source: TafsirSource.muyassar), isTrue);
      expect(await repo.hasTafsir(3, 1, source: TafsirSource.muyassar), isFalse);
    });

    test('Corrupt JSON throws typed TafsirLoadException for loadMuyassar', () async {
      final repo = TafsirRepository();
      final mockBundle = _MockAssetBundle({'assets/tafsir/tafsir_muyassar.json': '{"invalid": 123}'});

      expect(
        () async => repo.loadMuyassar(bundle: mockBundle),
        throwsA(isA<TafsirLoadException>()),
      );
    });
  });

  group('TafsirSheet Source Switching UI Tests', () {
    testWidgets('Switching between Jalalayn and Al-Muyassar updates body, notice and attribution', (tester) async {
      final sampleJalalayn = testJalalaynMap['1:1']!;
      final sampleMuyassar = testMuyassarMap['1:1']!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTafsirProvider.overrideWith((ref) => Future.value(testJalalaynMap)),
            allMuyassarTafsirProvider.overrideWith((ref) => Future.value(testMuyassarMap)),
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
            home: Scaffold(
              body: TafsirSheet(
                tafsir: sampleJalalayn,
                muyassarTafsir: sampleMuyassar,
                surahName: 'Al-Fatihah',
                surahNumber: 1,
                ayahNumber: 1,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Initial state: Jalalayn selected, English tab active
      expect(find.byKey(const ValueKey('tafsir_source_toggle_jalalayn')), findsOneWidget);
      expect(find.byKey(const ValueKey('tafsir_source_toggle_muyassar')), findsOneWidget);
      expect(find.textContaining('Tafsir al-Jalalayn'), findsOneWidget);

      // Tap on Al-Muyassar source toggle
      await tester.tap(find.byKey(const ValueKey('tafsir_source_toggle_muyassar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Notice for English locale: "(Available in Arabic only for this source)"
      expect(find.byKey(const ValueKey('tafsir_muyassar_arabic_only_note')), findsOneWidget);

      // Attribution footer updated
      expect(find.textContaining('Tafsir al-Muyassar'), findsOneWidget);

      // Arabic text rendered
      expect(find.byKey(const ValueKey('tafsir_muyassar_text')), findsOneWidget);

      // Copy button taps without error
      await tester.tap(find.byKey(const ValueKey('tafsir_copy_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      tester.takeException();
    });

    testWidgets('360px RTL smoke test on TafsirSheet with Muyassar source', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sampleJalalayn = testJalalaynMap['114:1']!;
      final sampleMuyassar = testMuyassarMap['114:1']!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTafsirProvider.overrideWith((ref) => Future.value(testJalalaynMap)),
            allMuyassarTafsirProvider.overrideWith((ref) => Future.value(testMuyassarMap)),
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
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: TafsirSheet(
                  tafsir: sampleJalalayn,
                  muyassarTafsir: sampleMuyassar,
                  surahName: 'الناس',
                  surahNumber: 114,
                  ayahNumber: 1,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Muyassar
      await tester.tap(find.byKey(const ValueKey('tafsir_source_toggle_muyassar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // In Arabic locale, no need for the "Arabic only" note
      expect(find.byKey(const ValueKey('tafsir_muyassar_arabic_only_note')), findsNothing);
      expect(find.byType(TafsirSheet), findsOneWidget);

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
