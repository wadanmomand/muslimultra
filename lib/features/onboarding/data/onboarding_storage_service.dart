import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorageService {
  static const String keyOnboardingDone = 'onboarding_done_v1';
  static const String keyLearningGoal = 'onboarding_learning_goal_v1';

  /// Returns true if onboarding has been completed OR if legacy user data exists.
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(keyOnboardingDone);
      if (done == true) return true;

      // Legacy User Check:
      // If any existing app preferences exist (prayer logs, deen data, quran settings, etc.)
      // then silently mark onboarding as done so existing users updating never see onboarding.
      final allKeys = prefs.getKeys();
      final hasLegacyData = allKeys.any((k) => k != keyOnboardingDone);

      if (hasLegacyData) {
        await prefs.setBool(keyOnboardingDone, true);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Marks onboarding as completed and saves the selected learning goal
  static Future<void> completeOnboarding({String? learningGoal}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyOnboardingDone, true);
      if (learningGoal != null && learningGoal.isNotEmpty) {
        await prefs.setString(keyLearningGoal, learningGoal);
      }
    } catch (_) {}
  }

  /// Gets saved learning goal (if any)
  static Future<String?> getLearningGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(keyLearningGoal);
    } catch (_) {
      return null;
    }
  }
}
