import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/widgets/daily_ayat.dart';

/// Platform bridge to communicate prayer and ayah updates to native Android Home-Screen Widgets
class WidgetBridge {
  static const MethodChannel _channel = MethodChannel('com.muslimultra.app/widgets');

  // Keys used in SharedPreferences (accessed by Android native widgets)
  static const String keyNextPrayerName = 'widget_next_prayer_name';
  static const String keyNextPrayerTime = 'widget_next_prayer_time';
  static const String keyNextPrayerTimestamp = 'widget_next_prayer_timestamp';
  static const String keyDailyAyahArabic = 'widget_daily_ayah_arabic';
  static const String keyDailyAyahTranslation = 'widget_daily_ayah_translation';
  static const String keyDailyAyahRef = 'widget_daily_ayah_ref';
  static const String keyLastUpdated = 'widget_last_updated';

  /// Updates the next prayer widget data and notifies native platform
  static Future<void> updatePrayerWidget({
    String? nextPrayerName,
    String? nextPrayerTime,
    int? nextPrayerTimestamp,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (nextPrayerName != null) {
        await prefs.setString(keyNextPrayerName, nextPrayerName);
      }
      if (nextPrayerTime != null) {
        await prefs.setString(keyNextPrayerTime, nextPrayerTime);
      }
      if (nextPrayerTimestamp != null) {
        await prefs.setInt(keyNextPrayerTimestamp, nextPrayerTimestamp);
      }
      await prefs.setInt(keyLastUpdated, DateTime.now().millisecondsSinceEpoch);

      // Trigger native widget update via MethodChannel
      await _channel.invokeMethod('updatePrayerWidget');
    } catch (_) {
      // Platform channels may not be available in headless test environments
    }
  }

  /// Updates the daily ayah widget data deterministically and notifies native platform
  static Future<void> updateAyahWidget([DateTime? date]) async {
    try {
      final targetDate = date ?? DateTime.now();
      final ref = DailyAyatService.getRefForDate(targetDate);
      final resolved = await DailyAyatService.resolveAyah(ref);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyDailyAyahArabic, resolved.arabic);
      await prefs.setString(keyDailyAyahTranslation, resolved.english);
      await prefs.setString(keyDailyAyahRef, resolved.referenceText);
      await prefs.setInt(keyLastUpdated, DateTime.now().millisecondsSinceEpoch);

      // Trigger native widget update via MethodChannel
      await _channel.invokeMethod('updateAyahWidget');
    } catch (_) {
      // Platform channels may not be available in headless test environments
    }
  }

  /// Refreshes both widgets simultaneously
  static Future<void> updateAllWidgets({
    String? nextPrayerName,
    String? nextPrayerTime,
    int? nextPrayerTimestamp,
    DateTime? date,
  }) async {
    await updatePrayerWidget(
      nextPrayerName: nextPrayerName,
      nextPrayerTime: nextPrayerTime,
      nextPrayerTimestamp: nextPrayerTimestamp,
    );
    await updateAyahWidget(date);
  }
}
