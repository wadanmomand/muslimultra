import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/quran/domain/models/surah.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/quran/domain/models/tajweed_rule.dart';
import 'package:muslim_ultra/features/quran/data/tajweed_repository.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/quran_providers.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/tajweed_providers.dart';
import 'package:muslim_ultra/features/quran/presentation/screens/surah_reader_screen.dart';
import 'package:muslim_ultra/features/quran/presentation/widgets/tajweed_legend_sheet.dart';
import 'package:muslim_ultra/features/quran/presentation/widgets/tajweed_ayah_text.dart';

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
    TajweedRepository.clearCacheForTesting();
  });

  group('Tajweed Rules & Color Palette Spec Tests', () {
    test('Exactly 18 Tajweed rules are registered', () {
      expect(TajweedRuleType.values.length, 18);
    });

    test('Zero green or emerald colors used in Tajweed palette', () {
      for (final rule in TajweedRuleType.values) {
        final darkCol = rule.darkColor;
        final lightCol = rule.lightColor;

        // Ensure not green-dominant (e.g. green channel significantly exceeding red and blue)
        final isDarkGreenish = (darkCol.g * 255).round() > 180 &&
            (darkCol.r * 255).round() < 120 &&
            (darkCol.b * 255).round() < 120;
        final isLightGreenish = (lightCol.g * 255).round() > 180 &&
            (lightCol.r * 255).round() < 120 &&
            (lightCol.b * 255).round() < 120;

        expect(isDarkGreenish, isFalse, reason: '${rule.id} dark color is green');
        expect(isLightGreenish, isFalse, reason: '${rule.id} light color is green');
      }
    });

    test('Index and Id lookup works bidirectionally', () {
      expect(TajweedRuleType.fromIndex(0), TajweedRuleType.ghunnah);
      expect(TajweedRuleType.fromIndex(16), TajweedRuleType.qalqalah);
      expect(TajweedRuleType.fromId('lam_shamsiyyah'), TajweedRuleType.lamShamsiyyah);
      expect(TajweedRuleType.fromId('madd_6'), TajweedRuleType.madd6);
    });
  });

  group('TajweedSpanBuilder Unit Tests', () {
    const baseStyle = TextStyle(color: Colors.white, fontSize: 20);

    test('Empty text returns empty span list', () {
      final spans = TajweedSpanBuilder.buildSpans(
        rawText: '',
        annotations: const [],
        isDark: true,
        baseStyle: baseStyle,
      );
      expect(spans, isEmpty);
    });

    test('Empty annotations returns single plain text span', () {
      const text = 'بِسْمِ ٱللَّهِ';
      final spans = TajweedSpanBuilder.buildSpans(
        rawText: text,
        annotations: const [],
        isDark: true,
        baseStyle: baseStyle,
      );
      expect(spans.length, 1);
      expect((spans.first as TextSpan).text, text);
      expect((spans.first as TextSpan).style?.color, baseStyle.color);
    });

    test('Applies colors to annotated ranges', () {
      const text = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      final annotations = [
        const TajweedAnnotation(rule: TajweedRuleType.hamzatWasl, start: 7, end: 8),
        const TajweedAnnotation(rule: TajweedRuleType.lamShamsiyyah, start: 16, end: 17),
      ];

      final spans = TajweedSpanBuilder.buildSpans(
        rawText: text,
        annotations: annotations,
        isDark: true,
        baseStyle: baseStyle,
      );

      expect(spans.length, greaterThan(1));
      // First chunk is plain text (indices 0..6)
      expect((spans[0] as TextSpan).style?.color, baseStyle.color);
      // Second chunk is hamzat wasl (index 7)
      expect((spans[1] as TextSpan).style?.color, TajweedRuleType.hamzatWasl.darkColor);
    });

    test('Overlapping annotations: later-starting rule wins', () {
      // Text with 10 characters
      const text = 'abcdefghij';
      // Ann1: 2..8 (rule Qalqalah)
      // Ann2: 4..6 (rule Ikhfa, later start)
      final annotations = [
        const TajweedAnnotation(rule: TajweedRuleType.qalqalah, start: 2, end: 8),
        const TajweedAnnotation(rule: TajweedRuleType.ikhfa, start: 4, end: 6),
      ];

      final spans = TajweedSpanBuilder.buildSpans(
        rawText: text,
        annotations: annotations,
        isDark: true,
        baseStyle: baseStyle,
      );

      // Slices:
      // 0..2: plain 'ab'
      // 2..4: qalqalah 'cd'
      // 4..6: ikhfa 'ef' (later-starting rule won)
      // 6..8: qalqalah 'gh'
      // 8..10: plain 'ij'
      expect(spans.length, 5);
      expect((spans[0] as TextSpan).text, 'ab');
      expect((spans[1] as TextSpan).text, 'cd');
      expect((spans[1] as TextSpan).style?.color, TajweedRuleType.qalqalah.darkColor);
      expect((spans[2] as TextSpan).text, 'ef');
      expect((spans[2] as TextSpan).style?.color, TajweedRuleType.ikhfa.darkColor);
      expect((spans[3] as TextSpan).text, 'gh');
      expect((spans[3] as TextSpan).style?.color, TajweedRuleType.qalqalah.darkColor);
      expect((spans[4] as TextSpan).text, 'ij');
    });

    test('Out-of-range and negative indices do not crash and clamp safely', () {
      const text = 'hello';
      final annotations = [
        const TajweedAnnotation(rule: TajweedRuleType.ghunnah, start: -5, end: 2),
        const TajweedAnnotation(rule: TajweedRuleType.iqlab, start: 3, end: 100),
      ];

      final spans = TajweedSpanBuilder.buildSpans(
        rawText: text,
        annotations: annotations,
        isDark: true,
        baseStyle: baseStyle,
      );

      expect(spans, isNotEmpty);
      expect(spans.map((s) => (s as TextSpan).text).join(''), text);
    });

    test('Strips leading U+FEFF without misaligning indices', () {
      const text = '\uFEFFبِسْمِ ٱللَّهِ';
      final annotations = [
        const TajweedAnnotation(rule: TajweedRuleType.hamzatWasl, start: 7, end: 8),
      ];

      final spans = TajweedSpanBuilder.buildSpans(
        rawText: text,
        annotations: annotations,
        isDark: true,
        baseStyle: baseStyle,
      );

      expect(spans, isNotEmpty);
      expect(spans.map((s) => (s as TextSpan).text).join('').startsWith('\uFEFF'), isFalse);
    });
  });

  group('Tajweed Asset File Verification', () {
    test('Bundle asset is present, valid JSON, with >= 64,000 total annotations', () async {
      final file = File('assets/tajweed/tajweed.json');
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      final rules = meta['rules'] as List<dynamic>;
      expect(rules.length, 18);

      final totalAnnotations = meta['total_annotations'] as int;
      expect(totalAnnotations, greaterThanOrEqualTo(64000));

      final ayahs = data['ayahs'] as List<dynamic>;
      expect(ayahs.length, greaterThan(6000));
    });
  });

  group('Tajweed State & Persistence', () {
    test('TajweedEnabledNotifier toggles and persists', () async {
      final notifier = TajweedEnabledNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state, isTrue); // default true

      await notifier.toggle();
      expect(notifier.state, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('tajweed_color_mode_enabled'), isFalse);

      await notifier.setEnabled(true);
      expect(notifier.state, isTrue);
      expect(prefs.getBool('tajweed_color_mode_enabled'), isTrue);
    });
  });

  group('Tajweed UI & Widget Tests', () {
    Widget buildTestWidget({
      required Widget child,
      Locale locale = const Locale('en'),
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
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

    testWidgets('TajweedAyahText renders colored rich text when enabled and plain when disabled',
        (tester) async {
      const text = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      const annotations = [
        TajweedAnnotation(rule: TajweedRuleType.hamzatWasl, start: 7, end: 8),
        TajweedAnnotation(rule: TajweedRuleType.lamShamsiyyah, start: 16, end: 17),
      ];

      // Enabled
      await tester.pumpWidget(
        buildTestWidget(
          child: const Scaffold(
            body: TajweedAyahText(
              textUthmani: text,
              annotations: annotations,
              isTajweedEnabled: true,
              isDark: true,
              fontSize: 24,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsOneWidget);
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.textSpan, isNotNull);
      expect((textWidget.textSpan! as TextSpan).children, isNotEmpty);

      // Disabled -> plain text
      await tester.pumpWidget(
        buildTestWidget(
          child: const Scaffold(
            body: TajweedAyahText(
              textUthmani: text,
              annotations: annotations,
              isTajweedEnabled: false,
              isDark: true,
              fontSize: 24,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final plainWidget = tester.widget<Text>(find.byType(Text));
      expect(plainWidget.data, text);
    });

    testWidgets('TajweedLegendSheet shows rules and all 18 rules are localized in en/ar/ur',
        (tester) async {
      // Verify all 18 rules have non-empty name and description in all 3 languages
      for (final rule in TajweedRuleType.values) {
        expect(testEnL10n.getTajweedRuleName(rule.id), isNotEmpty);
        expect(testEnL10n.getTajweedRuleDescription(rule.id), isNotEmpty);
        expect(testArL10n.getTajweedRuleName(rule.id), isNotEmpty);
        expect(testArL10n.getTajweedRuleDescription(rule.id), isNotEmpty);
        expect(testUrL10n.getTajweedRuleName(rule.id), isNotEmpty);
        expect(testUrL10n.getTajweedRuleDescription(rule.id), isNotEmpty);
      }

      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => TajweedLegendSheet.show(ctx),
                child: const Text('Open Legend'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Legend'));
      await tester.pumpAndSettle();

      expect(find.byType(TajweedLegendSheet), findsOneWidget);
      expect(find.text('Tajweed Rules & Colors'), findsOneWidget);
      expect(find.text('Qalqalah'), findsOneWidget);
      expect(find.text('Ghunnah'), findsOneWidget);
    });

    testWidgets('TajweedLegendSheet renders cleanly in Arabic (RTL) on 360px without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ar'),
          child: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => TajweedLegendSheet.show(ctx),
                child: const Text('Open Legend'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Legend'));
      await tester.pumpAndSettle();

      expect(find.text('أحكام التجويد وألوانها'), findsOneWidget);
      expect(find.text('قَلْقَلَة'), findsOneWidget);
      expect(find.text('غُنَّة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TajweedLegendSheet renders cleanly in Urdu (RTL) on 360px without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ur'),
          child: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => TajweedLegendSheet.show(ctx),
                child: const Text('Open Legend'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Legend'));
      await tester.pumpAndSettle();

      expect(find.text('تجوید کے قواعد اور رنگ'), findsOneWidget);
      expect(find.text('قلقلہ'), findsOneWidget);
      expect(find.text('غنہ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SurahReaderScreen contains Tajweed toggle and opens TajweedLegendSheet',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const fatihah = SurahModel(
        number: 1,
        name: 'الفاتحة',
        englishName: 'Al-Fatihah',
        englishNameTranslation: 'The Opening',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
        startJuz: 1,
      );

      final mockAyahs = [
        const AyahModel(
          numberInSurah: 1,
          numberInQuran: 1,
          surahNumber: 1,
          textUthmani: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          translationEnglish:
              'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            surahAyahsProvider(1).overrideWith((ref) => Future.value(mockAyahs)),
          ],
          child: const SurahReaderScreen(surah: fatihah),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find Tajweed toggle
      final tajweedToggle = find.byKey(const ValueKey('toggle_tajweed_mode'));
      expect(tajweedToggle, findsOneWidget);

      // Toggle Tajweed mode
      await tester.tap(tajweedToggle);
      await tester.pump();

      // Tap info button to open legend
      final legendBtn = find.byKey(const ValueKey('btn_tajweed_legend'));
      expect(legendBtn, findsOneWidget);
      await tester.tap(legendBtn);
      await tester.pumpAndSettle();

      expect(find.byType(TajweedLegendSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
