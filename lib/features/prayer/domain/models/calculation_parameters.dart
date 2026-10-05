/// Calculation Methods supported by Muslim Ultra (Spec §3 M1)
enum CalculationMethod {
  muslimWorldLeague('Muslim World League (MWL)', 18.0, 17.0),
  isna('Islamic Society of North America (ISNA)', 15.0, 15.0),
  egyptian('Egyptian General Authority of Survey', 19.5, 17.5),
  karachi('University of Islamic Sciences, Karachi', 18.0, 18.0),
  ummAlQura('Umm al-Qura University, Makkah', 18.5, null, ishaInterval: 90),
  dubai('Dubai (UAE)', 18.2, 18.2),
  jakim('JAKIM (Malaysia)', 20.0, 18.0),
  diyanet('Diyanet (Turkey)', 18.0, 17.0),
  morocco('Morocco (Habous)', 19.0, 17.0),
  tunisia('Tunisia', 18.0, 18.0),
  algeria('Algeria (Ministry of Religious Affairs)', 18.0, 17.0),
  jordan('Jordan (Ministry of Awqaf)', 18.0, 18.0);

  final String title;
  final double fajrAngle;
  final double? ishaAngle;
  final int? ishaInterval; // minutes after Maghrib

  const CalculationMethod(
    this.title,
    this.fajrAngle,
    this.ishaAngle, {
    this.ishaInterval,
  });
}

/// Asr Juristic Method (Madhab)
enum Madhab {
  standard('Standard (Shafi\'i, Maliki, Hanbali)', 1),
  hanafi('Hanafi', 2);

  final String title;
  final int shadowFactor;

  const Madhab(this.title, this.shadowFactor);
}

/// High Latitude Adjustment Rule
enum HighLatitudeRule {
  middleOfTheNight('Middle of the Night'),
  oneSeventh('One Seventh of Night'),
  angleBased('Angle-based Rule');

  final String title;
  const HighLatitudeRule(this.title);
}

/// Prayer calculation settings container
class PrayerCalculationParameters {
  final CalculationMethod method;
  final Madhab madhab;
  final HighLatitudeRule highLatitudeRule;
  final int hijriOffsetDays; // Umm al-Qura ±1 day

  const PrayerCalculationParameters({
    this.method = CalculationMethod.muslimWorldLeague,
    this.madhab = Madhab.standard,
    this.highLatitudeRule = HighLatitudeRule.angleBased,
    this.hijriOffsetDays = 0,
  });

  PrayerCalculationParameters copyWith({
    CalculationMethod? method,
    Madhab? madhab,
    HighLatitudeRule? highLatitudeRule,
    int? hijriOffsetDays,
  }) {
    return PrayerCalculationParameters(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
      hijriOffsetDays: hijriOffsetDays ?? this.hijriOffsetDays,
    );
  }
}
