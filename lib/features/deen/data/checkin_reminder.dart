import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:muslim_ultra/features/prayer/data/services/notification_service.dart';

class CheckinReminderService {
  static const String enabledKey = 'deen_evening_reminder_enabled';
  static const int reminderNotificationId = 999;
  static const int reminderHour = 21; // 9:00 PM
  static const int reminderMinute = 0;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check if evening reminder is enabled (default true)
  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(enabledKey) ?? true;
  }

  /// Toggle evening reminder
  static Future<void> setReminderEnabled(
    bool enabled, {
    String? title,
    String? body,
    bool quietHoursEnabled = false,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, enabled);

    if (enabled) {
      await scheduleEveningReminder(
        title: title ?? "Today's Deen",
        body: body ?? "Complete today's reflections and log your prayers 🤲",
        quietHoursEnabled: quietHoursEnabled,
        quietStartMinutes: quietStartMinutes,
        quietEndMinutes: quietEndMinutes,
      );
    } else {
      await cancelEveningReminder();
    }
  }

  /// Cancel evening check-in reminder
  static Future<void> cancelEveningReminder() async {
    try {
      await _notificationsPlugin.cancel(reminderNotificationId);
      debugPrint('CheckinReminderService: Cancelled evening reminder (id: $reminderNotificationId)');
    } catch (e) {
      debugPrint('CheckinReminderService: Failed to cancel evening reminder: $e');
    }
  }

  /// Pure function to check if 21:00 is inside quiet hours
  static bool isTimeInQuietHours({
    int hour = 21,
    int minute = 0,
    bool quietHoursEnabled = false,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) {
    if (!quietHoursEnabled || quietStartMinutes == null || quietEndMinutes == null) {
      return false;
    }
    final target = hour * 60 + minute;
    if (quietStartMinutes < quietEndMinutes) {
      return target >= quietStartMinutes && target < quietEndMinutes;
    } else {
      // Over midnight
      return target >= quietStartMinutes || target < quietEndMinutes;
    }
  }

  /// Calculate next 21:00 TZDateTime
  static tz.TZDateTime nextReminderTime([DateTime? customNow]) {
    final now = customNow != null
        ? tz.TZDateTime.from(customNow, tz.local)
        : tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedule daily notification at 21:00
  static Future<void> scheduleEveningReminder({
    required String title,
    required String body,
    bool quietHoursEnabled = false,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) async {
    try {
      final isEnabled = await isReminderEnabled();
      if (!isEnabled) {
        await cancelEveningReminder();
        return;
      }

      // Check quiet hours
      if (isTimeInQuietHours(
        hour: reminderHour,
        minute: reminderMinute,
        quietHoursEnabled: quietHoursEnabled,
        quietStartMinutes: quietStartMinutes,
        quietEndMinutes: quietEndMinutes,
      )) {
        debugPrint('CheckinReminderService: 21:00 is in quiet hours. Skipping reminder.');
        await cancelEveningReminder();
        return;
      }

      await PrayerNotificationService.initialize();

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        PrayerNotificationService.reminderChannelId,
        PrayerNotificationService.reminderChannelName,
        channelDescription: PrayerNotificationService.reminderChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledTime = nextReminderTime();

      await _notificationsPlugin.zonedSchedule(
        reminderNotificationId,
        title,
        body,
        scheduledTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('CheckinReminderService: Scheduled daily evening reminder at $scheduledTime');
    } catch (e, st) {
      debugPrint('CheckinReminderService: Failed to schedule evening reminder: $e\n$st');
    }
  }
}
