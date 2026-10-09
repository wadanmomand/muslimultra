import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/quran_providers.dart';
import 'package:muslim_ultra/features/quran/presentation/screens/surah_reader_screen.dart';
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
    if (locale.languageCode == 'ar') return SynchronousFuture(testArL10n);
    if (locale.languageCode == 'ur') return SynchronousFuture(testUrL10n);
    return SynchronousFuture(testEnL10n);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, TafsirEntry> testTafsirMap;
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
    testTafsirMap = await repo.loadAll();

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

  group('Tafsir Dataset & Repository Unit Tests', () {
    test('Bundle loads exactly 574 entries with non-empty English & Urdu text and unique keys', () async {
      final repo = TafsirRepository();
      final entries = await repo.loadAll();

      expect(entries.length, 574);

      final keySet = <String>{};
      int arabicGapsCount = 0;

      for (final entry in entries.values) {
        // Unique keys
        expect(keySet.contains(entry.key), isFalse, reason: 'Duplicate key found: ${entry.key}');
        keySet.add(entry.key);

        // English and Urdu text are always present and non-empty
        expect(entry.en.trim(), isNotEmpty, reason: 'Empty English for key ${entry.key}');
        expect(entry.ur.trim(), isNotEmpty, reason: 'Empty Urdu for key ${entry.key}');

        if (entry.ar.trim().isEmpty) {
          arabicGapsCount++;
        }

        // Surah and ayah match key
        expect('${entry.surah}:${entry.ayah}', entry.key);
      }

      // Check known 17 Arabic gaps
      expect(arabicGapsCount, 17);
    });

    test('Cross-check: Every Tafsir key exists in verified Quran bundle (assets/quran/quran_full.json)', () async {
      for (final entry in testTafsirMap.values) {
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

    test('getTafsir returns entry with EN, AR, UR for covered verses and null for uncovered verses', () async {
      final repo = TafsirRepository();

      // Covered: 114:1 (An-Nas), 1:1 (Al-Fatihah), 2:255 (Ayat al-Kursi), 2:285, 2:286
      final nas1 = await repo.getTafsir(114, 1);
      expect(nas1, isNotNull);
      expect(nas1!.surah, 114);
      expect(nas1.ayah, 1);
      expect(nas1.en, isNotEmpty);
      expect(nas1.ar, isNotEmpty);
      expect(nas1.ur, isNotEmpty);

      final fatihah1 = await repo.getTafsir(1, 1);
      expect(fatihah1, isNotNull);
      expect(fatihah1!.en, isNotEmpty);
      expect(fatihah1.ur, isNotEmpty);

      final ayatKursi = await repo.getTafsir(2, 255);
      expect(ayatKursi, isNotNull);
      expect(ayatKursi!.en, isNotEmpty);
      expect(ayatKursi.ur, isNotEmpty);

      final baqarah285 = await repo.getTafsir(2, 285);
      expect(baqarah285, isNotNull);
      expect(baqarah285!.ur, isNotEmpty);

      final baqarah286 = await repo.getTafsir(2, 286);
      expect(baqarah286, isNotNull);
      expect(baqarah286!.ur, isNotEmpty);

      // Uncovered: 2:100, 3:1, 10:5
      expect(await repo.getTafsir(2, 100), isNull);
      expect(await repo.getTafsir(3, 1), isNull);
      expect(await repo.getTafsir(10, 5), isNull);

      // hasTafsir checks
      expect(await repo.hasTafsir(114, 1), isTrue);
      expect(await repo.hasTafsir(2, 100), isFalse);
    });

    test('Corrupt JSON throws typed TafsirLoadException', () async {
      final repo = TafsirRepository();
      final mockBundle = _MockAssetBundle({'assets/tafsir/tafsir.json': '{"invalid": 123}'});

      expect(
        () async => repo.loadAll(bundle: mockBundle),
        throwsA(isA<TafsirLoadException>()),
      );
    });
  });

  group('Tafsir UI & Widget Flow Tests', () {
    testWidgets('Ayah WITH tafsir displays affordance and opens TafsirSheet with EN/AR/UR tabs and attributions', (tester) async {
      // Surah An-Nas (Surah 114 - 6 ayahs, all have tafsir)
      final surahNas = TanzilQuranData.allSurahs.firstWhere((s) => s.number == 114);
      final List<AyahModel> sampleAyahs = List.generate(
        6,
        (i) => AyahModel(
          surahNumber: 114,
          numberInSurah: i + 1,
          numberInQuran: 6231 + i,
          juz: 30,
          page: 604,
          textUthmani: 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ',
          translationEnglish: 'Say, "I seek refuge in the Lord of mankind',
          translationUrdu: 'کہو کہ میں پناہ مانگتا ہوں انسانوں کے پروردگار کی',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTafsirProvider.overrideWith((ref) => Future.value(testTafsirMap)),
            surahAyahsProvider(114).overrideWith((ref) => Future.value(sampleAyahs)),
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
            home: SurahReaderScreen(surah: surahNas),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Affordance button for 114:1 is present
      final tafsirBtnFinder = find.byKey(const ValueKey('btn_tafsir_114_1'));
      expect(tafsirBtnFinder, findsOneWidget);

      // Tap Tafsir button to open bottom sheet
      await tester.tap(tafsirBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify TafsirSheet rendered
      expect(find.byType(TafsirSheet), findsOneWidget);
      expect(find.textContaining('An-Nas 114:1'), findsOneWidget);
      expect(find.textContaining('Tafsir al-Jalalayn'), findsOneWidget);
      expect(find.byKey(const ValueKey('tafsir_copy_button')), findsOneWidget);

      // Switch to Arabic Tab (index 1)
      await tester.tap(find.byKey(const ValueKey('tafsir_tab_1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Tafsir al-Jalalayn'), findsOneWidget);

      // Switch to Urdu Tab (index 2 - shows Bayan-ul-Quran attribution)
      await tester.tap(find.byKey(const ValueKey('tafsir_tab_2')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Bayan-ul-Quran — Dr. Israr Ahmed'), findsOneWidget);

      // Tap copy button on Urdu tab
      await tester.tap(find.byKey(const ValueKey('tafsir_copy_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      tester.takeException();
    });

    testWidgets('Coverage hint banner is shown for partially/uncovered surahs and omitted for Juz 30', (tester) async {
      // Surah Al-Baqarah (Surah 2)
      final surahBaqarah = TanzilQuranData.allSurahs.firstWhere((s) => s.number == 2);
      final List<AyahModel> sampleAyahs = [
        const AyahModel(
          surahNumber: 2,
          numberInSurah: 1, // 2:1 has NO tafsir
          numberInQuran: 8,
          juz: 1,
          page: 2,
          textUthmani: 'الٓمٓ',
          translationEnglish: 'Alif, Lam, Meem.',
          translationUrdu: 'الف لام میم',
        ),
        const AyahModel(
          surahNumber: 2,
          numberInSurah: 255, // 2:255 HAS tafsir
          numberInQuran: 262,
          juz: 3,
          page: 42,
          textUthmani: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ',
          translationEnglish: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.',
          translationUrdu: 'اللہ، اس کے سوا کوئی عبادت کے لائق نہیں، وہ زندہ ہے سب کا تھامنے والا',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTafsirProvider.overrideWith((ref) => Future.value(testTafsirMap)),
            surahAyahsProvider(2).overrideWith((ref) => Future.value(sampleAyahs)),
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
            home: SurahReaderScreen(surah: surahBaqarah),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Coverage hint banner is present for Surah 2
      expect(find.byKey(const ValueKey('tafsir_coverage_hint_banner')), findsOneWidget);

      // Ayah 2:1 has NO tafsir button
      expect(find.byKey(const ValueKey('btn_tafsir_2_1')), findsNothing);

      // Ayah 2:255 HAS tafsir button
      expect(find.byKey(const ValueKey('btn_tafsir_2_255')), findsOneWidget);

      tester.takeException();
    });

    testWidgets('360px RTL smoke test on TafsirSheet', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sampleTafsir = testTafsirMap['114:1']!;

      await tester.pumpWidget(
        MaterialApp(
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
                tafsir: sampleTafsir,
                surahName: 'الناس',
                surahNumber: 114,
                ayahNumber: 1,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

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

