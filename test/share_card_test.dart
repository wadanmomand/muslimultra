import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/share_card/presentation/widgets/ayah_share_card.dart';
import 'package:muslim_ultra/features/share_card/presentation/widgets/ayah_share_preview_dialog.dart';

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

  const ayahKursi = AyahModel(
    surahNumber: 2,
    numberInSurah: 255,
    numberInQuran: 262,
    juz: 3,
    page: 42,
    textUthmani:
        'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُۥ سِنَةٌۭ وَلَا نَوْمٌۭ ۚ لَّهُۥ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ',
    translationEnglish:
        'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep.',
    translationUrdu:
        'اللہ وہ ذات ہے کہ اس کے سوا کوئی معبود نہیں، وہ ہمیشہ زندہ رہنے والا، سب کا سنبھالنے والا ہے',
  );

  const shortAyahIkhlas = AyahModel(
    surahNumber: 112,
    numberInSurah: 1,
    numberInQuran: 6222,
    juz: 30,
    page: 604,
    textUthmani: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
    translationEnglish: 'Say, "He is Allah, [who is] One,',
    translationUrdu: 'آپ کہئے کہ وہ اللہ ایک ہے',
  );

  group('AyahShareCard Widget Tests', () {
    testWidgets('Renders long ayah (2:255 Ayat al-Kursi) with reference, Arabic, translation and watermark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            TestLocalizationsDelegate(Locale('en')),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const Scaffold(
            body: Center(
              child: AyahShareCard(
                ayah: ayahKursi,
                surahName: 'Al-Baqarah',
                languageCode: 'en',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Surah Reference line
      expect(find.textContaining('Al-Baqarah • 2:255'), findsOneWidget);

      // Arabic Text
      expect(find.textContaining('ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ'), findsOneWidget);

      // Translation Text
      expect(find.textContaining('Allah - there is no deity except Him'), findsOneWidget);

      // Watermark
      expect(find.text('Muslim Ultra'), findsOneWidget);

      tester.takeException();
    });

    testWidgets('Renders short ayah (112:1 Al-Ikhlas) correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            TestLocalizationsDelegate(Locale('en')),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const Scaffold(
            body: Center(
              child: AyahShareCard(
                ayah: shortAyahIkhlas,
                surahName: 'Al-Ikhlas',
                languageCode: 'en',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Al-Ikhlas • 112:1'), findsOneWidget);
      expect(find.textContaining('قُلْ هُوَ ٱللَّهُ أَحَدٌ'), findsOneWidget);
      expect(find.textContaining('Say, "He is Allah, [who is] One,'), findsOneWidget);
      expect(find.text('Muslim Ultra'), findsOneWidget);

      tester.takeException();
    });

    testWidgets('AyahSharePreviewDialog opens with preview and share button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            TestLocalizationsDelegate(Locale('en')),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('btn_open_dialog'),
                  onPressed: () {
                    AyahSharePreviewDialog.show(
                      ctx,
                      ayah: ayahKursi,
                      surahName: 'Al-Baqarah',
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('btn_open_dialog')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AyahSharePreviewDialog), findsOneWidget);
      expect(find.text('Share Quran Card'), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_share_card_export')), findsOneWidget);

      tester.takeException();
    });

    testWidgets('360px RTL smoke test on AyahShareCard in Arabic', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: AyahShareCard(
                  ayah: shortAyahIkhlas,
                  surahName: 'الإخلاص',
                  languageCode: 'ar',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AyahShareCard), findsOneWidget);
      expect(find.textContaining('الإخلاص • 112:1'), findsOneWidget);

      tester.takeException();
    });
  });
}
