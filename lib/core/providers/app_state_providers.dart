import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App Locale StateNotifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale newLocale) {
    if (state != newLocale) {
      state = newLocale;
    }
  }

  void setLanguage(String languageCode) {
    if (['en', 'ar', 'ur'].contains(languageCode)) {
      state = Locale(languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// App Theme Mode StateNotifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Bottom Navigation Index Provider
/// 0: Today, 1: Prayer, 2: Quran, 3: Dua, 4: Muslim AI
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Prayer Tab Sub-view Mode (Prayer Timetable vs Qibla Compass)
enum PrayerTabMode { times, qibla }

final prayerTabModeProvider = StateProvider<PrayerTabMode>((ref) => PrayerTabMode.times);
