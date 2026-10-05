import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/domain/models/prayer_time.dart';
import 'package:muslim_ultra/features/prayer/domain/models/qibla_direction.dart';
import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';
import 'package:muslim_ultra/features/prayer/domain/models/notification_settings.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/prayer_time_engine.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/hijri_calculator.dart';
import 'package:muslim_ultra/features/prayer/data/services/location_service.dart';
import 'package:muslim_ultra/features/prayer/data/services/qibla_service.dart';
import 'package:muslim_ultra/features/prayer/data/services/prayer_storage_service.dart';
import 'package:muslim_ultra/features/prayer/data/services/notification_service.dart';

/// 1. Location State
class LocationNotifier extends StateNotifier<LocationModel> {
  LocationNotifier() : super(LocationService.defaultLocation);

  void setLocation(LocationModel location) {
    state = location;
  }

  Future<void> useGpsLocation() async {
    final gps = await LocationService.getCurrentGpsLocation();
    if (gps != null) {
      state = gps;
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationModel>((ref) {
  return LocationNotifier();
});

/// 2. Calculation Parameters State
class PrayerParametersNotifier extends StateNotifier<PrayerCalculationParameters> {
  PrayerParametersNotifier() : super(const PrayerCalculationParameters()) {
    _init();
  }

  Future<void> _init() async {
    final loaded = await PrayerStorageService.loadParameters();
    state = loaded;
  }

  void setMethod(CalculationMethod method) {
    state = state.copyWith(method: method);
    PrayerStorageService.saveParameters(state);
  }

  void setMadhab(Madhab madhab) {
    state = state.copyWith(madhab: madhab);
    PrayerStorageService.saveParameters(state);
  }

  void setHighLatitudeRule(HighLatitudeRule rule) {
    state = state.copyWith(highLatitudeRule: rule);
    PrayerStorageService.saveParameters(state);
  }

  void setHijriOffset(int offset) {
    state = state.copyWith(hijriOffsetDays: offset);
    PrayerStorageService.saveParameters(state);
  }
}

final prayerParametersProvider =
    StateNotifierProvider<PrayerParametersNotifier, PrayerCalculationParameters>((ref) {
  return PrayerParametersNotifier();
});

/// 3. Notification Settings State
class NotificationSettingsNotifier extends StateNotifier<PrayerNotificationSettings> {
  NotificationSettingsNotifier() : super(const PrayerNotificationSettings()) {
    _init();
  }

  Future<void> _init() async {
    final loaded = await PrayerStorageService.loadNotificationSettings();
    state = loaded;
  }

  void togglePrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        state = state.copyWith(enableFajr: !state.enableFajr);
        break;
      case 'sunrise':
        state = state.copyWith(enableSunrise: !state.enableSunrise);
        break;
      case 'dhuhr':
        state = state.copyWith(enableDhuhr: !state.enableDhuhr);
        break;
      case 'asr':
        state = state.copyWith(enableAsr: !state.enableAsr);
        break;
      case 'maghrib':
        state = state.copyWith(enableMaghrib: !state.enableMaghrib);
        break;
      case 'isha':
        state = state.copyWith(enableIsha: !state.enableIsha);
        break;
    }
    PrayerStorageService.saveNotificationSettings(state);
  }

  void setQuietHours({required bool enabled, int? startMins, int? endMins}) {
    state = state.copyWith(
      enableQuietHours: enabled,
      quietHoursStartMinutes: startMins ?? state.quietHoursStartMinutes,
      quietHoursEndMinutes: endMins ?? state.quietHoursEndMinutes,
    );
    PrayerStorageService.saveNotificationSettings(state);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, PrayerNotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

/// 4. Computed Prayer Schedule
final prayerScheduleProvider = Provider<PrayerSchedule>((ref) {
  final location = ref.watch(locationProvider);
  final parameters = ref.watch(prayerParametersProvider);
  final notificationSettings = ref.watch(notificationSettingsProvider);

  final now = DateTime.now();
  final schedule = PrayerTimeEngine.calculate(
    date: now,
    latitude: location.latitude,
    longitude: location.longitude,
    timezoneOffsetHours: location.timezoneOffsetHours,
    locationName: location.displayName,
    parameters: parameters,
  );

  // Trigger background notification schedule
  PrayerNotificationService.schedulePrayerNotifications(
    schedule: schedule,
    settings: notificationSettings,
  );

  return schedule;
});

/// 5. Current Hijri Date Provider
final hijriDateProvider = Provider<HijriDate>((ref) {
  final params = ref.watch(prayerParametersProvider);
  return HijriCalculator.fromGregorian(
    DateTime.now(),
    offsetDays: params.hijriOffsetDays,
  );
});

/// 6. Next Prayer Countdown State
class CountdownState {
  final PrayerTimeModel nextPrayer;
  final Duration remainingDuration;
  final String formattedCountdown; // e.g. "01h 24m 15s"
  final double progressFraction; // 0.0 to 1.0

  const CountdownState({
    required this.nextPrayer,
    required this.remainingDuration,
    required this.formattedCountdown,
    this.progressFraction = 0.0,
  });
}

/// 6. Countdown Stream Tick Provider
final countdownTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  final timer = Timer.periodic(const Duration(seconds: 1), (t) {
    if (!controller.isClosed) {
      controller.add(DateTime.now());
    }
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  // Emit initial tick
  controller.add(DateTime.now());
  return controller.stream;
});

final nextPrayerCountdownProvider = Provider.autoDispose<CountdownState?>((ref) {
  // Watch tick
  ref.watch(countdownTickProvider);

  final schedule = ref.watch(prayerScheduleProvider);
  final now = DateTime.now();
  final next = schedule.nextPrayer(now);

  var diff = next.time.difference(now);
  if (diff.isNegative) {
    diff = Duration.zero;
  }

  final hours = diff.inHours.toString().padLeft(2, '0');
  final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
  final secs = (diff.inSeconds % 60).toString().padLeft(2, '0');

  return CountdownState(
    nextPrayer: next,
    remainingDuration: diff,
    formattedCountdown: '${hours}h ${mins}m ${secs}s',
  );
});

/// 7. Qibla Direction State
class QiblaNotifier extends StateNotifier<QiblaDirectionData> {
  final Ref ref;
  StreamSubscription<double>? _headingSubscription;

  QiblaNotifier(this.ref)
      : super(const QiblaDirectionData(qiblaBearing: 0.0, distanceKm: 0.0)) {
    _recalculate(0.0);
    _headingSubscription = QiblaService.streamHeading().listen((heading) {
      _recalculate(heading);
    });
  }

  void _recalculate(double currentHeading) {
    final location = ref.read(locationProvider);
    state = QiblaService.evaluateQibla(
      userLat: location.latitude,
      userLng: location.longitude,
      currentHeading: currentHeading,
    );
  }

  void setManualHeading(double heading) {
    _recalculate(heading);
  }

  @override
  void dispose() {
    _headingSubscription?.cancel();
    super.dispose();
  }
}

final qiblaDataProvider =
    StateNotifierProvider.autoDispose<QiblaNotifier, QiblaDirectionData>((ref) {
  return QiblaNotifier(ref);
});
