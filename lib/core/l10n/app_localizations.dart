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

  // Hijri Calendar
  String get hijriCalendar => translate('hijri_calendar');
  String get hijriCalendarSubtitle => translate('hijri_calendar_subtitle');
  String get today => translate('today');
  String get todayEvent => translate('today_event');
  String get tomorrow => translate('tomorrow');
  String inDays(int count) {
    final pattern = translate('in_days');
    return pattern.replaceAll('{count}', count.toString());
  }
  String get daysRemaining => translate('days_remaining');
  String get eventsThisMonth => translate('events_this_month');
  String get noEventsThisDay => translate('no_events_this_day');
  String get eventDetails => translate('event_details');
  String get moonSightingDisclaimer => translate('moon_sighting_disclaimer');
  String get ahSuffix => translate('ah_suffix');

  // Fasting & Ramadan Tracker
  String get fasting => translate('fasting');
  String get fastingTrackerTitle => translate('fasting_tracker_title');
  String get suhoorEndsIn => translate('suhoor_ends_in');
  String get suhoorEndsAt => translate('suhoor_ends_at');
  String get suhoorCautionNote => translate('suhoor_caution_note');
  String get iftarIn => translate('iftar_in');
  String get iftarAt => translate('iftar_at');
  String get fastingHoursProgress => translate('fasting_hours_progress');
  String get fastingCompletedToday => translate('fasting_completed_today');
  String get nextSuhoorTomorrow => translate('next_suhoor_tomorrow');
  String get fastingIntentionLabel => translate('fasting_intention_label');
  String get logTodayFast => translate('log_today_fast');
  String get currentStreak => translate('current_streak');
  String get fastsThisMonth => translate('fasts_this_month');
  String get makeupOwed => translate('makeup_owed');
  String get daysUnit => translate('days_unit');
  String get fastsUnit => translate('fasts_unit');
  String get ramadanChecklistTitle => translate('ramadan_checklist_title');
  String get checklistSuhoor => translate('checklist_suhoor');
  String get checklistSuhoorSub => translate('checklist_suhoor_sub');
  String get checklistFastKept => translate('checklist_fast_kept');
  String get checklistFastKeptSub => translate('checklist_fast_kept_sub');
  String get checklistTaraweeh => translate('checklist_taraweeh');
  String get checklistTaraweehSub => translate('checklist_taraweeh_sub');
  String get checklistQuran => translate('checklist_quran');
  String get checklistQuranSub => translate('checklist_quran_sub');
  String get checklistDua => translate('checklist_dua');
  String get checklistDuaSub => translate('checklist_dua_sub');
  String get fastHistoryTitle => translate('fast_history_title');
  String get addFastBtn => translate('add_fast_btn');
  String get filterAll => translate('filter_all');
  String get statusKept => translate('status_kept');
  String get statusMissed => translate('status_missed');
  String get statusQada => translate('status_qada');
  String get noFastsLogged => translate('no_fasts_logged');
  String get noFastsLoggedDesc => translate('no_fasts_logged_desc');
  String get logFastTitle => translate('log_fast_title');
  String get editFastTitle => translate('edit_fast_title');
  String get fastStatusLabel => translate('fast_status_label');
  String get notesOptional => translate('notes_optional');
  String get notesPlaceholder => translate('notes_placeholder');
  String get deleteEntry => translate('delete_entry');
  String get save => translate('save');

  // Tajweed Color Mode
  String get tajweedMode => translate('tajweed_mode');
  String get tajweedModeSubtitle => translate('tajweed_mode_subtitle');
  String get tajweedLegend => translate('tajweed_legend');
  String get tajweedLegendSubtitle => translate('tajweed_legend_subtitle');
  String get tajweedCategoryGhunnah => translate('tajweed_category_ghunnah');
  String get tajweedCategoryIkhfa => translate('tajweed_category_ikhfa');
  String get tajweedCategoryMadd => translate('tajweed_category_madd');
  String get tajweedCategoryQalqalah => translate('tajweed_category_qalqalah');
  String get tajweedCategorySilent => translate('tajweed_category_silent');

  String getTajweedRuleName(String ruleId) => translate('rule_${ruleId}_name');
  String getTajweedRuleDescription(String ruleId) => translate('rule_${ruleId}_desc');

  // Hadith Library (40 Nawawi)
  String get hadithLibraryTitle => translate('hadith_library_title');
  String get hadithLibrarySubtitle => translate('hadith_library_subtitle');
  String get searchHadithHint => translate('search_hadith_hint');
  String get categoryAll => translate('category_all');
  String hadithNumberPrefix(int number) {
    final pattern = translate('hadith_number_prefix');
    return pattern.replaceAll('{number}', number.toString());
  }
  String get narratorLabel => translate('narrator_label');
  String get sourceLabel => translate('source_label');
  String get categoriesLabel => translate('categories_label');
  String get arabicTextLabel => translate('arabic_text_label');
  String get englishTextLabel => translate('english_text_label');
  String get urduTextLabel => translate('urdu_text_label');
  String get copyHadith => translate('copy_hadith');
  String get shareHadith => translate('share_hadith');
  String get hadithCopiedToast => translate('hadith_copied_toast');
  String get noHadithFound => translate('no_hadith_found');
  String get noHadithFoundDesc => translate('no_hadith_found_desc');
  String get couldNotLoadHadith => translate('could_not_load_hadith');
  String get quickActionHadith => translate('quick_action_hadith');
  String get quickActionHadithSub => translate('quick_action_hadith_sub');

  String getHadithCategoryName(String category) {
    final key = 'hadith_cat_${category.toLowerCase().trim()}';
    final translated = translate(key);
    if (translated.isNotEmpty && translated != key) {
      return translated;
    }
    // Fallback: capitalize
    if (category.isEmpty) return '';
    return category[0].toUpperCase() + category.substring(1).replaceAll('_', ' ');
  }

  // Prayer Tracking & Streaks
  String get prayerTrackerTitle => translate('prayer_tracker_title');
  String get prayerTrackerSubtitle => translate('prayer_tracker_subtitle');
  String get statusPrayed => translate('status_prayed');
  String get statusMissedPrayer => translate('status_missed_prayer');
  String get statusQadaPrayer => translate('status_qada_prayer');
  String get currentPrayerStreak => translate('current_prayer_streak');
  String get bestPrayerStreak => translate('best_prayer_streak');
  String get weeklyPrayerSummary => translate('weekly_prayer_summary');
  String get monthlyPrayerConsistency => translate('monthly_prayer_consistency');
  String get tapPrayerToLogHint => translate('tap_prayer_to_log_hint');
  String prayedCountOfTotal(int prayed) {
    final pattern = translate('prayed_count_of_total');
    return pattern.replaceAll('{prayed}', prayed.toString());
  }
  String get quickActionPrayerLog => translate('quick_action_prayer_log');
  String get quickActionPrayerLogSub => translate('quick_action_prayer_log_sub');

  // Daily Deen & XP Engine
  String get todaysDeenTitle => translate('todays_deen_title');
  String get xpToNextLevelSuffix => translate('xp_to_next_level_suffix');
  String get maxLevelReached => translate('max_level_reached');
  String get fivePrayersChecklistLabel => translate('five_prayers_checklist_label');
  String get prayedStatusSuffix => translate('prayed_status_suffix');
  String get quranGoalChecklistLabel => translate('quran_goal_checklist_label');
  String get quranMinutesGoalSuffix => translate('quran_minutes_goal_suffix');
  String get dhikrChecklistLabel => translate('dhikr_checklist_label');
  String get morningDhikrChip => translate('morning_dhikr_chip');
  String get eveningDhikrChip => translate('evening_dhikr_chip');
  String get streakDaysCount => translate('streak_days_count');
  String get streakFreezeAvailableButton => translate('streak_freeze_available_button');
  String get freezeDialogTitle => translate('freeze_dialog_title');
  String get freezeDialogBody => translate('freeze_dialog_body');
  String get applyFreezeButton => translate('apply_freeze_button');
  String get freezeAppliedToast => translate('freeze_applied_toast');
  String get logQuranMinutesTitle => translate('log_quran_minutes_title');
  String get todaysLearningTitle => translate('todays_learning_title');
  String get learningViewedToast => translate('learning_viewed_toast');
  String get nameOfDayBadge => translate('name_of_day_badge');

  // Daily Quiz Challenge
  String get dailyQuizCardHeading => translate('daily_quiz_card_heading');
  String get quizTodayReady => translate('quiz_today_ready');
  String get quizAnsweredCorrect => translate('quiz_answered_correct');
  String get quizAnsweredCompleted => translate('quiz_answered_completed');
  String get quizTapToPlayHint => translate('quiz_tap_to_play_hint');
  String get quizReviewHint => translate('quiz_review_hint');
  String get quizTitle => translate('quiz_title');
  String get quizSubtitle => translate('quiz_subtitle');
  String get quizCorrectHeading => translate('quiz_correct_heading');
  String get quizExplanationHeading => translate('quiz_explanation_heading');
  String get quizLoadError => translate('quiz_load_error');
  String get quizQuickActionTitle => translate('quiz_quick_action_title');

  // Weekly Deen Report
  String get weeklyReportTitle => translate('weekly_report_title');
  String get weeklyReportHeroHeading => translate('weekly_report_hero_heading');
  String get weeklyXpEarnedSuffix => translate('weekly_xp_earned_suffix');
  String get weeklyPrayersStat => translate('weekly_prayers_stat');
  String get weeklyQuranStat => translate('weekly_quran_stat');
  String get weeklyQuranGoalSubtitle => translate('weekly_quran_goal_subtitle');
  String get weeklyQuizStat => translate('weekly_quiz_stat');
  String get shareReportButton => translate('share_report_button');
  String get reportCopiedSnackbar => translate('report_copied_snackbar');
  String get reportLoadError => translate('report_load_error');

  // Quran Khatmah Tracker
  String get khatmahTitle => translate('khatmah_title');
  String get khatmahCurrentGoal => translate('khatmah_current_goal');
  String get khatmahCompletedPlural => translate('khatmah_completed_plural');
  String get khatmahGridTitle => translate('khatmah_grid_title');
  String get juzLabel => translate('juz_label');
  String get khatmahCelebrationMessage => translate('khatmah_celebration_message');
  String get khatmahLoadError => translate('khatmah_load_error');
  String get khatmahQuickActionTitle => translate('khatmah_quick_action_title');

  // Sadaqah Tracker
  String get sadaqahTitle => translate('sadaqah_title');
  String get logSadaqahTitle => translate('log_sadaqah_title');
  String get amountLabel => translate('amount_label');
  String get optionalNoteLabel => translate('optional_note_label');
  String get sadaqahThisMonth => translate('sadaqah_this_month');
  String get sadaqahAllTime => translate('sadaqah_all_time');
  String get sadaqahHistoryTitle => translate('sadaqah_history_title');
  String get sadaqahEmptyState => translate('sadaqah_empty_state');
  String get sadaqahLoadError => translate('sadaqah_load_error');
  String get sadaqahQuickActionTitle => translate('sadaqah_quick_action_title');

  // Activity Heatmap (v1.7)
  String get heatmapTitle => translate('heatmap_title');
  String get heatmapSubtitle => translate('heatmap_subtitle');
  String get heatmapLegendLess => translate('heatmap_legend_less');
  String get heatmapLegendMore => translate('heatmap_legend_more');
  String get heatmapActivityLabel => translate('heatmap_activity_label');
  String get heatmapPrayersDone => translate('heatmap_prayers_done');
  String get heatmapQuranMins => translate('heatmap_quran_mins');
  String get heatmapFasting => translate('heatmap_fasting');
  String get heatmapFastKept => translate('heatmap_fast_kept');
  String get heatmapNoFast => translate('heatmap_no_fast');
  String get heatmapXpEarned => translate('heatmap_xp_earned');

  // Dua Journal (v1.7)
  String get duaJournalTitle => translate('dua_journal_title');
  String get duaJournalPrivacyNotice => translate('dua_journal_privacy_notice');
  String get duaJournalFilterAll => translate('dua_journal_filter_all');
  String get duaJournalFilterPending => translate('dua_journal_filter_pending');
  String get duaJournalFilterAnswered => translate('dua_journal_filter_answered');
  String get duaJournalEmpty => translate('dua_journal_empty');
  String get duaJournalEmptyTitle => translate('dua_journal_empty_title');
  String get duaJournalEmptySubtitle => translate('dua_journal_empty_subtitle');
  String get duaJournalAddTitle => translate('dua_journal_add_title');
  String get duaJournalAddHint => translate('dua_journal_add_hint');
  String get duaJournalInputHint => translate('dua_journal_input_hint');
  String get duaJournalSave => translate('dua_journal_save');
  String get duaJournalMarkAnswered => translate('dua_journal_mark_answered');
  String get duaJournalMarkPending => translate('dua_journal_mark_pending');
  String get duaJournalActionMarkAnswered => translate('dua_journal_action_mark_answered');
  String get duaJournalActionMarkPending => translate('dua_journal_action_mark_pending');
  String get duaJournalStatusAnswered => translate('dua_journal_status_answered');
  String get duaJournalDelete => translate('dua_journal_delete');
  String get duaJournalDeleteConfirm => translate('dua_journal_delete_confirm');
  String get duaJournalLoadError => translate('dua_journal_load_error');
  String get duaJournalQuickActionTitle => translate('dua_journal_quick_action_title');


  // Mood -> Dhikr (v1.7)
  String get moodScreenTitle => translate('mood_screen_title');
  String get moodHeaderPrompt => translate('mood_header_prompt');
  String get moodHeaderSubtitle => translate('mood_header_subtitle');
  String get recommendedDhikrLabel => translate('recommended_dhikr_label');
  String get startDhikrButton => translate('start_dhikr_button');
  String get moodCheckinCardTitle => translate('mood_checkin_card_title');
  String get moodCheckinCardSubtitle => translate('mood_checkin_card_subtitle');
  String get tapToViewDhikr => translate('tap_to_view_dhikr');

  // Milestone Cards (v1.7)
  String get milestoneCopiedSnackbar => translate('milestone_copied_snackbar');
  String get shareMilestoneButton => translate('share_milestone_button');
  String get milestoneDismissButton => translate('milestone_dismiss_button');

  // Deen Score (v1.7)
  String get deenScoreTitle => translate('deen_score_title');
  String get quranScoreLabel => translate('quran_score_label');
  String get dhikrScoreLabel => translate('dhikr_score_label');
  String get quizScoreLabel => translate('quiz_score_label');
  String get learningScoreLabel => translate('learning_score_label');

  // Evening Reminder (v1.7)
  String get eveningReminderMenuLabel => translate('evening_reminder_menu_label');
  String get reminderEnabledToast => translate('reminder_enabled_toast');
  String get reminderDisabledToast => translate('reminder_disabled_toast');

  // Hajj & Umrah Guide (v1.8)
  String get hajjGuideTitle => translate('hajj_guide_title');
  String get hajjQuickActionTitle => translate('hajj_quick_action_title');
  String get hajjPhaseUmrah => translate('hajj_phase_umrah');
  String get hajjPhaseHajj => translate('hajj_phase_hajj');
  String get hajjPhaseChecklist => translate('hajj_phase_checklist');
  String get hajjStepsCompletedCount => translate('hajj_steps_completed_count');
  String hajjStepNumberPrefix(int number) {
    final pattern = translate('hajj_step_number_prefix');
    return pattern.replaceAll('{number}', number.toString());
  }
  String get hajjMarkDoneButton => translate('hajj_mark_done_button');
  String get hajjMarkPendingButton => translate('hajj_mark_pending_button');
  String get hajjCompletedButtonLabel => translate('hajj_completed_button_label');
  String get hajjStepCompletedToast => translate('hajj_step_completed_toast');
  String get hajjStepPendingToast => translate('hajj_step_pending_toast');
  String get hajjDuaSectionTitle => translate('hajj_dua_section_title');
  String get hajjDuaBadge => translate('hajj_dua_badge');
  String get hajjScholarDisclaimer => translate('hajj_scholar_disclaimer');
  String get dhulHijjahBannerText => translate('dhul_hijjah_banner_text');
  String get hajjLoadError => translate('hajj_load_error');

  // Tafsir (v1.9)
  String get tafsir => translate('tafsir');
  String get tafsirTabEnglish => translate('tafsir_tab_english');
  String get tafsirTabArabic => translate('tafsir_tab_arabic');
  String get tafsirTabUrdu => translate('tafsir_tab_urdu');
  String get tafsirSourceFooter => translate('tafsir_source_footer');
  String get tafsirSourceJalalayn => translate('tafsir_source_jalalayn');
  String get tafsirSourceBayanUlQuran => translate('tafsir_source_bayan_ul_quran');
  String get tafsirArabicUnavailableNote => translate('tafsir_arabic_unavailable_note');
  String get tafsirUrduComingSoon => translate('tafsir_urdu_coming_soon');
  String get tafsirCoverageHint => translate('tafsir_coverage_hint');
  String get tafsirCopyLabel => translate('tafsir_copy_label');
  String get tafsirCopiedToast => translate('tafsir_copied_toast');
  String get tafsirLoadError => translate('tafsir_load_error');

  // Muhasaba (v2.0)
  String get muhasabaTitle => translate('muhasaba_title');
  String get muhasabaSubtitle => translate('muhasaba_subtitle');
  String get muhasabaPrivacyNote => translate('muhasaba_privacy_note');
  String get muhasabaQ1 => translate('muhasaba_q1');
  String get muhasabaQ2 => translate('muhasaba_q2');
  String get muhasabaQ3 => translate('muhasaba_q3');
  String get muhasabaQ4 => translate('muhasaba_q4');
  String get muhasabaQ5 => translate('muhasaba_q5');
  String get muhasabaQ6 => translate('muhasaba_q6');
  String get muhasabaYes => translate('muhasaba_yes');
  String get muhasabaPartly => translate('muhasaba_partly');
  String get muhasabaNo => translate('muhasaba_no');
  String get localeName => locale.languageCode;

  String muhasabaProgress(int completed, int total) {
    final pattern = translate('muhasaba_progress');
    return pattern
        .replaceAll('{completed}', completed.toString())
        .replaceAll('{total}', total.toString());
  }

  String get muhasabaAllCompleted => translate('muhasaba_all_completed');
  String get muhasabaSave => translate('muhasaba_save');
  String get muhasabaSavedToast => translate('muhasaba_saved_toast');
  String get muhasabaWeeklySummary => translate('muhasaba_weekly_summary');

  String muhasabaStreak(int days) {
    final pattern = translate('muhasaba_streak_label');
    return pattern.replaceAll('{days}', days.toString());
  }
  String get muhasabaReminderSetting => translate('muhasaba_reminder_setting');
  String get muhasabaReminderTitle => translate('muhasaba_reminder_title');
  String get muhasabaReminderBody => translate('muhasaba_reminder_body');
  String get muhasabaReadOnlyBadge => translate('muhasaba_read_only_badge');
  String get muhasabaNoEntryPast => translate('muhasaba_no_entry_past');
  String get muhasabaToday => translate('muhasaba_today');
  String get muhasabaYesterday => translate('muhasaba_yesterday');

  // Qaza Debt (v2.1)
  String get qazaDebtTitle => translate('qaza_debt_title');
  String get qazaDebtSubtitle => translate('qaza_debt_subtitle');
  String get qazaDebtCardHint => translate('qaza_debt_card_hint');
  String get qazaTotalBalanceLabel => translate('qaza_total_balance_label');
  String get qazaPrayersUnit => translate('qaza_prayers_unit');
  String get qazaEmptyState => translate('qaza_empty_state');
  String get qazaGentleEncouragement => translate('qaza_gentle_encouragement');
  String get qazaThisWeekLabel => translate('qaza_this_week_label');
  String get qazaBreakdownTitle => translate('qaza_breakdown_title');
  String qazaPrayerDue(int count) {
    final pattern = translate('qaza_prayer_due');
    return pattern.replaceAll('{count}', count.toString());
  }
  String get qazaRepayButton => translate('qaza_repay_button');
  String qazaRepaidSnackbar(String prayer) {
    final pattern = translate('qaza_repaid_snackbar');
    return pattern.replaceAll('{prayer}', prayer);
  }
  String get qazaLoadError => translate('qaza_load_error');
  String get undo => translate('undo');

  // Quran Share Card (v2.2)
  String get shareAyahLabel => translate('share_ayah_label');
  String get sharePreviewTitle => translate('share_preview_title');
  String get shareCardButton => translate('share_card_button');
  String get shareGeneratingImage => translate('share_generating_image');
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
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
