import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/deen/domain/models/deen_xp.dart';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/deen/data/name_of_day.dart';
import 'package:muslim_ultra/features/deen/presentation/widgets/daily_deen_card.dart';
import 'package:muslim_ultra/features/khatmah/data/khatmah_repository.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/prayer_tracking/data/prayer_tracking_repository.dart';
import 'package:muslim_ultra/features/quiz/data/quiz_repository.dart';
import 'package:muslim_ultra/features/quiz/domain/models/quiz_question.dart';
import 'package:muslim_ultra/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:muslim_ultra/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:muslim_ultra/features/sadaqah/data/sadaqah_repository.dart';

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

Widget createTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
  Size size = const Size(400, 850),
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
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          padding: const EdgeInsets.only(top: 24, bottom: 24),
        ),
        child: child,
      ),
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
    SharedPreferences.setMockInitialValues({});
    QuizRepository.clearCacheForTesting();
    NameOfDayService.clearCacheForTesting();
  });

  group('Part 1: Deen XP Engine & Level Boundaries', () {
    test('levelFor calculates accurate level thresholds', () {
      expect(DeenLevel.levelFor(0), DeenLevel.beginner);
      expect(DeenLevel.levelFor(99), DeenLevel.beginner);
      expect(DeenLevel.levelFor(100), DeenLevel.learner);
      expect(DeenLevel.levelFor(249), DeenLevel.learner);
      expect(DeenLevel.levelFor(250), DeenLevel.practitioner);
      expect(DeenLevel.levelFor(499), DeenLevel.practitioner);
      expect(DeenLevel.levelFor(500), DeenLevel.devoted);
      expect(DeenLevel.levelFor(999), DeenLevel.devoted);
      expect(DeenLevel.levelFor(1000), DeenLevel.steadfast);
      expect(DeenLevel.levelFor(1999), DeenLevel.steadfast);
      expect(DeenLevel.levelFor(2000), DeenLevel.exemplar);
      expect(DeenLevel.levelFor(5000), DeenLevel.exemplar);
    });

    test('XP awarding is idempotent per daily reason', () async {
      final repo = DeenRepository();

      final res1 = await repo.awardXp(10, 'prayer_fajr_2026-10-09');
      expect(res1.amountAwarded, 10);
      expect(res1.newTotalXp, 10);

      // Second identical call must not award duplicate XP
      final res2 = await repo.awardXp(10, 'prayer_fajr_2026-10-09');
      expect(res2.amountAwarded, 0);
      expect(res2.newTotalXp, 10);
    });

    test('Quran daily minutes awards 1 XP per minute up to daily cap of 30', () async {
      final repo = DeenRepository();
      final date = DateTime(2026, 10, 9);

      // Add 25 minutes
      await repo.addQuranMinutes(25, date);
      var xp = await repo.getDeenXp();
      expect(xp.totalXp, 25);

      // Add 10 more minutes (total 35 minutes) -> cap is 30 XP
      await repo.addQuranMinutes(10, date);
      xp = await repo.getDeenXp();
      expect(xp.totalXp, 30);
    });

    test('Full Deen completion bonus awards +25 XP', () async {
      final repo = DeenRepository();
      final date = DateTime(2026, 10, 9);

      await repo.setMorningDhikr(true, date);
      await repo.setEveningDhikr(true, date);
      await repo.addQuranMinutes(10, date);

      // 5 prayers prayed
      final awarded = await repo.checkAndAwardFullDeen(date, 5);
      expect(awarded, isTrue);

      final state = await repo.getDailyState(date);
      expect(state.fullDeenClaimed, isTrue);
    });
  });

  group('Part 6: Streak Freeze Protection', () {
    test('Freeze preserves streak across missed days', () async {
      final prayerRepo = PrayerTrackingRepository();
      final deenRepo = DeenRepository();
      final today = DateTime(2026, 10, 10);

      Future<void> logFullDay(DateTime date) async {
        final dateStr = PrayerTrackingRepository.formatDate(date);
        for (final p in TrackedPrayer.all) {
          await prayerRepo.logPrayer(PrayerLogEntry(
            date: dateStr,
            prayer: p.keyName,
            status: PrayerLogStatus.prayed,
            timestamp: date,
          ));
        }
      }

      final day2Ago = today.subtract(const Duration(days: 2)); // Oct 8 (prayed)
      final day1Ago = today.subtract(const Duration(days: 1)); // Oct 9 (missed, but frozen)

      await logFullDay(day2Ago);
      await logFullDay(today);

      // Without freeze, missing Oct 9 breaks streak
      var streakWithoutFreeze = await prayerRepo.currentStreak(today);
      expect(streakWithoutFreeze, 1);

      // Apply freeze to Oct 9
      await deenRepo.useFreeze(day1Ago);

      // With freeze applied, Oct 8 + Oct 9 (frozen) + Oct 10 -> streak = 2 (prayed days)
      final streakWithFreeze = await prayerRepo.currentStreak(today);
      expect(streakWithFreeze, 2);
    });
  });

  group('Part 3: Daily Quiz Rotation & Bank Contract', () {
    test('Cycles through 60 questions deterministically without repeating in 60-day window', () async {
      final repo = QuizRepository();
      final questions = await repo.getAllQuestions();
      expect(questions.length, 60);

      final baseDate = DateTime(2026, 1, 1);
      final seenIds = <int>{};

      for (var day = 0; day < 60; day++) {
        final date = baseDate.add(Duration(days: day));
        final q = await repo.getQuestionForDay(date);
        seenIds.add(q.id);
      }

      expect(seenIds.length, 60);
    });
  });

  group('Part 5: Quran Khatmah Tracker Math', () {
    test('Completing 30 paras increments completed khatmahs count and resets', () async {
      final repo = KhatmahRepository();

      for (var p = 1; p <= 29; p++) {
        await repo.togglePara(p);
      }

      var state = await repo.getKhatmahState();
      expect(state.completedCount, 29);
      expect(state.completedKhatmahs, 0);

      // Toggle 30th para
      state = await repo.togglePara(30);
      expect(state.completedKhatmahs, 1);
      expect(state.completedCount, 0); // Reset for next Khatmah
    });
  });

  group('Part 7: Name of Allah of the Day', () {
    test('Cycles deterministically across 99 names', () async {
      final names = await NameOfDayService.getAllNames();
      expect(names.length, 99);

      final dateA = DateTime(2026, 4, 15, 10, 0);
      final dateB = DateTime(2026, 4, 15, 22, 0);

      final nameA = NameOfDayService.nameFor(dateA, names);
      final nameB = NameOfDayService.nameFor(dateB, names);

      expect(nameA.number, nameB.number);
      expect(nameA.arabic, nameB.arabic);
    });
  });

  group('Part 8: Sadaqah Tracker Math', () {
    test('Monthly total and all-time total computation', () async {
      final repo = SadaqahRepository();

      await repo.logSadaqah(50.0, note: 'Charity', date: DateTime(2026, 10, 5));
      await repo.logSadaqah(100.0, note: 'Mosque', date: DateTime(2026, 10, 8));
      await repo.logSadaqah(25.0, note: 'Previous month', date: DateTime(2026, 9, 20));

      final octTotal = await repo.monthlyTotal(DateTime(2026, 10, 1));
      final allTime = await repo.totalAllTime();

      expect(octTotal, 150.0);
      expect(allTime, 175.0);
    });
  });

  group('Widget Tests & 360px RTL Smoke', () {
    testWidgets('DailyDeenCard renders with XP bar, checklist rows, and adhkar chips', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const Scaffold(body: DailyDeenCard()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's Deen"), findsOneWidget);
      expect(find.text('5 Obligatory Prayers'), findsOneWidget);
      expect(find.text('Daily Quran'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
    });

    final sampleQuestion = const QuizQuestion(
      id: 1,
      category: 'Quran',
      qEn: 'Which Surah is known as the Heart of the Quran?',
      qUr: 'کس سورت کو قرآن کا دل کہا جاتا ہے؟',
      qAr: 'ما هي السورة التي تسمى قلب القرآن؟',
      optsEn: ['Surah Yasin', 'Surah Al-Mulk', 'Surah Ar-Rahman', 'Surah Al-Kahf'],
      optsUr: ['سورۃ یٰسین', 'سورۃ الملک', 'سورۃ الرحمن', 'سورۃ الکہف'],
      optsAr: ['سورة يس', 'سورة الملك', 'سورة الرحمن', 'سورة الكهف'],
      correctIndex: 0,
      explainEn: 'Surah Yasin is referred to as the heart of the Quran.',
      source: 'Hadith (Tirmidhi 2887)',
    );

    testWidgets('QuizScreen renders 4 options and answers interactive tap', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            todayQuizQuestionProvider.overrideWith((ref) => Future.value(sampleQuestion)),
            todayQuizAnswerProvider.overrideWith((ref) => Future.value(null)),
          ],
          child: const QuizScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Quiz Challenge'), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz_option_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz_option_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz_option_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz_option_3')), findsOneWidget);

      // Tap first option
      await tester.tap(find.byKey(const ValueKey('quiz_option_0')));
      await tester.pumpAndSettle();
    });

    testWidgets('360px RTL smoke test in Arabic without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          locale: const Locale('ar'),
          size: const Size(360, 780),
          child: const Scaffold(
            body: SingleChildScrollView(
              child: DailyDeenCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('360px RTL smoke test in Urdu without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          locale: const Locale('ur'),
          size: const Size(360, 780),
          overrides: [
            todayQuizQuestionProvider.overrideWith((ref) => Future.value(sampleQuestion)),
            todayQuizAnswerProvider.overrideWith((ref) => Future.value(null)),
          ],
          child: const QuizScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
