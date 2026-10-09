import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:muslim_ultra/features/prayer/data/services/notification_service.dart';

class MuhasabaReminderService {
  static const String enabledKey = 'muhasaba_evening_reminder_enabled';
  static const int reminderNotificationId = 998;
  static const int reminderHour = 22; // 10:00 PM (fallback / ~30m post-Isha)
  static const int reminderMinute = 0;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check if Muhasaba evening reminder is enabled (default true)
  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(enabledKey) ?? true;
  }

  /// Toggle Muhasaba evening reminder
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
      await scheduleMuhasabaReminder(
        title: title ?? "Nightly Muhasaba Reflection",
        body: body ?? "Take a quiet moment with Allah: How was your day? 🌙",
        quietHoursEnabled: quietHoursEnabled,
        quietStartMinutes: quietStartMinutes,
        quietEndMinutes: quietEndMinutes,
      );
    } else {
      await cancelMuhasabaReminder();
    }
  }

  /// Cancel evening Muhasaba reminder
  static Future<void> cancelMuhasabaReminder() async {
    try {
      await _notificationsPlugin.cancel(reminderNotificationId);
      debugPrint('MuhasabaReminderService: Cancelled reminder (id: $reminderNotificationId)');
    } catch (e) {
      debugPrint('MuhasabaReminderService: Failed to cancel reminder: $e');
    }
  }

  /// Calculate next 22:00 TZDateTime
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

  /// Schedule daily notification at 22:00
  static Future<void> scheduleMuhasabaReminder({
    required String title,
    required String body,
    bool quietHoursEnabled = false,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) async {
    try {
      final isEnabled = await isReminderEnabled();
      if (!isEnabled) {
        await cancelMuhasabaReminder();
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

      debugPrint('MuhasabaReminderService: Scheduled daily reminder at $scheduledTime');
    } catch (e, st) {
      debugPrint('MuhasabaReminderService: Failed to schedule reminder: $e\n$st');
    }
  }
}
