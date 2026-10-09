import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/prayer/domain/models/prayer_time.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fast_log_entry.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fasting_countdown_state.dart';
import 'package:muslim_ultra/features/fasting/domain/models/ramadan_checklist.dart';
import 'package:muslim_ultra/features/fasting/data/fasting_repository.dart';
import 'package:muslim_ultra/features/fasting/presentation/screens/fasting_dashboard_screen.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/fasting_today_card.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/fasting_stats_row.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/fasting_log_list.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/log_fast_dialog.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/quick_actions.dart';

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

  group('Fasting Countdown State Logic (All 3 Phases)', () {
    final fajr = DateTime(2026, 4, 15, 4, 30);
    final maghrib = DateTime(2026, 4, 15, 18, 45);

    test('1. Before Fajr -> beforeSuhoor state targeting Fajr', () {
      final now = DateTime(2026, 4, 15, 3, 15); // 1h 15m before Fajr
      final state = FastingCountdownState.compute(
        now: now,
        fajr: fajr,
        maghrib: maghrib,
      );

      expect(state.stage, FastingCountdownStage.beforeSuhoor);
      expect(state.isBeforeSuhoor, isTrue);
      expect(state.isFastingHours, isFalse);
      expect(state.isCompleted, isFalse);
      expect(state.targetTime, fajr);
      expect(state.remainingDuration, const Duration(hours: 1, minutes: 15));
      expect(state.formattedCountdown, '01:15:00');
      expect(state.progressFraction, 0.0);
    });

    test('2. Between Fajr and Maghrib -> fasting state targeting Maghrib', () {
      final now = DateTime(2026, 4, 15, 12, 00); // midday
      final state = FastingCountdownState.compute(
        now: now,
        fajr: fajr,
        maghrib: maghrib,
      );

      expect(state.stage, FastingCountdownStage.fasting);
      expect(state.isBeforeSuhoor, isFalse);
      expect(state.isFastingHours, isTrue);
      expect(state.isCompleted, isFalse);
      expect(state.targetTime, maghrib);
      expect(state.remainingDuration, const Duration(hours: 6, minutes: 45));
      expect(state.formattedCountdown, '06:45:00');
      expect(state.progressFraction, greaterThan(0.0));
      expect(state.progressFraction, lessThan(1.0));
    });

    test('3. After Maghrib -> completed state targeting tomorrow Fajr', () {
      final now = DateTime(2026, 4, 15, 19, 30); // after sunset
      final state = FastingCountdownState.compute(
        now: now,
        fajr: fajr,
        maghrib: maghrib,
      );

      expect(state.stage, FastingCountdownStage.completed);
      expect(state.isBeforeSuhoor, isFalse);
      expect(state.isFastingHours, isFalse);
      expect(state.isCompleted, isTrue);
      expect(state.targetTime, fajr.add(const Duration(days: 1)));
      expect(state.progressFraction, 1.0);
    });
  });

  group('Fasting Repository & Streak Calculation Math', () {
    test('Calculates consecutive streak correctly', () {
      final today = DateTime(2026, 4, 15);
      final entries = [
        FastLogEntry(
          dateKey: '2026-04-15',
          gregorianDate: today,
          hijriFormatted: '27 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 27,
          status: FastStatus.kept,
        ),
        FastLogEntry(
          dateKey: '2026-04-14',
          gregorianDate: DateTime(2026, 4, 14),
          hijriFormatted: '26 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 26,
          status: FastStatus.kept,
        ),
        FastLogEntry(
          dateKey: '2026-04-13',
          gregorianDate: DateTime(2026, 4, 13),
          hijriFormatted: '25 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 25,
          status: FastStatus.qada,
        ),
        FastLogEntry(
          dateKey: '2026-04-11', // Gap on 2026-04-12 -> streak should be 3
          gregorianDate: DateTime(2026, 4, 11),
          hijriFormatted: '23 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 23,
          status: FastStatus.kept,
        ),
      ];

      final streak = FastingRepository.calculateStreak(entries, referenceToday: today);
      expect(streak, 3);
    });

    test('Computes monthly totals and makeup days owed', () {
      final entries = [
        FastLogEntry(
          dateKey: '2026-04-01',
          gregorianDate: DateTime(2026, 4, 1),
          hijriFormatted: '13 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 13,
          status: FastStatus.kept,
        ),
        FastLogEntry(
          dateKey: '2026-04-02',
          gregorianDate: DateTime(2026, 4, 2),
          hijriFormatted: '14 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 14,
          status: FastStatus.missed,
        ),
        FastLogEntry(
          dateKey: '2026-04-03',
          gregorianDate: DateTime(2026, 4, 3),
          hijriFormatted: '15 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 15,
          status: FastStatus.missed,
        ),
        FastLogEntry(
          dateKey: '2026-04-04',
          gregorianDate: DateTime(2026, 4, 4),
          hijriFormatted: '16 Ramadan 1447 AH',
          hijriYear: 1447,
          hijriMonth: 9,
          hijriDay: 16,
          status: FastStatus.qada,
        ),
      ];

      final countThisMonth = FastingRepository.calculateFastsThisMonth(entries, 9, 1447);
      expect(countThisMonth, 2); // 1 kept + 1 qada

      final makeupOwed = FastingRepository.calculateMakeupDaysOwed(entries);
      expect(makeupOwed, 1); // 2 missed - 1 qada = 1 owed
    });

    test('Saves, loads, and deletes entries via SharedPreferences', () async {
      final repo = FastingRepository();
      expect(await repo.loadLogEntries(), isEmpty);

      final entry = FastLogEntry(
        dateKey: '2026-04-10',
        gregorianDate: DateTime(2026, 4, 10),
        hijriFormatted: '22 Ramadan 1447 AH',
        hijriYear: 1447,
        hijriMonth: 9,
        hijriDay: 22,
        status: FastStatus.kept,
        checklist: const RamadanChecklist(suhoor: true, fastKept: true),
      );

      await repo.saveLogEntry(entry);
      final loaded = await repo.loadLogEntries();
      expect(loaded.length, 1);
      expect(loaded.first.dateKey, '2026-04-10');
      expect(loaded.first.checklist?.suhoor, isTrue);

      await repo.deleteLogEntry('2026-04-10');
      expect(await repo.loadLogEntries(), isEmpty);
    });
  });

  group('Fasting UI & Widget Navigation Flow', () {
    Widget buildTestWidget({required Widget child, Locale locale = const Locale('en')}) {
      final now = DateTime.now();
      final mockSchedule = PrayerSchedule(
        date: now,
        fajr: DateTime(now.year, now.month, now.day, 4, 30),
        sunrise: DateTime(now.year, now.month, now.day, 6, 0),
        dhuhr: DateTime(now.year, now.month, now.day, 12, 30),
        asr: DateTime(now.year, now.month, now.day, 16, 0),
        maghrib: DateTime(now.year, now.month, now.day, 18, 45),
        isha: DateTime(now.year, now.month, now.day, 20, 15),
        locationName: 'Test City',
        latitude: 21.4225,
        longitude: 39.8262,
      );

      return ProviderScope(
        overrides: [
          countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
          prayerScheduleProvider.overrideWithValue(mockSchedule),
        ],
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

    testWidgets(
        'Renders FastingDashboardScreen, displays countdown, stats, caution note, and opens Mark Dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(child: const FastingDashboardScreen()),
      );
      await tester.pumpAndSettle();

      // Verify FastingDashboardScreen components
      expect(find.byType(FastingTodayCard), findsOneWidget);
      expect(find.byType(FastingStatsRow), findsOneWidget);
      expect(find.byType(FastingLogList), findsOneWidget);

      // Verify Suhoor caution note is displayed
      expect(
        find.textContaining('Suhoor should end a few minutes before Fajr'),
        findsOneWidget,
      );

      // Verify Quick Action entry point works
      final markBtn = find.text('Mark Fast Status');
      expect(markBtn, findsOneWidget);
      await tester.ensureVisible(markBtn);
      await tester.tap(markBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LogFastDialog), findsOneWidget);
      final saveBtn = find.text('Save');
      expect(saveBtn, findsOneWidget);
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify dialog dismissed and entry saved
      expect(find.byType(LogFastDialog), findsNothing);
    });

    testWidgets('Renders properly in Arabic (RTL) without overflow on 360px',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const FastingDashboardScreen(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الصيام ورمضان'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders properly in Urdu (RTL) without overflow on 360px',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const FastingDashboardScreen(),
          locale: const Locale('ur'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('روزہ و رمضان'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeQuickActions contains Fasting item and navigates',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: HomeQuickActions(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fastingCard = find.text('Fasting');
      expect(fastingCard, findsOneWidget);
      await tester.tap(fastingCard);
      await tester.pumpAndSettle();
      expect(find.byType(FastingDashboardScreen), findsOneWidget);
    });
  });
}
