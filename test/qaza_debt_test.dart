import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/prayer_tracking/data/prayer_tracking_repository.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/qaza/data/qaza_repository.dart';
import 'package:muslim_ultra/features/qaza/domain/models/qaza_debt.dart';
import 'package:muslim_ultra/features/qaza/presentation/providers/qaza_providers.dart';
import 'package:muslim_ultra/features/qaza/presentation/screens/qaza_debt_screen.dart';

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

  group('Qaza Debt Math & Repository Unit Tests', () {
    test('Debt math: 3 missed Fajr - 1 repaid Qaza = 2 Fajr debt', () async {
      final prayerRepo = PrayerTrackingRepository();
      final qazaRepo = QazaRepository(prayerTrackingRepo: prayerRepo);

      // Log 3 missed Fajrs across 3 dates
      await prayerRepo.logPrayer(PrayerLogEntry(
        date: '2026-10-01',
        prayer: 'fajr',
        status: PrayerLogStatus.missed,
        timestamp: DateTime(2026, 10, 1),
      ));
      await prayerRepo.logPrayer(PrayerLogEntry(
        date: '2026-10-02',
        prayer: 'fajr',
        status: PrayerLogStatus.missed,
        timestamp: DateTime(2026, 10, 2),
      ));
      await prayerRepo.logPrayer(PrayerLogEntry(
        date: '2026-10-03',
        prayer: 'fajr',
        status: PrayerLogStatus.missed,
        timestamp: DateTime(2026, 10, 3),
      ));

      // Initial debt
      var debt = await qazaRepo.getDebt();
      expect(debt.fajr, 3);
      expect(debt.total, 3);

      // Repay 1 Fajr Qaza
      await qazaRepo.repayQaza(TrackedPrayer.fajr, DateTime(2026, 10, 10));

      // After 1 repayment: 3 - 1 = 2
      debt = await qazaRepo.getDebt();
      expect(debt.fajr, 2);
      expect(debt.total, 2);
      expect(debt.repaidThisWeek, 1);

      // Verify repayment writes through v1.5 storage format (allEntries contains qada)
      final allEntries = await prayerRepo.getAllEntries();
      final qadaEntries = allEntries.where((e) => e.status == PrayerLogStatus.qada).toList();
      expect(qadaEntries.length, 1);
      expect(qadaEntries.first.prayer, 'fajr');
      expect(qadaEntries.first.date, '2026-10-10');

      // Undo repayment
      final undone = await qazaRepo.undoRepayQaza(TrackedPrayer.fajr);
      expect(undone, isTrue);

      debt = await qazaRepo.getDebt();
      expect(debt.fajr, 3);
      expect(debt.total, 3);
      expect(debt.repaidThisWeek, 0);
    });

    test('Zero debt for all prayers when all are prayed on time', () async {
      final prayerRepo = PrayerTrackingRepository();
      final qazaRepo = QazaRepository(prayerTrackingRepo: prayerRepo);

      for (final p in TrackedPrayer.all) {
        await prayerRepo.logPrayer(PrayerLogEntry(
          date: '2026-10-09',
          prayer: p.keyName,
          status: PrayerLogStatus.prayed,
          timestamp: DateTime(2026, 10, 9),
        ));
      }

      final debt = await qazaRepo.getDebt();
      expect(debt.total, 0);
      expect(debt.hasDebt, isFalse);
    });
  });

  group('Qaza Debt UI & Widget Flow Tests', () {
    testWidgets('QazaDebtScreen renders counts, allows repaying prayer, and shows snackbar', (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const initialDebt = QazaDebt(
        fajr: 2,
        dhuhr: 1,
        asr: 0,
        maghrib: 0,
        isha: 1,
        total: 4,
        repaidThisWeek: 3,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qazaDebtProvider.overrideWith((ref) => Future.value(initialDebt)),
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
            home: const QazaDebtScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Title & headline rendered
      expect(find.text('Qaza Debt Balance'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('+3'), findsOneWidget);

      // Per-prayer breakdown rendered
      expect(find.text('2 pending'), findsOneWidget); // Fajr
      expect(find.text('1 pending'), findsNWidgets(2)); // Dhuhr and Isha
      expect(find.text('0 pending'), findsNWidgets(2)); // Asr and Maghrib

      // Tap repay button for Fajr
      final repayFajrBtn = find.byKey(const ValueKey('btn_repay_fajr'));
      expect(repayFajrBtn, findsOneWidget);
      await tester.tap(repayFajrBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Snackbar with undo is shown
      expect(find.textContaining('Fajr Qaza logged'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      tester.takeException();
    });

    testWidgets('360px RTL smoke test on QazaDebtScreen in Arabic', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const sampleDebt = QazaDebt(
        fajr: 1,
        dhuhr: 0,
        asr: 0,
        maghrib: 0,
        isha: 0,
        total: 1,
        repaidThisWeek: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qazaDebtProvider.overrideWith((ref) => Future.value(sampleDebt)),
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
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: QazaDebtScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(QazaDebtScreen), findsOneWidget);
      expect(find.text('رصيد قضاء الصلوات'), findsOneWidget);

      tester.takeException();
    });
  });
}
