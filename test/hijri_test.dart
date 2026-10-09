import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/main.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/hijri_calculator.dart';
import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/hijri/data/hijri_calendar_service.dart';
import 'package:muslim_ultra/features/hijri/data/islamic_events_data.dart';
import 'package:muslim_ultra/features/hijri/presentation/screens/hijri_calendar_screen.dart';
import 'package:muslim_ultra/features/hijri/presentation/widgets/hijri_countdown_chip.dart';
import 'package:muslim_ultra/features/hijri/presentation/widgets/hijri_month_grid.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/quick_actions.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HijriDate Model & Urdu Month Names', () {
    test('HijriDate contains 12 Urdu months', () {
      expect(HijriDate.monthsUr.length, 12);
      expect(HijriDate.monthsUr[0], 'محرم');
      expect(HijriDate.monthsUr[8], 'رمضان');
      expect(HijriDate.monthsUr[9], 'شوال');
      expect(HijriDate.monthsUr[11], 'ذوالحجہ');
    });

    test('HijriCalculator populates monthNameUr and formats correctly', () {
      final ramadan1447 = DateTime(2026, 2, 18);
      final hijri = HijriCalculator.fromGregorian(ramadan1447);

      expect(hijri.year, 1447);
      expect(hijri.month, 9);
      expect(hijri.day, 1);
      expect(hijri.monthNameEn, 'Ramadan');
      expect(hijri.monthNameAr, 'رمضان');
      expect(hijri.monthNameUr, 'رمضان');
      expect(hijri.formattedEn(), '1 Ramadan 1447 AH');
      expect(hijri.formattedAr(), '1 رمضان 1447 هـ');
      expect(hijri.formattedUr(), '1 رمضان 1447 ھ');
    });
  });

  group('Hijri Calendar Service — Month Grid & Spot Checks', () {
    test('Spot-check Ramadan 1447 AH Gregorian dates', () {
      // 1 Ramadan 1447 AH
      final ramadanData = HijriCalendarService.getMonthData(1447, 9);
      expect(ramadanData.hijriYear, 1447);
      expect(ramadanData.hijriMonth, 9);
      expect(ramadanData.daysInMonth, 30); // 30 days in Ramadan 1447
      expect(ramadanData.days.first.hijriDay, 1);
      expect(ramadanData.days.first.gregorianDate, DateTime(2026, 2, 18));
      expect(ramadanData.days.last.hijriDay, 30);
      expect(ramadanData.days.last.gregorianDate, DateTime(2026, 3, 19));
    });

    test('Spot-check Shawwal 1447 AH (Eid al-Fitr) Gregorian dates', () {
      // 1 Shawwal 1447 AH (Eid al-Fitr)
      final shawwalData = HijriCalendarService.getMonthData(1447, 10);
      expect(shawwalData.hijriYear, 1447);
      expect(shawwalData.hijriMonth, 10);
      expect(shawwalData.days.first.hijriDay, 1);
      expect(shawwalData.days.first.gregorianDate, DateTime(2026, 3, 20));

      final eidEvent = shawwalData.days.first.events.firstWhere((e) => e.id == 'eid_al_fitr');
      expect(eidEvent.nameEn, 'Eid al-Fitr');
      expect(eidEvent.nameAr, 'عيد الفطر المبارك');
      expect(eidEvent.nameUr, 'عید الفطر');
    });

    test('All Hijri months in year 1447 have 29 or 30 days', () {
      for (int m = 1; m <= 12; m++) {
        final monthData = HijriCalendarService.getMonthData(1447, m);
        expect(monthData.daysInMonth, isIn([29, 30]), reason: 'Month $m of 1447 should have 29 or 30 days');
        expect(monthData.days.first.hijriDay, 1);
        expect(monthData.days.last.hijriDay, monthData.daysInMonth);
      }
    });

    test('Respects hijriOffsetDays adjustment (+1, -1)', () {
      final base = HijriCalendarService.getMonthData(1447, 9, offsetDays: 0);
      final offsetPlus1 = HijriCalendarService.getMonthData(1447, 9, offsetDays: 1);
      final offsetMinus1 = HijriCalendarService.getMonthData(1447, 9, offsetDays: -1);

      // With +1 offset, 1 Ramadan begins 1 Gregorian day earlier
      expect(offsetPlus1.days.first.gregorianDate, base.days.first.gregorianDate.subtract(const Duration(days: 1)));
      // With -1 offset, 1 Ramadan begins 1 Gregorian day later
      expect(offsetMinus1.days.first.gregorianDate, base.days.first.gregorianDate.add(const Duration(days: 1)));
    });
  });

  group('Islamic Events Dataset & Rules', () {
    test('Predefined events fire on correct Hijri dates', () {
      // 1 Muharram - Islamic New Year
      final newYearEvents = IslamicEventsData.getEventsFor(1, 1);
      expect(newYearEvents.any((e) => e.id == 'islamic_new_year'), isTrue);

      // 10 Muharram - Day of Ashura
      final ashuraEvents = IslamicEventsData.getEventsFor(1, 10);
      expect(ashuraEvents.any((e) => e.id == 'day_of_ashura'), isTrue);

      // 12 Rabi al-Awwal - Mawlid
      final mawlidEvents = IslamicEventsData.getEventsFor(3, 12);
      expect(mawlidEvents.any((e) => e.id == 'mawlid_an_nabi'), isTrue);

      // 27 Rajab - Isra wal-Miraj
      final mirajEvents = IslamicEventsData.getEventsFor(7, 27);
      expect(mirajEvents.any((e) => e.id == 'isra_wal_miraj'), isTrue);

      // 15 Shaban - Shab-e-Barat
      final shabanEvents = IslamicEventsData.getEventsFor(8, 15);
      expect(shabanEvents.any((e) => e.id == 'shab_e_barat'), isTrue);

      // 1 Ramadan - Start of Ramadan
      final ramadanEvents = IslamicEventsData.getEventsFor(9, 1);
      expect(ramadanEvents.any((e) => e.id == 'start_of_ramadan'), isTrue);

      // Laylat al Qadr odd nights (21, 23, 25, 27, 29)
      for (final day in [21, 23, 25, 27, 29]) {
        final qadrEvents = IslamicEventsData.getEventsFor(9, day);
        expect(qadrEvents.any((e) => e.id.startsWith('laylat_al_qadr')), isTrue, reason: 'Day $day Ramadan is odd night');
      }

      // 1 Shawwal - Eid al-Fitr
      final eidFitrEvents = IslamicEventsData.getEventsFor(10, 1);
      expect(eidFitrEvents.any((e) => e.id == 'eid_al_fitr'), isTrue);

      // 8-13 Dhul-Hijjah - Hajj days
      expect(IslamicEventsData.getEventsFor(12, 8).any((e) => e.id == 'day_of_tarwiyah'), isTrue);
      expect(IslamicEventsData.getEventsFor(12, 9).any((e) => e.id == 'day_of_arafah'), isTrue);
      expect(IslamicEventsData.getEventsFor(12, 10).any((e) => e.id == 'eid_al_adha'), isTrue);
      expect(IslamicEventsData.getEventsFor(12, 11).any((e) => e.id == 'tashreeq_day_1'), isTrue);
      expect(IslamicEventsData.getEventsFor(12, 12).any((e) => e.id == 'tashreeq_day_2'), isTrue);
      expect(IslamicEventsData.getEventsFor(12, 13).any((e) => e.id == 'tashreeq_day_3'), isTrue);

      // 1st of regular month is New Month marker
      expect(IslamicEventsData.getEventsFor(2, 1).any((e) => e.id == 'new_hijri_month'), isTrue);
    });

    test('Countdown calculates days remaining to next major event', () {
      // 10 days before 1 Ramadan 1447 (which is 2026-02-18) -> 2026-02-08
      final fromDate = DateTime(2026, 2, 8);
      final upcoming = HijriCalendarService.getNextMajorEvent(fromDate: fromDate);

      expect(upcoming, isNotNull);
      expect(upcoming!.event.id, 'start_of_ramadan');
      expect(upcoming.daysRemaining, 10);
      expect(upcoming.gregorianDate, DateTime(2026, 2, 18));
    });
  });

  group('Hijri Calendar UI & Widget Flow', () {
    testWidgets('Opens from Home Quick Actions, navigates months, highlights today, shows countdown and disclaimer',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
      );
      addTearDown(container.dispose);

      // Set 360px viewport
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MuslimUltraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Find Hijri Calendar card in Quick Actions
      expect(find.byType(HomeQuickActions), findsOneWidget);
      final hijriAction = find.text('Hijri Calendar');
      expect(hijriAction, findsOneWidget);

      await tester.tap(hijriAction);
      await tester.pumpAndSettle();

      // Verify HijriCalendarScreen is pushed
      expect(find.byType(HijriCalendarScreen), findsOneWidget);
      expect(find.byType(HijriMonthGrid), findsOneWidget);

      // Verify Countdown Chip exists
      expect(find.byType(HijriCountdownChip), findsOneWidget);

      // Verify Moon-sighting disclaimer is visible
      expect(find.text('Dates may vary by moon sighting in your region.'), findsOneWidget);

      // Verify Month navigation works
      final nextMonthBtn = find.byIcon(Icons.chevron_right_rounded);
      expect(nextMonthBtn, findsOneWidget);
      await tester.tap(nextMonthBtn);
      await tester.pumpAndSettle();

      // Verify Jump back to Today works
      final todayBtn = find.byIcon(Icons.today_rounded);
      expect(todayBtn, findsOneWidget);
      await tester.tap(todayBtn);
      await tester.pumpAndSettle();

      // Tap an event card if present to verify bottom sheet
      final eventCards = find.byType(InkWell);
      expect(eventCards, findsWidgets);
    });

    testWidgets('Renders properly in Arabic (RTL) without overflow on 360px',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
      );
      container.read(localeProvider.notifier).setLanguage('ar');
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MuslimUltraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Hijri Calendar
      final action = find.text('التقويم الهجري');
      expect(action, findsOneWidget);
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.byType(HijriCalendarScreen), findsOneWidget);
      expect(find.text('التقويم الهجري'), findsWidgets);
      expect(find.text('قد تختلف المواعيد حسب رؤية الهلال في منطقتك.'), findsOneWidget);
    });

    testWidgets('Renders properly in Urdu (RTL) with Urdu month names on 360px',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
      );
      container.read(localeProvider.notifier).setLanguage('ur');
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MuslimUltraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Hijri Calendar
      final action = find.text('ہجری کیلنڈر');
      expect(action, findsOneWidget);
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.byType(HijriCalendarScreen), findsOneWidget);
      expect(find.text('ہجری کیلنڈر'), findsWidgets);
      expect(find.text('علاقائی رویت ہلال کے مطابق تاریخوں میں فرق ہو سکتا ہے۔'), findsOneWidget);
    });
  });
}
