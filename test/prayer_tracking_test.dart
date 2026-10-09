import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/prayer_tracking/data/prayer_tracking_repository.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/screens/prayer_tracker_screen.dart';

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
  });

  group('PrayerLogEntry Domain Model', () {
    test('JSON serialization & deserialization round-trip', () {
      final now = DateTime(2026, 10, 9, 5, 0);
      final entry = PrayerLogEntry(
        date: '2026-10-09',
        prayer: 'fajr',
        status: PrayerLogStatus.prayed,
        timestamp: now,
      );

      final json = entry.toJson();
      final reconstructed = PrayerLogEntry.fromJson(json);

      expect(reconstructed, equals(entry));
      expect(reconstructed.prayer, 'fajr');
      expect(reconstructed.trackedPrayer, TrackedPrayer.fajr);
      expect(reconstructed.status, PrayerLogStatus.prayed);
      expect(reconstructed.date, '2026-10-09');
    });

    test('Equality and hashCode consistency', () {
      final now = DateTime(2026, 10, 9, 18, 30);
      final entry1 = PrayerLogEntry(
        date: '2026-10-09',
        prayer: 'maghrib',
        status: PrayerLogStatus.qada,
        timestamp: now,
      );
      final entry2 = PrayerLogEntry(
        date: '2026-10-09',
        prayer: 'maghrib',
        status: PrayerLogStatus.qada,
        timestamp: now,
      );
      final entry3 = PrayerLogEntry(
        date: '2026-10-09',
        prayer: 'maghrib',
        status: PrayerLogStatus.missed,
        timestamp: now,
      );

      expect(entry1, equals(entry2));
      expect(entry1.hashCode, equals(entry2.hashCode));
      expect(entry1, isNot(equals(entry3)));
    });
  });

  group('PrayerTrackingRepository Storage & Calculations', () {
    test('Round-trip: log prayer -> reload -> entry intact', () async {
      final repo = PrayerTrackingRepository();

      final entry = PrayerLogEntry(
        date: '2026-10-09',
        prayer: 'dhuhr',
        status: PrayerLogStatus.prayed,
        timestamp: DateTime(2026, 10, 9, 13, 0),
      );

      await repo.logPrayer(entry);

      final fetched = await repo.getEntry('2026-10-09', 'dhuhr');
      expect(fetched, isNotNull);
      expect(fetched!.prayer, 'dhuhr');
      expect(fetched.status, PrayerLogStatus.prayed);
      expect(fetched.date, '2026-10-09');

      // Update existing entry status to qada
      final updated = entry.copyWith(status: PrayerLogStatus.qada);
      await repo.logPrayer(updated);

      final reFetched = await repo.getEntry('2026-10-09', 'dhuhr');
      expect(reFetched, isNotNull);
      expect(reFetched!.status, PrayerLogStatus.qada);
    });

    test('Streak math: 3 consecutive full days -> streak 3; missed day breaks it', () async {
      final repo = PrayerTrackingRepository();
      final today = DateTime(2026, 10, 10);

      // Helper to log all 5 prayers for a day
      Future<void> logFullDay(DateTime date) async {
        final dateStr = PrayerTrackingRepository.formatDate(date);
        for (final p in TrackedPrayer.all) {
          await repo.logPrayer(PrayerLogEntry(
            date: dateStr,
            prayer: p.keyName,
            status: PrayerLogStatus.prayed,
            timestamp: date,
          ));
        }
      }

      // Log 3 consecutive full days: Oct 8, Oct 9, Oct 10
      await logFullDay(today.subtract(const Duration(days: 2)));
      await logFullDay(today.subtract(const Duration(days: 1)));
      await logFullDay(today);

      var currStreak = await repo.currentStreak(today);
      var maxStreak = await repo.bestStreak();
      expect(currStreak, 3);
      expect(maxStreak, 3);

      // A missed prayer on Oct 9 (e.g. Asr marked missed) breaks the 3-day full streak
      await repo.logPrayer(PrayerLogEntry(
        date: PrayerTrackingRepository.formatDate(today.subtract(const Duration(days: 1))),
        prayer: 'asr',
        status: PrayerLogStatus.missed,
        timestamp: today.subtract(const Duration(days: 1)),
      ));

      currStreak = await repo.currentStreak(today);
      // Oct 10 is full (1), Oct 9 is broken -> currentStreak is 1
      expect(currStreak, 1);
    });

    test('monthlyConsistency handles empty month without division by zero', () async {
      final repo = PrayerTrackingRepository();

      // Completely empty repository
      final consistency = await repo.monthlyConsistency(DateTime(2026, 10, 1));
      expect(consistency, 0.0);
    });

    test('weeklyStats calculates correct counts per prayer', () async {
      final repo = PrayerTrackingRepository();
      final now = DateTime(2026, 10, 10);

      // Log Fajr on 4 different days, Dhuhr on 2 days
      for (int i = 0; i < 4; i++) {
        final dt = now.subtract(Duration(days: i));
        await repo.logPrayer(PrayerLogEntry(
          date: PrayerTrackingRepository.formatDate(dt),
          prayer: 'fajr',
          status: PrayerLogStatus.prayed,
          timestamp: dt,
        ));
      }

      for (int i = 0; i < 2; i++) {
        final dt = now.subtract(Duration(days: i));
        await repo.logPrayer(PrayerLogEntry(
          date: PrayerTrackingRepository.formatDate(dt),
          prayer: 'dhuhr',
          status: PrayerLogStatus.prayed,
          timestamp: dt,
        ));
      }

      final stats = await repo.weeklyStats(now);
      expect(stats['totalPrayed'], 6);
      final dailyCounts = stats['dailyPrayedCounts'] as List<int>;
      expect(dailyCounts.length, 7);
    });
  });

  group('Prayer Tracker UI & Widget Tests', () {
    testWidgets('Tracker screen renders all 5 prayer rows and header widgets', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const PrayerTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Prayer Log'), findsOneWidget);

      // 5 prayer names should be in the tree
      expect(find.text('Fajr'), findsWidgets);
      expect(find.text('Dhuhr'), findsWidgets);
      expect(find.text('Asr'), findsWidgets);
      expect(find.text('Maghrib'), findsWidgets);
      expect(find.text('Isha'), findsWidgets);

      // Check for streak labels
      expect(find.text('Day Streak'), findsOneWidget);
      expect(find.text('Best Streak'), findsOneWidget);

      // Check for weekly & monthly section headers
      expect(find.text('Weekly Summary'), findsOneWidget);
      expect(find.text('Monthly Consistency'), findsOneWidget);
    });

    testWidgets('Tapping prayer log status updates status', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const PrayerTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find 'Prayed' buttons
      final prayedButtons = find.text('Prayed');
      expect(prayedButtons, findsWidgets);

      // Tap first 'Prayed' button
      await tester.tap(prayedButtons.first);
      await tester.pumpAndSettle();

      // Tap 'Qada' on the first row
      final qadaButtons = find.text('Qada');
      expect(qadaButtons, findsWidgets);
      await tester.tap(qadaButtons.first);
      await tester.pumpAndSettle();
    });

    testWidgets('360px compact RTL smoke test (Arabic)', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          locale: const Locale('ar'),
          size: const Size(360, 780),
          child: const PrayerTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title in Arabic
      expect(find.text(testArL10n.prayerTrackerTitle), findsOneWidget);
      // Verify no layout overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('360px compact RTL smoke test (Urdu)', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          locale: const Locale('ur'),
          size: const Size(360, 780),
          child: const PrayerTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title in Urdu
      expect(find.text(testUrL10n.prayerTrackerTitle), findsOneWidget);
      // Verify no layout overflow errors
      expect(tester.takeException(), isNull);
    });
  });
}
