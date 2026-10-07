/// Muslim Ultra Application Configuration & Feature Flags
class AppConfig {
  static const String appName = 'Muslim Ultra';
  static const String packageName = 'com.muslimultra.app';
  static const String appVersion = '1.0.0+1';
  static const String milestone = 'Milestone 4';

  // API Endpoints & Supabase Secrets (Configured via env or fallback)
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static const String hadithApiBaseUrl = 'https://api.hadith.gading.dev';
  static const String deenCompanionAiEndpoint = 'https://ai.muslimultra.app/v1/chat';

  // Privacy & Device Settings (Spec §7)
  // Strict on-device computation: No location data sent to remote servers
  static const bool onDeviceLocationCalculation = true;
  static const bool analyticsEnabledDefault = false;
  static const bool crashReportingEnabledDefault = false;

  // Feature Flags
  static const bool enablePrayerTimes = true;
  static const bool enableQuranReader = true;
  static const bool enableAiDeenCompanion = true;
  static const bool enableDuaAzkar = true;
  static const bool enableDailyChecklist = true;
  static const bool enableOfflineSync = true;
}
