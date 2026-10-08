import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/theme/app_theme.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/quran/domain/models/surah.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/quran/domain/models/reciter.dart';
import 'package:muslim_ultra/features/quran/data/audio_url_builder.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';
import 'package:muslim_ultra/features/quran/data/quran_api_service.dart';
import 'package:muslim_ultra/features/quran/presentation/screens/surah_reader_screen.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/quran_providers.dart';

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

  group('EveryAyah CDN Audio URL Builder Tests (Spec §3 M2 Acceptance)', () {
    test('Correct URL mapping for Al-Fatiha 1:1 to 1:7', () {
      const reciter = 'Alafasy_128kbps';
      const surah = 1;

      final expectedUrls = [
        'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001002.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001003.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001004.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001005.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001006.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001007.mp3',
      ];

      for (int i = 1; i <= 7; i++) {
        final url = AudioUrlBuilder.buildAyahAudioUrl(
          reciterSubpath: reciter,
          surahNumber: surah,
          ayahNumber: i,
        );
        expect(url, expectedUrls[i - 1]);
      }
    });

    test('Correct URL mapping for Al-Baqarah 2:1 to 2:10', () {
      const reciter = 'Alafasy_128kbps';
      const surah = 2;

      final expectedUrls = [
        'https://everyayah.com/data/Alafasy_128kbps/002001.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002002.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002003.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002004.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002005.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002006.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002007.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002008.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002009.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002010.mp3',
      ];

      for (int i = 1; i <= 10; i++) {
        final url = AudioUrlBuilder.buildAyahAudioUrl(
          reciterSubpath: reciter,
          surahNumber: surah,
          ayahNumber: i,
        );
        expect(url, expectedUrls[i - 1]);
      }
    });

    test('Reciter subpath switching generates valid URLs', () {
      final reciters = ReciterModel.availableReciters;
      expect(reciters.length, greaterThanOrEqualTo(5));

      final abdulBasitUrl = AudioUrlBuilder.buildAyahAudioUrl(
        reciterSubpath: 'Abdul_Basit_Murattal_192kbps',
        surahNumber: 112,
        ayahNumber: 1,
      );
      expect(
        abdulBasitUrl,
        'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/112001.mp3',
      );

      final husaryUrl = AudioUrlBuilder.buildAyahAudioUrl(
        reciterSubpath: 'Husary_128kbps',
        surahNumber: 36,
        ayahNumber: 83,
      );
      expect(
        husaryUrl,
        'https://everyayah.com/data/Husary_128kbps/036083.mp3',
      );
    });
  });

  group('Tanzil Quran Structure & True Offline Bundle Tests', () {
    test('Contains exactly 114 Surahs sequentially numbered 1 to 114', () {
      final surahs = TanzilQuranData.allSurahs;
      expect(surahs.length, 114);

      for (int i = 0; i < 114; i++) {
        expect(surahs[i].number, i + 1);
        expect(surahs[i].name.isNotEmpty, isTrue);
        expect(surahs[i].englishName.isNotEmpty, isTrue);
        expect(surahs[i].numberOfAyahs, greaterThan(0));
      }

      expect(surahs[0].englishName, 'Al-Fatihah');
      expect(surahs[0].numberOfAyahs, 7);

      expect(surahs[1].englishName, 'Al-Baqarah');
      expect(surahs[1].numberOfAyahs, 286);

      expect(surahs[113].englishName, 'An-Nas');
      expect(surahs[113].numberOfAyahs, 6);
    });

    test('Contains exactly 30 Juz sequentially numbered 1 to 30', () {
      final juzList = TanzilQuranData.allJuz;
      expect(juzList.length, 30);

      for (int i = 0; i < 30; i++) {
        expect(juzList[i].number, i + 1);
        expect(juzList[i].nameArabic.isNotEmpty, isTrue);
        expect(juzList[i].nameEnglish.isNotEmpty, isTrue);
      }
    });

    test('Bundled Tanzil offline asset loads all 114 Surahs and 6236 total Ayahs', () async {
      final allSurahsMap = await TanzilQuranData.loadAllBundledSurahs();
      expect(allSurahsMap.length, 114);

      int totalAyahs = 0;
      for (int i = 1; i <= 114; i++) {
        final ayahs = allSurahsMap[i];
        expect(ayahs, isNotNull, reason: 'Surah $i must exist in offline bundle');
        expect(ayahs!.isNotEmpty, isTrue);
        expect(ayahs.length, TanzilQuranData.allSurahs[i - 1].numberOfAyahs);
        totalAyahs += ayahs.length;
      }
      expect(totalAyahs, 6236);
    });

    test('Al-Fatihah (Surah 1) loads 7 authentic distinct ayahs', () async {
      final ayahs = await TanzilQuranData.getBundledAyahs(1);
      expect(ayahs.length, 7);
      expect(ayahs[0].textUthmani, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
      expect(ayahs[1].textUthmani, 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ');
      expect(ayahs[6].textUthmani, 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ');
      expect(ayahs[0].translationEnglish, isNotEmpty);
      expect(ayahs[0].translationUrdu, isNotEmpty);
    });

    test('Ali Imran (Surah 3) loads 200 authentic distinct ayahs with NO fake placeholders', () async {
      final ayahs = await TanzilQuranData.getBundledAyahs(3);
      expect(ayahs.length, 200);

      // Ayah 1: Alif-Lam-Meem
      expect(ayahs[0].textUthmani.contains('الٓمٓ'), isTrue);
      expect(ayahs[0].translationEnglish, 'Alif, Lam, Meem.');

      // Ayah 2: Allahu la ilaha illa huwa al-Hayyu al-Qayyum
      expect(ayahs[1].textUthmani.contains('ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ'), isTrue);
      expect(ayahs[1].textUthmani.startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ﴿2﴾'), isFalse);

      // Verify no placeholder text anywhere in Surah 3
      for (final ayah in ayahs) {
        expect(ayah.textUthmani.contains('Full text loads via Tanzil reader'), isFalse);
        expect(ayah.translationEnglish.contains('Full text loads via Tanzil reader'), isFalse);
      }
    });

    test('Ya-Sin (Surah 36) loads 83 authentic distinct ayahs with NO fake placeholders', () async {
      final ayahs = await TanzilQuranData.getBundledAyahs(36);
      expect(ayahs.length, 83);
      expect(ayahs[0].textUthmani.contains('يسٓ'), isTrue);
      expect(ayahs[1].textUthmani.contains('وَٱلْقُرْءَانِ ٱلْحَكِيمِ'), isTrue);
    });

    test('Al-Ikhlas (Surah 112) loads 4 authentic distinct ayahs', () async {
      final ayahs = await TanzilQuranData.getBundledAyahs(112);
      expect(ayahs.length, 4);
      expect(ayahs[0].textUthmani.contains('قُلْ هُوَ ٱللَّهُ أَحَدٌ'), isTrue);
      expect(ayahs[1].textUthmani.contains('ٱللَّهُ ٱلصَّمَدُ'), isTrue);
      expect(ayahs[2].textUthmani.contains('لَمْ يَلِدْ وَلَمْ يُولَدْ'), isTrue);
      expect(ayahs[3].textUthmani.contains('وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ'), isTrue);
    });

    test('QuranApiService.fetchSurahAyahs falls back to offline bundle with zero network', () async {
      final ayahs = await QuranApiService.fetchSurahAyahs(67); // Al-Mulk (30 ayahs)
      expect(ayahs.length, 30);
      expect(ayahs[0].textUthmani.contains('تَبَٰرَكَ ٱلَّذِى بِيَدِهِ ٱلْمُلْكُ'), isTrue);
    });
  });

  group('Quran Reader UI & Error State Tests', () {
    Widget buildReaderApp({
      required ProviderContainer container,
      required SurahModel surah,
      Locale locale = const Locale('en'),
    }) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          localizationsDelegates: [
            TestLocalizationsDelegate(locale),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SurahReaderScreen(
            key: ValueKey('reader_${surah.number}_${locale.languageCode}'),
            surah: surah,
          ),
        ),
      );
    }

    testWidgets('SurahReaderScreen renders authentic ayahs and Bismillah header',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const surah = SurahModel(
        number: 112,
        name: 'الإخلاص',
        englishName: 'Al-Ikhlas',
        englishNameTranslation: 'The Sincerity',
        numberOfAyahs: 4,
        revelationType: 'Meccan',
        startJuz: 30,
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(buildReaderApp(container: container, surah: surah));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Bismillah Header
      expect(find.text('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'), findsWidgets);
      // Ayah 1
      expect(find.textContaining('قُلْ هُوَ ٱللَّهُ أَحَدٌ'), findsOneWidget);
      // Ayah 1:1 Tag
      expect(find.text('112:1'), findsOneWidget);
      // Ayah 112:4 Tag
      expect(find.text('112:4'), findsOneWidget);
      expect(find.textContaining('وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ'), findsOneWidget);
    });

    testWidgets('SurahReaderScreen shows honest error state with Retry button on load failure',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const surah = SurahModel(
        number: 3,
        name: 'آل عمران',
        englishName: 'Ali \'Imran',
        englishNameTranslation: 'Family of Imran',
        numberOfAyahs: 200,
        revelationType: 'Medinan',
        startJuz: 3,
      );

      final container = ProviderContainer(
        overrides: [
          surahAyahsProvider(surah.number).overrideWith((ref) => Future<List<AyahModel>>.error(
            Exception('Network offline & Bundle unavailable'),
          )),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildReaderApp(container: container, surah: surah));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Honest Error UI elements
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text("Couldn't load this Surah"), findsOneWidget);
      expect(find.text("Please check your internet connection and try again."), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, "Retry"), findsOneWidget);
    });

    testWidgets('SurahReaderScreen error state renders without overflow in 360x640 in EN, AR, and UR',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const surah = SurahModel(
        number: 36,
        name: 'يس',
        englishName: 'Ya-Sin',
        englishNameTranslation: 'Ya Sin',
        numberOfAyahs: 83,
        revelationType: 'Meccan',
        startJuz: 22,
      );

      final container = ProviderContainer(
        overrides: [
          surahAyahsProvider(surah.number).overrideWith((ref) => Future<List<AyahModel>>.error(
            Exception('Offline error'),
          )),
        ],
      );
      addTearDown(container.dispose);

      // 1. English Error State
      await tester.pumpWidget(
        buildReaderApp(container: container, surah: surah, locale: const Locale('en')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.text("Couldn't load this Surah"), findsOneWidget);

      // 2. Arabic Error State (RTL)
      await tester.pumpWidget(
        buildReaderApp(container: container, surah: surah, locale: const Locale('ar')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.text("تعذر تحميل هذه السورة"), findsOneWidget);
      expect(find.text("إعادة المحاولة"), findsOneWidget);

      // 3. Urdu Error State (RTL)
      await tester.pumpWidget(
        buildReaderApp(container: container, surah: surah, locale: const Locale('ur')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.text("یہ سورت لوڈ نہیں ہو سکی"), findsOneWidget);
      expect(find.text("دوبارہ کوشش کریں"), findsOneWidget);
    });
  });
}
