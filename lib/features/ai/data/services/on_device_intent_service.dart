import 'package:muslim_ultra/features/prayer/domain/models/prayer_time.dart';
import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';
import 'package:muslim_ultra/features/prayer/domain/models/qibla_direction.dart';

enum DeviceIntentType {
  prayerSchedule,
  nextPrayer,
  specificPrayer,
  hijriDate,
  qiblaDirection,
  none,
}

class OnDeviceIntentResult {
  final bool matched;
  final DeviceIntentType type;
  final String answer;
  final List<String> sources;

  const OnDeviceIntentResult({
    required this.matched,
    required this.type,
    required this.answer,
    this.sources = const [],
  });

  static const notMatched = OnDeviceIntentResult(
    matched: false,
    type: DeviceIntentType.none,
    answer: '',
  );
}

/// Service that identifies on-device utility queries (prayer times, hijri date, Qibla)
/// and resolves them locally without making network or LLM API calls.
class OnDeviceIntentService {
  /// Detects intent and creates a structured response if matched.
  static OnDeviceIntentResult evaluateQuery({
    required String query,
    required PrayerSchedule prayerSchedule,
    required HijriDate hijriDate,
    required QiblaDirectionData qiblaData,
    String language = 'en',
    DateTime? now,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    final currentTime = now ?? DateTime.now();

    // 1. Next Prayer Intent
    if (_isNextPrayerQuery(cleanQuery)) {
      final next = prayerSchedule.nextPrayer(currentTime);
      final diff = next.time.difference(currentTime);
      final minutesLeft = diff.inMinutes;
      final hoursLeft = minutesLeft ~/ 60;
      final remainingMins = minutesLeft % 60;

      final timeStr = _formatTime(next.time);
      String text;
      if (language == 'ur') {
        text = 'اگلی نماز ${next.name} ہے جو $timeStr پر ہے۔ باقی وقت: $hoursLeft گھنٹے $remainingMins منٹ۔';
      } else if (language == 'ar') {
        text = 'الصلاة القادمة هي ${next.name} في تمام الساعة $timeStr. المتبقي: $hoursLeft ساعة و $remainingMins دقيقة.';
      } else {
        text = 'The next prayer is **${next.name}** at **$timeStr** (in $hoursLeft hours and $remainingMins minutes).';
      }

      return OnDeviceIntentResult(
        matched: true,
        type: DeviceIntentType.nextPrayer,
        answer: text,
        sources: const ['[On-Device Astronomical Calculator]'],
      );
    }

    // 2. Specific Prayer Query (e.g. "when is fajr", "asr time", "maghrib kab hai")
    final specificPrayerMatch = _checkSpecificPrayer(cleanQuery, prayerSchedule, language);
    if (specificPrayerMatch != null) {
      return specificPrayerMatch;
    }

    // 3. Full Daily Prayer Schedule Intent
    if (_isPrayerScheduleQuery(cleanQuery)) {
      final buffer = StringBuffer();
      if (language == 'ur') {
        buffer.writeln('آج کے نماز کے اوقات (${prayerSchedule.locationName}):\n');
        for (final p in prayerSchedule.prayers) {
          buffer.writeln('• ${p.name}: ${_formatTime(p.time)}');
        }
      } else if (language == 'ar') {
        buffer.writeln('مواقيت الصلاة اليوم (${prayerSchedule.locationName}):\n');
        for (final p in prayerSchedule.prayers) {
          buffer.writeln('• ${p.name}: ${_formatTime(p.time)}');
        }
      } else {
        buffer.writeln('Prayer times for today in **${prayerSchedule.locationName}**:\n');
        for (final p in prayerSchedule.prayers) {
          buffer.writeln('• **${p.name}**: ${_formatTime(p.time)}');
        }
      }

      return OnDeviceIntentResult(
        matched: true,
        type: DeviceIntentType.prayerSchedule,
        answer: buffer.toString().trim(),
        sources: const ['[On-Device Astronomical Calculator]'],
      );
    }

    // 4. Hijri Calendar Date Intent
    if (_isHijriDateQuery(cleanQuery)) {
      String text;
      if (language == 'ur') {
        text = 'آج کی ہجری تاریخ ہے: **${hijriDate.formattedEn()}** (${hijriDate.day} ${hijriDate.monthNameEn} ${hijriDate.year}ھ)۔';
      } else if (language == 'ar') {
        text = 'التاريخ الهجري اليوم هو: **${hijriDate.formattedAr()}** (${hijriDate.day} ${hijriDate.monthNameAr} ${hijriDate.year} هـ).';
      } else {
        text = 'Today is **${hijriDate.formattedEn()}** (${hijriDate.day} ${hijriDate.monthNameEn} ${hijriDate.year} AH).';
      }

      return OnDeviceIntentResult(
        matched: true,
        type: DeviceIntentType.hijriDate,
        answer: text,
        sources: const ['[Umm al-Qura Calendar Engine]'],
      );
    }

    // 5. Qibla Direction Intent
    if (_isQiblaQuery(cleanQuery)) {
      final bearingStr = '${qiblaData.qiblaBearing.toStringAsFixed(1)}°';
      final distanceStr = '${qiblaData.distanceKm.toStringAsFixed(0)} km';

      String text;
      if (language == 'ur') {
        text = 'آپ کے موجودہ مقام سے قبلہ کا رخ شمال سے **$bearingStr** پر ہے (مکہ مکرمہ کا فاصلہ: $distanceStr)۔';
      } else if (language == 'ar') {
        text = 'اتجاه القبلة من موقعك الحالي هو **$bearingStr** من الشمال (المسافة إلى مكة: $distanceStr).';
      } else {
        text = 'The Qibla direction from your location is **$bearingStr** from true North (Distance to Makkah: **$distanceStr**).';
      }

      return OnDeviceIntentResult(
        matched: true,
        type: DeviceIntentType.qiblaDirection,
        answer: text,
        sources: const ['[Spherical Great-Circle Geodesic]'],
      );
    }

    return OnDeviceIntentResult.notMatched;
  }

  static bool _isNextPrayerQuery(String q) {
    return q.contains('next prayer') ||
        q.contains('next namaz') ||
        q.contains('agli namaz') ||
        q.contains('الصلاة القادمة') ||
        q.contains('upcoming prayer');
  }

  static bool _isPrayerScheduleQuery(String q) {
    return q.contains('prayer time') ||
        q.contains('prayer times') ||
        q.contains('namaz time') ||
        q.contains('namaz timings') ||
        q.contains('salah time') ||
        q.contains('salat time') ||
        q.contains('مواقيت الصلاة') ||
        q.contains('اوقات الصلاة') ||
        q.contains('نماز کا وقت') ||
        q.contains('نماز کے اوقات');
  }

  static bool _isHijriDateQuery(String q) {
    return q.contains('hijri date') ||
        q.contains('islamic date') ||
        q.contains('arabic date') ||
        q.contains('hijri calendar') ||
        q.contains('تاريخ اليوم الهجري') ||
        q.contains('التاريخ الهجري') ||
        q.contains('اسلامی تاریخ') ||
        q.contains('ہجری تاریخ') ||
        (q.contains('today') && q.contains('hijri'));
  }

  static bool _isQiblaQuery(String q) {
    return q.contains('qibla') ||
        q.contains('qiblah') ||
        q.contains('kibla') ||
        q.contains('قبلة') ||
        q.contains('القبلة') ||
        q.contains('قبلہ');
  }

  static OnDeviceIntentResult? _checkSpecificPrayer(
    String q,
    PrayerSchedule schedule,
    String language,
  ) {
    final prayers = {
      'fajr': schedule.fajr,
      'sunrise': schedule.sunrise,
      'dhuhr': schedule.dhuhr,
      'zuhr': schedule.dhuhr,
      'asr': schedule.asr,
      'asar': schedule.asr,
      'maghrib': schedule.maghrib,
      'isha': schedule.isha,
      'esha': schedule.isha,
    };

    final prayerDisplayNames = {
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'zuhr': 'Dhuhr',
      'asr': 'Asr',
      'asar': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'esha': 'Isha',
    };

    for (final entry in prayers.entries) {
      final name = entry.key;
      final prayerTime = entry.value;
      final displayName = prayerDisplayNames[name]!;

      if ((q.contains(name) || q.contains(_getArabicPrayerName(name)) || q.contains(_getUrduPrayerName(name))) &&
          (q.contains('time') ||
              q.contains('when') ||
              q.contains('kab') ||
              q.contains('وقت') ||
              q.contains('متى') ||
              q.contains('timing') ||
              q.contains('start'))) {
        final timeStr = _formatTime(prayerTime);
        String text;
        if (language == 'ur') {
          text = '$displayName کا وقت آج $timeStr پر ہے (${schedule.locationName})۔';
        } else if (language == 'ar') {
          text = 'وقت صلاة $displayName اليوم هو $timeStr (${schedule.locationName}).';
        } else {
          text = '**$displayName** prayer time today is **$timeStr** in ${schedule.locationName}.';
        }

        return OnDeviceIntentResult(
          matched: true,
          type: DeviceIntentType.specificPrayer,
          answer: text,
          sources: const ['[On-Device Astronomical Calculator]'],
        );
      }
    }

    return null;
  }

  static String _getArabicPrayerName(String key) {
    switch (key) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
      case 'zuhr':
        return 'الظهر';
      case 'asr':
      case 'asar':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
      case 'esha':
        return 'العشاء';
      default:
        return key;
    }
  }

  static String _getUrduPrayerName(String key) {
    switch (key) {
      case 'fajr':
        return 'فجر';
      case 'sunrise':
        return 'طلوع آفتاب';
      case 'dhuhr':
      case 'zuhr':
        return 'ظہر';
      case 'asr':
      case 'asar':
        return 'عصر';
      case 'maghrib':
        return 'مغرب';
      case 'isha':
      case 'esha':
        return 'عشاء';
      default:
        return key;
    }
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '$displayHour:$minute $period';
  }
}
