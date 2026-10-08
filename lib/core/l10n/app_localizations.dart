import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Muslim Ultra JSON-backed Localization System
class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('ur'), // Urdu
  ];

  static bool isSupported(Locale locale) {
    return supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  /// Whether current locale is right-to-left
  bool get isRtl => locale.languageCode == 'ar' || locale.languageCode == 'ur';

  /// Load strings from l10n/{languageCode}.json
  Future<bool> load() async {
    try {
      final String jsonString = await rootBundle
          .loadString('l10n/${locale.languageCode}.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      return true;
    } catch (e) {
      // Fallback to English if loading specific language failed
      if (locale.languageCode != 'en') {
        try {
          final String fallbackString =
              await rootBundle.loadString('l10n/en.json');
          final Map<String, dynamic> fallbackMap = json.decode(fallbackString);
          _localizedStrings = fallbackMap.map((key, value) {
            return MapEntry(key, value.toString());
          });
          return true;
        } catch (_) {}
      }
      return false;
    }
  }

  /// Translate key
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common Getters for type-safe convenient access
  String get appName => translate('app_name');
  String get tagline => translate('tagline');
  String get navHome => translate('nav_home');
  String get navPrayer => translate('nav_prayer');
  String get navQuran => translate('nav_quran');
  String get navDua => translate('nav_dua');
  String get navAi => translate('nav_ai');
  String get settings => translate('settings');
  String get language => translate('language');
  String get theme => translate('theme');
  String get themeDark => translate('theme_dark');
  String get themeLight => translate('theme_light');
  String get themeSystem => translate('theme_system');
  String get selectLanguage => translate('select_language');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get urdu => translate('urdu');
  String get nextPrayer => translate('next_prayer');
  String get fajr => translate('fajr');
  String get sunrise => translate('sunrise');
  String get dhuhr => translate('dhuhr');
  String get asr => translate('asr');
  String get maghrib => translate('maghrib');
  String get isha => translate('isha');
  String get qibla => translate('qibla');
  String get qiblaCompass => translate('qibla_compass');
  String get dailyVerse => translate('daily_verse');
  String get dailyHadith => translate('daily_hadith');
  String get dailyChecklist => translate('daily_checklist');
  String get comingSoon => translate('coming_soon');
  String get privacyNotice => translate('privacy_notice');
  String get quickActions => translate('quick_actions');
  String get askAiPlaceholder => translate('ask_ai_placeholder');
  String get surahList => translate('surah_list');
  String get duasCategories => translate('duas_categories');
  String get statusActive => translate('status_active');
  String get notifications => translate('notifications');
  String get noNotifications => translate('no_notifications');
  String get noNotificationsDesc => translate('no_notifications_desc');
  String get features => translate('features');
  String get prayerTimes => translate('prayer_times');
  String get remaining => translate('remaining');
  String get close => translate('close');
  String get tasbih => translate('tasbih');
  String get tasbihCounter => translate('tasbih_counter');
  String get todayTotal => translate('today_total');
  String get target => translate('target');
  String get targetReached => translate('target_reached');
  String get reset => translate('reset');
  String get resetConfirmTitle => translate('reset_confirm_title');
  String get resetConfirmDesc => translate('reset_confirm_desc');
  String get cancel => translate('cancel');
  String get customTarget => translate('custom_target');
  String get setTarget => translate('set_target');
  String get presets => translate('presets');
  String get dhikrSubhanallahTrans => translate('dhikr_subhanallah_trans');
  String get dhikrAlhamdulillahTrans => translate('dhikr_alhamdulillah_trans');
  String get dhikrAllahuakbarTrans => translate('dhikr_allahuakbar_trans');
  String get dhikrLailahaillallahTrans => translate('dhikr_lailahaillallah_trans');
  String get dhikrAstaghfirullahTrans => translate('dhikr_astaghfirullah_trans');
  String get dhikrSubhanallahBihamdihiTrans => translate('dhikr_subhanallah_bihamdihi_trans');
  String get quranLoadErrorTitle => translate('quran_load_error_title');
  String get quranLoadErrorDesc => translate('quran_load_error_desc');
  String get retry => translate('retry');
  String get readingModeTranslation => translate('reading_mode_translation');
  String get readingModeMushaf => translate('reading_mode_mushaf');
  String get prayerNotifications => translate('prayer_notifications');
  String get prayerNotificationsDesc => translate('prayer_notifications_desc');
  String get prePrayerReminder => translate('pre_prayer_reminder');
  String get prePrayerReminderDesc => translate('pre_prayer_reminder_desc');
  String get quietHoursTitle => translate('quiet_hours_title');
  String get quietHoursDesc => translate('quiet_hours_desc');
  String get exactAlarmTitle => translate('exact_alarm_title');
  String get exactAlarmDesc => translate('exact_alarm_desc');
  String get enableExactAlarm => translate('enable_exact_alarm');
  String get athanAudioNotice => translate('athan_audio_notice');
  String get athanAudioDesc => translate('athan_audio_desc');
  String get allDuas => translate('all_duas');
  String get searchDuasPlaceholder => translate('search_duas_placeholder');
  String get noDuasFound => translate('no_duas_found');
  String get noDuasFoundDesc => translate('no_duas_found_desc');
  String get copyDua => translate('copy_dua');
  String get shareDua => translate('share_dua');
  String get duaCopied => translate('dua_copied');
  String get sourceReference => translate('source_reference');
  String get hisnUlMuslim => translate('hisn_ul_muslim');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'ur'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
