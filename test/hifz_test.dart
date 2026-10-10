import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_item.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_stats.dart';
import 'package:muslim_ultra/features/hifz/data/hifz_repository.dart';
import 'package:muslim_ultra/features/hifz/presentation/providers/hifz_providers.dart';
import 'package:muslim_ultra/features/hifz/presentation/screens/hifz_screen.dart';

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

    // Mock Quran Arabic text for test speed
    HifzRepository.setMockQuranCacheForTesting({
      '1:1': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      '1:2': 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
      '2:255': 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ',
    });
  });

  tearDownAll(() {
    HifzRepository.clearCacheForTesting();
  });

  group('Hifz Scheduler & Spaced Repetition Logic Tests', () {
    test('Remembered review advances stability through [1 -> 3 -> 7 -> 14 -> 30 -> 60 -> 120]',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = HifzRepository(prefs: prefs);

      // Start lesson: 1:1
      await repo.startLesson(1, 1, 1);
      var item = (await repo.getItem(1, 1))!;
      expect(item.stability, 1);
      expect(item.status, 1); // Learning

      // Review 1: 1 -> 3
      item = await repo.review(1, 1, true);
      expect(item.stability, 3);

      // Review 2: 3 -> 7 (status becomes memorized 2)
      item = await repo.review(1, 1, true);
      expect(item.stability, 7);
      expect(item.status, 2);

      // Review 3: 7 -> 14
      item = await repo.review(1, 1, true);
      expect(item.stability, 14);

      // Review 4: 14 -> 30
      item = await repo.review(1, 1, true);
      expect(item.stability, 30);

      // Review 5: 30 -> 60
      item = await repo.review(1, 1, true);
      expect(item.stability, 60);

      // Review 6: 60 -> 120 (capped at 120)
      item = await repo.review(1, 1, true);
      expect(item.stability, 120);

      // Review 7: stays at 120
      item = await repo.review(1, 1, true);
      expect(item.stability, 120);
    });

    test('Forgotten review resets stability to 1 and status back to learning (1)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = HifzRepository(prefs: prefs);

      // Setup an item with stability 60 and status 2 (memorized)
      await repo.setStatus(2, 255, 2);
      var item = await repo.review(2, 255, true); // stability becomes 14
      item = await repo.review(2, 255, true); // stability becomes 30

      expect(item.stability, 30);
      expect(item.status, 2);

      // Forget on review
      final resetItem = await repo.review(2, 255, false);
      expect(resetItem.stability, 1);
      expect(resetItem.status, 1); // Dropped back to learning
    });

    test('dueToday calculation and sorting by due date', () async {
      final oldDate = '2026-09-20';
      SharedPreferences.setMockInitialValues({
        HifzRepository.storageKey: jsonEncode({
          '1:1': {'status': 1, 'stability': 3, 'last': oldDate},
          '1:2': {'status': 1, 'stability': 1, 'last': oldDate},
        }),
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = HifzRepository(prefs: prefs);

      final dueItems = await repo.getDueTodayItems();
      expect(dueItems.length, 2);
      // Sorted by due date ascending
      expect(
        dueItems[0].dueDate.isBefore(dueItems[1].dueDate) ||
            dueItems[0].dueDate.isAtSameMomentAs(dueItems[1].dueDate),
        isTrue,
      );
    });

    test('Statistics calculation and sparse persistence round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = HifzRepository(prefs: prefs);

      await repo.startLesson(1, 1, 5); // 5 learning ayat
      await repo.setStatus(1, 1, 2); // 1 memorized

      final stats = await repo.getStats();
      expect(stats.memorizedCount, 1);
      expect(stats.learningCount, 4);
      expect(stats.streakDays, greaterThanOrEqualTo(1));
    });
  });

  Widget createTestWidget({
    required Widget child,
    Locale locale = const Locale('en'),
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
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

  group('HifzScreen UI & Tab Flow Tests', () {
    final mockItems = [
      HifzItem(
        surahNumber: 1,
        ayahNumber: 1,
        status: 1, // Learning
        stability: 1,
        lastReviewed: DateTime.now(),
        arabicText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        surahName: 'الفاتحة',
      ),
      HifzItem(
        surahNumber: 2,
        ayahNumber: 255,
        status: 2, // Memorized
        stability: 30,
        lastReviewed: DateTime.now().subtract(const Duration(days: 35)),
        arabicText: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ',
        surahName: 'البقرة',
      ),
    ];

    testWidgets('Renders HifzScreen with 3 tabs and starts new lesson', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hifzStatsProvider.overrideWith(
              (ref) => Future.value(
                const HifzStats(
                  memorizedCount: 1,
                  learningCount: 1,
                  dueCount: 1,
                  streakDays: 5,
                ),
              ),
            ),
            hifzSabqProvider.overrideWith((ref) => Future.value([mockItems[0]])),
            hifzSabqiProvider.overrideWith((ref) => Future.value([mockItems[0]])),
            hifzManzilProvider.overrideWith((ref) => Future.value([mockItems[1]])),
          ],
          child: const HifzScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hifz Tracker'), findsOneWidget);
      expect(find.text('1 due today'), findsOneWidget);
      expect(find.text('1 memorized'), findsOneWidget);
      expect(find.text('5d'), findsOneWidget);

      // Tab 1 (Sabq)
      expect(find.text('Start New Lesson (Sabq)'), findsOneWidget);
      expect(find.text('Add to Active Lessons'), findsOneWidget);
      expect(find.text('Al-Fatihah 1:1'), findsOneWidget);

      // Switch to Sabqi Tab
      await tester.tap(find.text('Sabqi (Recent)'));
      await tester.pumpAndSettle();
      expect(find.text('Al-Fatihah 1:1'), findsOneWidget);

      // Switch to Manzil Tab
      await tester.tap(find.text('Manzil (Revision)'));
      await tester.pumpAndSettle();
      expect(find.text('Al-Baqarah 2:255'), findsOneWidget);
    });

    testWidgets('360x640 responsive smoke test in Arabic (RTL) with 0 overflow errors',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          overrides: [
            hifzStatsProvider.overrideWith(
              (ref) => Future.value(
                const HifzStats(
                  memorizedCount: 1,
                  learningCount: 1,
                  dueCount: 1,
                  streakDays: 3,
                ),
              ),
            ),
            hifzSabqProvider.overrideWith((ref) => Future.value([mockItems[0]])),
          ],
          child: const HifzScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('متابع الحفظ'), findsOneWidget);
      expect(find.text('السبق (جديد)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('360x640 responsive smoke test in Urdu (RTL) with 0 overflow errors',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ur'),
          overrides: [
            hifzStatsProvider.overrideWith(
              (ref) => Future.value(
                const HifzStats(
                  memorizedCount: 1,
                  learningCount: 1,
                  dueCount: 1,
                  streakDays: 3,
                ),
              ),
            ),
            hifzSabqProvider.overrideWith((ref) => Future.value([mockItems[0]])),
          ],
          child: const HifzScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('حفظ ٹریکر'), findsOneWidget);
      expect(find.text('سبق (نیا)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
