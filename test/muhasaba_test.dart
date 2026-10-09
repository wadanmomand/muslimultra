import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/muhasaba/data/muhasaba_repository.dart';
import 'package:muslim_ultra/features/muhasaba/domain/models/muhasaba_questions.dart';
import 'package:muslim_ultra/features/muhasaba/presentation/providers/muhasaba_providers.dart';
import 'package:muslim_ultra/features/muhasaba/presentation/screens/muhasaba_screen.dart';

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Muhasaba Domain & Questions Tests', () {
    test('Six fixed questions with valid IDs and non-empty EN/AR/UR translations', () {
      expect(MuhasabaQuestions.list.length, 6);

      final expectedIds = ['q1', 'q2', 'q3', 'q4', 'q5', 'q6'];
      for (int i = 0; i < 6; i++) {
        final q = MuhasabaQuestions.list[i];
        expect(q.id, expectedIds[i]);
        expect(q.en.trim(), isNotEmpty);
        expect(q.ar.trim(), isNotEmpty);
        expect(q.ur.trim(), isNotEmpty);

        expect(q.getText('en'), q.en);
        expect(q.getText('ar'), q.ar);
        expect(q.getText('ur'), q.ur);

        expect(MuhasabaQuestions.byId(expectedIds[i]), isNotNull);
      }
      expect(MuhasabaQuestions.byId('non_existent'), isNull);
    });

    test('MuhasabaEntry completion and answer validation', () {
      final incompleteEntry = MuhasabaEntry(
        date: '2026-10-09',
        answers: {'q1': 2, 'q2': 1, 'q3': 0},
      );
      expect(incompleteEntry.isCompleted, isFalse);
      expect(incompleteEntry.answeredCount, 3);
      expect(incompleteEntry.getAnswer('q1'), 2);
      expect(incompleteEntry.getAnswer('q4'), isNull);

      final completeEntry = MuhasabaEntry(
        date: '2026-10-09',
        answers: {'q1': 2, 'q2': 1, 'q3': 0, 'q4': 2, 'q5': 1, 'q6': 2},
      );
      expect(completeEntry.isCompleted, isTrue);
      expect(completeEntry.answeredCount, 6);

      // JSON serialization round-trip
      final jsonMap = completeEntry.toJson();
      final fromJson = MuhasabaEntry.fromJson(jsonMap);
      expect(fromJson.date, '2026-10-09');
      expect(fromJson.isCompleted, isTrue);
      expect(fromJson.answers['q1'], 2);
    });
  });

  group('MuhasabaRepository Unit Tests', () {
    test('saveEntry and getEntry round-trip with sanitized answers', () async {
      final repo = MuhasabaRepository();

      await repo.saveEntry('2026-10-09', {
        'q1': 2,
        'q2': 1,
        'q3': 0,
        'q4': null,
        'q5': 99, // invalid, should sanitize to null
      });

      final entry = await repo.getEntry('2026-10-09');
      expect(entry, isNotNull);
      expect(entry!.date, '2026-10-09');
      expect(entry.answers['q1'], 2);
      expect(entry.answers['q2'], 1);
      expect(entry.answers['q3'], 0);
      expect(entry.answers['q4'], isNull);
      expect(entry.answers['q5'], isNull);
      expect(entry.isCompleted, isFalse);
      expect(entry.answeredCount, 3);
    });

    test('getWeekEntries returns exactly 7 slots for the last 7 days', () async {
      final repo = MuhasabaRepository();
      final refDate = DateTime(2026, 10, 9);

      // Save entries for 10-08 and 10-09
      await repo.saveEntry('2026-10-08', {'q1': 2, 'q2': 2, 'q3': 2, 'q4': 2, 'q5': 2, 'q6': 2});
      await repo.saveEntry('2026-10-09', {'q1': 1, 'q2': 1, 'q3': 1, 'q4': 1, 'q5': 1, 'q6': 1});

      final week = await repo.getWeekEntries(refDate);
      expect(week.length, 7);

      expect(week[6], isNotNull); // 10-09
      expect(week[6]!.date, '2026-10-09');
      expect(week[6]!.isCompleted, isTrue);

      expect(week[5], isNotNull); // 10-08
      expect(week[5]!.date, '2026-10-08');

      expect(week[0], isNull); // 10-03 (no entry)
    });

    test('completionStreak counts consecutive days with all 6 answered', () async {
      final repo = MuhasabaRepository();
      final refDate = DateTime(2026, 10, 9);

      // Save 3 consecutive days
      final fullAnswers = {'q1': 2, 'q2': 2, 'q3': 2, 'q4': 2, 'q5': 2, 'q6': 2};
      await repo.saveEntry('2026-10-07', fullAnswers);
      await repo.saveEntry('2026-10-08', fullAnswers);
      await repo.saveEntry('2026-10-09', fullAnswers);

      final streak = await repo.completionStreak(refDate);
      expect(streak, 3);

      // Incomplete day breaks streak
      await repo.saveEntry('2026-10-08', {'q1': 2}); // broke day 8
      final brokenStreak = await repo.completionStreak(refDate);
      expect(brokenStreak, 1);
    });

    test('Corrupt JSON throws typed MuhasabaLoadException', () async {
      SharedPreferences.setMockInitialValues({
        MuhasabaRepository.keyMuhasabaStorage: '{"invalid": "corrupt structure}',
      });

      final repo = MuhasabaRepository();
      expect(
        () async => repo.getEntry('2026-10-09'),
        throwsA(isA<MuhasabaLoadException>()),
      );
    });
  });

  group('XP Engine Integration Tests', () {
    test('Award 5 XP when Muhasaba completed with 6 answers', () async {
      final deenRepo = DeenRepository();

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final todayStr = MuhasabaRepository.formatDate(DateTime.now());
      final notifier = container.read(muhasabaFormNotifierProvider(todayStr).notifier);

      // Answer all 6
      for (final q in MuhasabaQuestions.list) {
        notifier.setAnswer(q.id, 2);
      }

      final saved = await notifier.save();
      expect(saved, isTrue);

      final deenXp = await deenRepo.getDeenXp();
      expect(deenXp.totalXp, 5);

      // Saving again does not double-award (idempotent XP)
      await notifier.save();
      final deenXp2 = await deenRepo.getDeenXp();
      expect(deenXp2.totalXp, 5);
    });
  });

  group('Muhasaba UI & Widget Flow Tests', () {
    testWidgets('MuhasabaScreen renders 6 questions, allows selecting options, and saves entry', (tester) async {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              TestLocalizationsDelegate(Locale('en')),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const MuhasabaScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Title & Privacy badge rendered
      expect(find.text('Muhasaba'), findsOneWidget);
      expect(find.text('Private — stays on your device.'), findsOneWidget);

      // 6 questions rendered
      expect(find.text('Did I pray all five prayers on time today?'), findsOneWidget);
      expect(find.text('Did I guard my tongue from hurtful or backbiting words?'), findsOneWidget);
      expect(find.text('Did I recite or read some of the Quran today?'), findsOneWidget);
      expect(find.text('Was I kind and respectful to my parents and family?'), findsOneWidget);
      expect(find.text('Did I earn honestly and avoid what Allah dislikes?'), findsOneWidget);
      expect(find.text('Did I remember Allah with dhikr or istighfar today?'), findsOneWidget);

      // Select 'Yes' (2) for q1
      final q1Yes = find.byKey(const ValueKey('option_q1_2'));
      expect(q1Yes, findsOneWidget);
      await tester.tap(q1Yes);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Select 'Partly' (1) for q2
      final q2Partly = find.byKey(const ValueKey('option_q2_1'));
      expect(q2Partly, findsOneWidget);
      await tester.tap(q2Partly);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Progress updated to "2 of 6 answered"
      expect(find.text('2 of 6 answered'), findsOneWidget);

      // Tap Save button
      final saveBtn = find.byKey(const ValueKey('btn_save_muhasaba'));
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // SnackBar shown
      expect(find.text('Reflection saved securely'), findsOneWidget);

      // Toggle reminder dialog
      final reminderBtn = find.byKey(const ValueKey('btn_muhasaba_reminder_toggle'));
      expect(reminderBtn, findsOneWidget);
      await tester.tap(reminderBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Nightly Muhasaba Reminder'), findsWidgets);

      tester.takeException();
    });

    testWidgets('360px RTL smoke test on MuhasabaScreen in Arabic', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
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
              child: MuhasabaScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MuhasabaScreen), findsOneWidget);
      expect(find.text('المحاسبة'), findsOneWidget);

      tester.takeException();
    });
  });
}
