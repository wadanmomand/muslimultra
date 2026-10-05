import 'package:intl/intl.dart';

enum PrayerType {
  fajr('Fajr'),
  sunrise('Sunrise'),
  dhuhr('Dhuhr'),
  asr('Asr'),
  maghrib('Maghrib'),
  isha('Isha');

  final String label;
  const PrayerType(this.label);
}

class PrayerTimeModel {
  final PrayerType type;
  final String name;
  final DateTime time;
  final bool isPassed;
  final bool isCurrent;
  final bool isNext;

  const PrayerTimeModel({
    required this.type,
    required this.name,
    required this.time,
    this.isPassed = false,
    this.isCurrent = false,
    this.isNext = false,
  });

  String get formattedTime => DateFormat('hh:mm a').format(time);

  PrayerTimeModel copyWith({
    PrayerType? type,
    String? name,
    DateTime? time,
    bool? isPassed,
    bool? isCurrent,
    bool? isNext,
  }) {
    return PrayerTimeModel(
      type: type ?? this.type,
      name: name ?? this.name,
      time: time ?? this.time,
      isPassed: isPassed ?? this.isPassed,
      isCurrent: isCurrent ?? this.isCurrent,
      isNext: isNext ?? this.isNext,
    );
  }
}

class PrayerSchedule {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String locationName;
  final double latitude;
  final double longitude;

  const PrayerSchedule({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  List<PrayerTimeModel> get prayers {
    final now = DateTime.now();
    final next = nextPrayer(now);
    final current = currentPrayer(now);

    return [
      PrayerTimeModel(
        type: PrayerType.fajr,
        name: 'Fajr',
        time: fajr,
        isPassed: now.isAfter(fajr),
        isCurrent: current?.type == PrayerType.fajr,
        isNext: next.type == PrayerType.fajr,
      ),
      PrayerTimeModel(
        type: PrayerType.sunrise,
        name: 'Sunrise',
        time: sunrise,
        isPassed: now.isAfter(sunrise),
        isCurrent: current?.type == PrayerType.sunrise,
        isNext: next.type == PrayerType.sunrise,
      ),
      PrayerTimeModel(
        type: PrayerType.dhuhr,
        name: 'Dhuhr',
        time: dhuhr,
        isPassed: now.isAfter(dhuhr),
        isCurrent: current?.type == PrayerType.dhuhr,
        isNext: next.type == PrayerType.dhuhr,
      ),
      PrayerTimeModel(
        type: PrayerType.asr,
        name: 'Asr',
        time: asr,
        isPassed: now.isAfter(asr),
        isCurrent: current?.type == PrayerType.asr,
        isNext: next.type == PrayerType.asr,
      ),
      PrayerTimeModel(
        type: PrayerType.maghrib,
        name: 'Maghrib',
        time: maghrib,
        isPassed: now.isAfter(maghrib),
        isCurrent: current?.type == PrayerType.maghrib,
        isNext: next.type == PrayerType.maghrib,
      ),
      PrayerTimeModel(
        type: PrayerType.isha,
        name: 'Isha',
        time: isha,
        isPassed: now.isAfter(isha),
        isCurrent: current?.type == PrayerType.isha,
        isNext: next.type == PrayerType.isha,
      ),
    ];
  }

  PrayerTimeModel nextPrayer(DateTime referenceTime) {
    if (referenceTime.isBefore(fajr)) {
      return PrayerTimeModel(type: PrayerType.fajr, name: 'Fajr', time: fajr, isNext: true);
    } else if (referenceTime.isBefore(sunrise)) {
      return PrayerTimeModel(type: PrayerType.sunrise, name: 'Sunrise', time: sunrise, isNext: true);
    } else if (referenceTime.isBefore(dhuhr)) {
      return PrayerTimeModel(type: PrayerType.dhuhr, name: 'Dhuhr', time: dhuhr, isNext: true);
    } else if (referenceTime.isBefore(asr)) {
      return PrayerTimeModel(type: PrayerType.asr, name: 'Asr', time: asr, isNext: true);
    } else if (referenceTime.isBefore(maghrib)) {
      return PrayerTimeModel(type: PrayerType.maghrib, name: 'Maghrib', time: maghrib, isNext: true);
    } else if (referenceTime.isBefore(isha)) {
      return PrayerTimeModel(type: PrayerType.isha, name: 'Isha', time: isha, isNext: true);
    } else {
      // Tomorrow Fajr
      final tomorrowFajr = fajr.add(const Duration(days: 1));
      return PrayerTimeModel(type: PrayerType.fajr, name: 'Fajr', time: tomorrowFajr, isNext: true);
    }
  }

  PrayerTimeModel? currentPrayer(DateTime referenceTime) {
    if (referenceTime.isAfter(isha)) {
      return PrayerTimeModel(type: PrayerType.isha, name: 'Isha', time: isha, isCurrent: true);
    } else if (referenceTime.isAfter(maghrib)) {
      return PrayerTimeModel(type: PrayerType.maghrib, name: 'Maghrib', time: maghrib, isCurrent: true);
    } else if (referenceTime.isAfter(asr)) {
      return PrayerTimeModel(type: PrayerType.asr, name: 'Asr', time: asr, isCurrent: true);
    } else if (referenceTime.isAfter(dhuhr)) {
      return PrayerTimeModel(type: PrayerType.dhuhr, name: 'Dhuhr', time: dhuhr, isCurrent: true);
    } else if (referenceTime.isAfter(sunrise)) {
      return PrayerTimeModel(type: PrayerType.sunrise, name: 'Sunrise', time: sunrise, isCurrent: true);
    } else if (referenceTime.isAfter(fajr)) {
      return PrayerTimeModel(type: PrayerType.fajr, name: 'Fajr', time: fajr, isCurrent: true);
    }
    return null;
  }
}
