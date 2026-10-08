import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/domain/models/notification_settings.dart';

class PrayerStorageService {
  static const String _keyMethod = 'prayer_calculation_method';
  static const String _keyMadhab = 'prayer_madhab';
  static const String _keyHighLat = 'prayer_high_lat_rule';
  static const String _keyHijriOffset = 'prayer_hijri_offset';

  static const String _keyNotifFajr = 'prayer_notif_fajr';
  static const String _keyNotifSunrise = 'prayer_notif_sunrise';
  static const String _keyNotifDhuhr = 'prayer_notif_dhuhr';
  static const String _keyNotifAsr = 'prayer_notif_asr';
  static const String _keyNotifMaghrib = 'prayer_notif_maghrib';
  static const String _keyNotifIsha = 'prayer_notif_isha';
  static const String _keyNotifPreReminder = 'prayer_notif_pre_reminder';
  static const String _keyNotifPreReminderMins = 'prayer_notif_pre_reminder_mins';
  static const String _keyQuietHours = 'prayer_quiet_hours_enabled';
  static const String _keyQuietStart = 'prayer_quiet_start_mins';
  static const String _keyQuietEnd = 'prayer_quiet_end_mins';

  static Future<PrayerCalculationParameters> loadParameters() async {
    final prefs = await SharedPreferences.getInstance();

    final methodIndex = prefs.getInt(_keyMethod);
    final madhabIndex = prefs.getInt(_keyMadhab);
    final highLatIndex = prefs.getInt(_keyHighLat);
    final hijriOffset = prefs.getInt(_keyHijriOffset) ?? 0;

    return PrayerCalculationParameters(
      method: methodIndex != null && methodIndex < CalculationMethod.values.length
          ? CalculationMethod.values[methodIndex]
          : CalculationMethod.muslimWorldLeague,
      madhab: madhabIndex != null && madhabIndex < Madhab.values.length
          ? Madhab.values[madhabIndex]
          : Madhab.standard,
      highLatitudeRule: highLatIndex != null && highLatIndex < HighLatitudeRule.values.length
          ? HighLatitudeRule.values[highLatIndex]
          : HighLatitudeRule.angleBased,
      hijriOffsetDays: hijriOffset,
    );
  }

  static Future<void> saveParameters(PrayerCalculationParameters params) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMethod, params.method.index);
    await prefs.setInt(_keyMadhab, params.madhab.index);
    await prefs.setInt(_keyHighLat, params.highLatitudeRule.index);
    await prefs.setInt(_keyHijriOffset, params.hijriOffsetDays);
  }

  static Future<PrayerNotificationSettings> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fajr = prefs.getBool(_keyNotifFajr) ?? true;
    final sunrise = prefs.getBool(_keyNotifSunrise) ?? false;
    final dhuhr = prefs.getBool(_keyNotifDhuhr) ?? true;
    final asr = prefs.getBool(_keyNotifAsr) ?? true;
    final maghrib = prefs.getBool(_keyNotifMaghrib) ?? true;
    final isha = prefs.getBool(_keyNotifIsha) ?? true;
    final preReminder = prefs.getBool(_keyNotifPreReminder) ?? false;
    final preReminderMins = prefs.getInt(_keyNotifPreReminderMins) ?? 15;
    final quietHours = prefs.getBool(_keyQuietHours) ?? false;
    final quietStart = prefs.getInt(_keyQuietStart) ?? 1380; // 23:00
    final quietEnd = prefs.getInt(_keyQuietEnd) ?? 300; // 05:00

    return PrayerNotificationSettings(
      enableFajr: fajr,
      enableSunrise: sunrise,
      enableDhuhr: dhuhr,
      enableAsr: asr,
      enableMaghrib: maghrib,
      enableIsha: isha,
      enablePrePrayerReminder: preReminder,
      prePrayerReminderMinutes: preReminderMins,
      enableQuietHours: quietHours,
      quietHoursStartMinutes: quietStart,
      quietHoursEndMinutes: quietEnd,
    );
  }

  static Future<void> saveNotificationSettings(PrayerNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifFajr, settings.enableFajr);
    await prefs.setBool(_keyNotifSunrise, settings.enableSunrise);
    await prefs.setBool(_keyNotifDhuhr, settings.enableDhuhr);
    await prefs.setBool(_keyNotifAsr, settings.enableAsr);
    await prefs.setBool(_keyNotifMaghrib, settings.enableMaghrib);
    await prefs.setBool(_keyNotifIsha, settings.enableIsha);
    await prefs.setBool(_keyNotifPreReminder, settings.enablePrePrayerReminder);
    await prefs.setInt(_keyNotifPreReminderMins, settings.prePrayerReminderMinutes);
    await prefs.setBool(_keyQuietHours, settings.enableQuietHours);
    await prefs.setInt(_keyQuietStart, settings.quietHoursStartMinutes);
    await prefs.setInt(_keyQuietEnd, settings.quietHoursEndMinutes);
  }
}
