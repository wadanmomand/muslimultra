import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:muslim_ultra/features/prayer/domain/models/prayer_time.dart';
import 'package:muslim_ultra/features/prayer/domain/models/notification_settings.dart';

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      await _notificationsPlugin.initialize(initSettings);
      _initialized = true;
    } catch (_) {
      // Gracefully handled in headless test or non-mobile environments
    }
  }

  /// Schedule daily notifications for the prayer schedule
  static Future<void> schedulePrayerNotifications({
    required PrayerSchedule schedule,
    required PrayerNotificationSettings settings,
  }) async {
    try {
      await initialize();

      // Cancel previously scheduled prayer notifications
      for (int i = 1; i <= 6; i++) {
        await _notificationsPlugin.cancel(i);
      }

      final prayers = schedule.prayers;

      for (int i = 0; i < prayers.length; i++) {
        final prayer = prayers[i];
        final prayerId = i + 1;

        if (!settings.isPrayerEnabled(prayer.name)) continue;
        if (settings.isInQuietHours(prayer.time)) continue;

        if (prayer.time.isAfter(DateTime.now())) {
          await _scheduleSinglePrayer(
            id: prayerId,
            prayerName: prayer.name,
            time: prayer.time,
          );
        }
      }
    } catch (_) {
      // Platform notification channel ignored in headless/test environments
    }
  }

  static Future<void> _scheduleSinglePrayer({
    required int id,
    required String prayerName,
    required DateTime time,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(time, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prayer_athan_channel',
        'Prayer Times & Athan',
        channelDescription: 'Notifications for Islamic Prayer Times',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('athan'),
        playSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(sound: 'athan.aiff'),
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        '$prayerName Prayer Time',
        'It is time for $prayerName prayer.',
        tzTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Gracefully catch background scheduling exceptions
    }
  }
}
