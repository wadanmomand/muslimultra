import 'package:shared_preferences/shared_preferences.dart';

/// Local on-device persistence for Tasbih counts and targets
class TasbihStorageService {
  static const String _keySelectedDhikr = 'tasbih_selected_dhikr_id';
  static const String _keyCountPrefix = 'tasbih_current_count_';
  static const String _keyTargetPrefix = 'tasbih_custom_target_';
  static const String _keyDailyPrefix = 'tasbih_daily_count_';
  static const String _keyLastActiveDate = 'tasbih_last_active_date';

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Load selected Dhikr ID
  static Future<String> loadSelectedDhikrId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedDhikr) ?? 'subhanallah';
  }

  /// Save selected Dhikr ID
  static Future<void> saveSelectedDhikrId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedDhikr, id);
  }

  /// Load current session count for a dhikr
  static Future<int> loadCurrentCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyCountPrefix$dhikrId') ?? 0;
  }

  /// Save current session count for a dhikr
  static Future<void> saveCurrentCount(String dhikrId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyCountPrefix$dhikrId', count);
  }

  /// Load custom target if set, otherwise returns defaultTarget
  static Future<int> loadTarget(String dhikrId, int defaultTarget) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyTargetPrefix$dhikrId') ?? defaultTarget;
  }

  /// Save custom target for a dhikr
  static Future<void> saveTarget(String dhikrId, int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyTargetPrefix$dhikrId', target);
  }

  /// Get today's total count for a specific dhikr
  static Future<int> getTodayCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    return prefs.getInt('$_keyDailyPrefix${today}_$dhikrId') ?? 0;
  }

  /// Increment today's total count by 1 for a dhikr
  static Future<int> incrementTodayCount(String dhikrId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final key = '$_keyDailyPrefix${today}_$dhikrId';
    final current = prefs.getInt(key) ?? 0;
    final updated = current + 1;
    await prefs.setInt(key, updated);
    await prefs.setString(_keyLastActiveDate, today);
    return updated;
  }

  /// Get overall cumulative count for today across all adhkar
  static Future<int> getOverallTodayTotal(List<String> dhikrIds) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    int total = 0;
    for (final id in dhikrIds) {
      total += prefs.getInt('$_keyDailyPrefix${today}_$id') ?? 0;
    }
    return total;
  }
}
