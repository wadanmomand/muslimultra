import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:muslim_ultra/features/prayer/domain/models/prayer_time.dart';
import 'package:muslim_ultra/features/prayer/domain/models/notification_settings.dart';

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Channel IDs
  static const String athanChannelId = 'prayer_athan_channel';
  static const String athanChannelName = 'Prayer Times & Athan';
  static const String athanChannelDesc = 'Loud Athan notifications for Islamic prayer times';

  static const String defaultChannelId = 'prayer_default_channel';
  static const String defaultChannelName = 'Prayer Times (Standard)';
  static const String defaultChannelDesc = 'Standard prayer time alerts with system sound';

  static const String reminderChannelId = 'prayer_reminder_channel';
  static const String reminderChannelName = 'Pre-Prayer Reminders';
  static const String reminderChannelDesc = 'Gentle reminders 15 minutes before prayer time';

  /// Notification ID Ranges:
  /// Today Azan: 1..6
  /// Tomorrow Azan: 101..106
  /// Today Pre-Prayer Reminder: 201..206
  /// Tomorrow Pre-Prayer Reminder: 301..306

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

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('PrayerNotificationService: Notification tapped (id: ${response.id}, payload: ${response.payload})');
        },
      );

      // Create Android Notification Channels proactively
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // 1. Athan channel with custom sound
        const AndroidNotificationChannel athanChannel = AndroidNotificationChannel(
          athanChannelId,
          athanChannelName,
          description: athanChannelDesc,
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('athan'),
          playSound: true,
          enableVibration: true,
        );

        // 2. Default prayer channel (fallback)
        const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
          defaultChannelId,
          defaultChannelName,
          description: defaultChannelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

        // 3. Pre-prayer reminder channel
        const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
          reminderChannelId,
          reminderChannelName,
          description: reminderChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await androidPlugin.createNotificationChannel(athanChannel);
        await androidPlugin.createNotificationChannel(defaultChannel);
        await androidPlugin.createNotificationChannel(reminderChannel);
      }

      _initialized = true;
      debugPrint('PrayerNotificationService: Initialized successfully with notification channels');
    } catch (e, st) {
      debugPrint('PrayerNotificationService: Initialization failed: $e\n$st');
    }
  }

  /// Check and request POST_NOTIFICATIONS permission on Android 13+ / iOS
  static Future<bool> requestNotificationPermissions() async {
    try {
      await initialize();

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('PrayerNotificationService: Android POST_NOTIFICATIONS permission result: $granted');
        return granted ?? false;
      }

      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('PrayerNotificationService: iOS notification permission result: $granted');
        return granted ?? false;
      }

      return true;
    } catch (e, st) {
      debugPrint('PrayerNotificationService: Error requesting notification permission: $e\n$st');
      return false;
    }
  }

  /// Check exact alarm scheduling capability (Android 12+)
  static Future<bool> canScheduleExactAlarms() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final canSchedule = await androidPlugin.canScheduleExactNotifications();
        debugPrint('PrayerNotificationService: canScheduleExactNotifications = $canSchedule');
        return canSchedule ?? true;
      }
      return true;
    } catch (e, st) {
      debugPrint('PrayerNotificationService: Error checking exact alarm capability: $e\n$st');
      return true;
    }
  }

  /// Request exact alarm permission (Android 12+)
  static Future<void> requestExactAlarmPermission() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
        debugPrint('PrayerNotificationService: Requested exact alarms permission');
      }
    } catch (e, st) {
      debugPrint('PrayerNotificationService: Error requesting exact alarm permission: $e\n$st');
    }
  }

  /// Schedule rolling notifications: today's remaining prayers + ALL of tomorrow's prayers
  static Future<void> schedulePrayerNotifications({
    required PrayerSchedule schedule,
    required PrayerNotificationSettings settings,
    PrayerSchedule? tomorrowSchedule,
  }) async {
    try {
      await initialize();

      // Cancel all existing scheduled prayer & reminder notifications (1..400)
      for (int i = 1; i <= 6; i++) {
        await _notificationsPlugin.cancel(i); // Today Azan
        await _notificationsPlugin.cancel(100 + i); // Tomorrow Azan
        await _notificationsPlugin.cancel(200 + i); // Today Reminder
        await _notificationsPlugin.cancel(300 + i); // Tomorrow Reminder
      }

      final now = DateTime.now();

      // 1. Schedule today's remaining prayers & reminders
      final todayPrayers = schedule.prayers;
      for (int i = 0; i < todayPrayers.length; i++) {
        final prayer = todayPrayers[i];
        final prayerId = i + 1;

        if (!settings.isPrayerEnabled(prayer.name)) continue;
        if (settings.isInQuietHours(prayer.time)) continue;

        // Azan notification (today)
        if (prayer.time.isAfter(now)) {
          await _scheduleSinglePrayer(
            id: prayerId,
            prayerName: prayer.name,
            time: prayer.time,
            isAthan: true,
          );
        }

        // Pre-prayer reminder (today)
        if (settings.enablePrePrayerReminder) {
          final reminderTime = prayer.time.subtract(
            Duration(minutes: settings.prePrayerReminderMinutes),
          );
          if (reminderTime.isAfter(now) && !settings.isInQuietHours(reminderTime)) {
            await _scheduleSinglePrayer(
              id: 200 + prayerId,
              prayerName: prayer.name,
              time: reminderTime,
              isAthan: false,
              isPreReminder: true,
              minutesBefore: settings.prePrayerReminderMinutes,
            );
          }
        }
      }

      // 2. Schedule tomorrow's prayers & reminders (rolling window)
      if (tomorrowSchedule != null) {
        final tomorrowPrayers = tomorrowSchedule.prayers;
        for (int i = 0; i < tomorrowPrayers.length; i++) {
          final prayer = tomorrowPrayers[i];
          final prayerId = 100 + (i + 1);

          if (!settings.isPrayerEnabled(prayer.name)) continue;
          if (settings.isInQuietHours(prayer.time)) continue;

          // Azan notification (tomorrow)
          if (prayer.time.isAfter(now)) {
            await _scheduleSinglePrayer(
              id: prayerId,
              prayerName: prayer.name,
              time: prayer.time,
              isAthan: true,
            );
          }

          // Pre-prayer reminder (tomorrow)
          if (settings.enablePrePrayerReminder) {
            final reminderTime = prayer.time.subtract(
              Duration(minutes: settings.prePrayerReminderMinutes),
            );
            if (reminderTime.isAfter(now) && !settings.isInQuietHours(reminderTime)) {
              await _scheduleSinglePrayer(
                id: 300 + (i + 1),
                prayerName: prayer.name,
                time: reminderTime,
                isAthan: false,
                isPreReminder: true,
                minutesBefore: settings.prePrayerReminderMinutes,
              );
            }
          }
        }
      }

      debugPrint(
        'PrayerNotificationService: Successfully scheduled rolling prayers for today and tomorrow. Pre-reminder: ${settings.enablePrePrayerReminder}',
      );
    } catch (e, st) {
      debugPrint('PrayerNotificationService: Failed to schedule notifications: $e\n$st');
    }
  }

  static Future<void> _scheduleSinglePrayer({
    required int id,
    required String prayerName,
    required DateTime time,
    required bool isAthan,
    bool isPreReminder = false,
    int minutesBefore = 15,
  }) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);

    final title = isPreReminder
        ? 'Upcoming: $prayerName Prayer ($minutesBefore mins)'
        : '$prayerName Prayer Time';
    final body = isPreReminder
        ? 'Prepare for $prayerName prayer in $minutesBefore minutes.'
        : 'It is time for $prayerName prayer.';

    try {
      final NotificationDetails platformDetails = _getNotificationDetails(
        isAthan: isAthan,
        isPreReminder: isPreReminder,
        useAthanSound: isAthan,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('PrayerNotificationService: Scheduled id=$id ($prayerName) at $tzTime');
    } catch (e) {
      debugPrint(
        'PrayerNotificationService: Custom sound scheduling failed for id=$id ($prayerName): $e. Retrying with default sound fallback...',
      );

      // Graceful fallback: retry with default sound
      try {
        final fallbackDetails = _getNotificationDetails(
          isAthan: false,
          isPreReminder: isPreReminder,
          useAthanSound: false,
        );

        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzTime,
          fallbackDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('PrayerNotificationService: Fallback schedule succeeded for id=$id ($prayerName) at $tzTime');
      } catch (fallbackError, fallbackSt) {
        debugPrint(
          'PrayerNotificationService: Fallback scheduling also failed for id=$id: $fallbackError\n$fallbackSt',
        );
      }
    }
  }

  static NotificationDetails _getNotificationDetails({
    required bool isAthan,
    required bool isPreReminder,
    required bool useAthanSound,
  }) {
    if (isPreReminder) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        reminderChannelId,
        reminderChannelName,
        channelDescription: reminderChannelDesc,
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

      return const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
    }

    if (useAthanSound) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        athanChannelId,
        athanChannelName,
        channelDescription: athanChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        sound: RawResourceAndroidNotificationSound('athan'),
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'athan.aiff',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      return const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
    } else {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        defaultChannelId,
        defaultChannelName,
        channelDescription: defaultChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      return const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
    }
  }
}
