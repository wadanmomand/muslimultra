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
  String get audioRepeatOff => translate('audio_repeat_off');
  String get audioRepeatAyah => translate('audio_repeat_ayah');
  String get audioRepeatSurah => translate('audio_repeat_surah');
  String get audioSleepTimer => translate('audio_sleep_timer');
  String get audioSleepTimerOff => translate('audio_sleep_timer_off');
  String get audioPlaybackSpeed => translate('audio_playback_speed');
  String get audioLoadError => translate('audio_load_error');
  String get allDuas => translate('all_duas');
  String get searchDuasPlaceholder => translate('search_duas_placeholder');
  String get noDuasFound => translate('no_duas_found');
  String get noDuasFoundDesc => translate('no_duas_found_desc');
  String get copyDua => translate('copy_dua');
  String get shareDua => translate('share_dua');
  String get duaCopied => translate('dua_copied');
  String get sourceReference => translate('source_reference');
  String get hisnUlMuslim => translate('hisn_ul_muslim');
  String get academy => translate('academy');
  String get academyTitle => translate('academy_title');
  String get academyHeroBadge => translate('academy_hero_badge');
  String get academyHeroTitle => translate('academy_hero_title');
  String get academyHeroSubtitle => translate('academy_hero_subtitle');
  String get bookFreeTrial => translate('book_free_trial');
  String get explorePrograms => translate('explore_programs');
  String get expertTeachers => translate('expert_teachers');
  String get offlineCacheNotice => translate('offline_cache_notice');
  String get viewProgramDetails => translate('view_program_details');
  String get programDuration => translate('program_duration');
  String get programSchedule => translate('program_schedule');
  String get programFee => translate('program_fee');
  String get bookingFormTitle => translate('booking_form_title');
  String get bookingStudentName => translate('booking_student_name');
  String get bookingStudentNameHint => translate('booking_student_name_hint');
  String get bookingContact => translate('booking_contact');
  String get bookingContactHint => translate('booking_contact_hint');
  String get bookingProgram => translate('booking_program');
  String get bookingPreferredTime => translate('booking_preferred_time');
  String get bookingTimeFlexible => translate('booking_time_flexible');
  String get bookingTimeMorning => translate('booking_time_morning');
  String get bookingTimeAfternoon => translate('booking_time_afternoon');
  String get bookingTimeEvening => translate('booking_time_evening');
  String get bookingNotes => translate('booking_notes');
  String get bookingNotesHint => translate('booking_notes_hint');
  String get bookingSubmitBtn => translate('booking_submit_btn');
  String get bookingSuccessTitle => translate('booking_success_title');
  String get bookingSuccessDesc => translate('booking_success_desc');
  String get bookingNameRequired => translate('booking_name_required');
  String get bookingContactRequired => translate('booking_contact_required');
  String get bookingFailedError => translate('booking_failed_error');
  String get backToAcademy => translate('back_to_academy');
  String get refresh => translate('refresh');

  // Zakat Calculator
  String get zakat => translate('zakat');
  String get zakatCalculator => translate('zakat_calculator');
  String get zakatSubtitle => translate('zakat_subtitle');
  String get nisabStandard => translate('nisab_standard');
  String get silverStandard => translate('silver_standard');
  String get goldStandard => translate('gold_standard');
  String get nisabStandardNote => translate('nisab_standard_note');
  String get currency => translate('currency');
  String get metalPrices => translate('metal_prices');
  String get metalPricesHint => translate('metal_prices_hint');
  String get goldPricePerGram => translate('gold_price_per_gram');
  String get silverPricePerGram => translate('silver_price_per_gram');
  String get assetsCategory => translate('assets_category');
  String get cashInHand => translate('cash_in_hand');
  String get bankSavings => translate('bank_savings');
  String get goldWeightGrams => translate('gold_weight_grams');
  String get silverWeightGrams => translate('silver_weight_grams');
  String get investmentsShares => translate('investments_shares');
  String get businessInventory => translate('business_inventory');
  String get moneyOwedToYou => translate('money_owed_to_you');
  String get deductiblesCategory => translate('deductibles_category');
  String get debtsOwed => translate('debts_owed');
  String get immediateExpenses => translate('immediate_expenses');
  String get zakatSummary => translate('zakat_summary');
  String get totalAssets => translate('total_assets');
  String get totalDebts => translate('total_debts');
  String get netWealth => translate('net_wealth');
  String get nisabThreshold => translate('nisab_threshold');
  String get zakatStatusEligible => translate('zakat_status_eligible');
  String get zakatStatusNotEligible => translate('zakat_status_not_eligible');
  String get zakatAmountDue => translate('zakat_amount_due');
  String get resetCalculator => translate('reset_calculator');
  String get resetConfirm => translate('reset_confirm');
  String get rulesInfoTitle => translate('rules_info_title');
  String get nonZakatableInfo => translate('non_zakatable_info');
  String get hawlInfo => translate('hawl_info');
  String get scholarDisclaimer => translate('scholar_disclaimer');

  // Asma ul Husna
  String get asmaUlHusna => translate('asma_ul_husna');
  String get asmaSubtitle => translate('asma_subtitle');
  String get searchAsmaHint => translate('search_asma_hint');
  String get noNamesFound => translate('no_names_found');
  String get sourceTirmidhi => translate('source_tirmidhi');
  String get tirmidhiScholarlyNote => translate('tirmidhi_scholarly_note');
  String get nameOf99 => translate('name_of_99');
  String get meaningEnglish => translate('meaning_english');
  String get meaningUrdu => translate('meaning_urdu');
  String get previousName => translate('previous_name');
  String get nextName => translate('next_name');
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
