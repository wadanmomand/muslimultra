/// Athan Notification and Quiet Hours Settings
class PrayerNotificationSettings {
  final bool enableFajr;
  final bool enableSunrise;
  final bool enableDhuhr;
  final bool enableAsr;
  final bool enableMaghrib;
  final bool enableIsha;
  final bool enablePrePrayerReminder;
  final int prePrayerReminderMinutes;
  final bool enableQuietHours;
  final int quietHoursStartMinutes; // e.g. 23:00 (1380 mins)
  final int quietHoursEndMinutes; // e.g. 05:00 (300 mins)

  const PrayerNotificationSettings({
    this.enableFajr = true,
    this.enableSunrise = false,
    this.enableDhuhr = true,
    this.enableAsr = true,
    this.enableMaghrib = true,
    this.enableIsha = true,
    this.enablePrePrayerReminder = false,
    this.prePrayerReminderMinutes = 15,
    this.enableQuietHours = false,
    this.quietHoursStartMinutes = 1380, // 23:00
    this.quietHoursEndMinutes = 300, // 05:00
  });

  bool isPrayerEnabled(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return enableFajr;
      case 'sunrise':
        return enableSunrise;
      case 'dhuhr':
        return enableDhuhr;
      case 'asr':
        return enableAsr;
      case 'maghrib':
        return enableMaghrib;
      case 'isha':
        return enableIsha;
      default:
        return true;
    }
  }

  bool isInQuietHours(DateTime time) {
    if (!enableQuietHours) return false;
    final minutes = time.hour * 60 + time.minute;
    if (quietHoursStartMinutes > quietHoursEndMinutes) {
      // Overnight (e.g. 23:00 to 05:00)
      return minutes >= quietHoursStartMinutes || minutes < quietHoursEndMinutes;
    } else {
      return minutes >= quietHoursStartMinutes && minutes < quietHoursEndMinutes;
    }
  }

  PrayerNotificationSettings copyWith({
    bool? enableFajr,
    bool? enableSunrise,
    bool? enableDhuhr,
    bool? enableAsr,
    bool? enableMaghrib,
    bool? enableIsha,
    bool? enablePrePrayerReminder,
    int? prePrayerReminderMinutes,
    bool? enableQuietHours,
    int? quietHoursStartMinutes,
    int? quietHoursEndMinutes,
  }) {
    return PrayerNotificationSettings(
      enableFajr: enableFajr ?? this.enableFajr,
      enableSunrise: enableSunrise ?? this.enableSunrise,
      enableDhuhr: enableDhuhr ?? this.enableDhuhr,
      enableAsr: enableAsr ?? this.enableAsr,
      enableMaghrib: enableMaghrib ?? this.enableMaghrib,
      enableIsha: enableIsha ?? this.enableIsha,
      enablePrePrayerReminder: enablePrePrayerReminder ?? this.enablePrePrayerReminder,
      prePrayerReminderMinutes: prePrayerReminderMinutes ?? this.prePrayerReminderMinutes,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
      quietHoursStartMinutes: quietHoursStartMinutes ?? this.quietHoursStartMinutes,
      quietHoursEndMinutes: quietHoursEndMinutes ?? this.quietHoursEndMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrayerNotificationSettings &&
        other.enableFajr == enableFajr &&
        other.enableSunrise == enableSunrise &&
        other.enableDhuhr == enableDhuhr &&
        other.enableAsr == enableAsr &&
        other.enableMaghrib == enableMaghrib &&
        other.enableIsha == enableIsha &&
        other.enablePrePrayerReminder == enablePrePrayerReminder &&
        other.prePrayerReminderMinutes == prePrayerReminderMinutes &&
        other.enableQuietHours == enableQuietHours &&
        other.quietHoursStartMinutes == quietHoursStartMinutes &&
        other.quietHoursEndMinutes == quietHoursEndMinutes;
  }

  @override
  int get hashCode {
    return Object.hash(
      enableFajr,
      enableSunrise,
      enableDhuhr,
      enableAsr,
      enableMaghrib,
      enableIsha,
      enablePrePrayerReminder,
      prePrayerReminderMinutes,
      enableQuietHours,
      quietHoursStartMinutes,
      quietHoursEndMinutes,
    );
  }
}
