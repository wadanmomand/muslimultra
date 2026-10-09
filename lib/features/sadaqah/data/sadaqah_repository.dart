import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/sadaqah/domain/models/sadaqah_entry.dart';

class SadaqahRepository {
  static const String storageKey = 'sadaqah_v1';

  static String formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// Loads all saved Sadaqah entries (sorted newest first)
  Future<List<SadaqahEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = json.decode(raw);
      final entries = list
          .map((e) => SadaqahEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<SadaqahEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  /// Logs a new Sadaqah record
  Future<SadaqahEntry> logSadaqah(
    double amount, {
    String? note,
    DateTime? date,
  }) async {
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final entry = SadaqahEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_${(amount * 100).toInt()}',
      amount: amount,
      note: note?.trim(),
      date: dateStr,
      timestamp: DateTime.now(),
    );

    final entries = await getAllEntries();
    entries.insert(0, entry);
    await _saveAll(entries);
    return entry;
  }

  /// Deletes an entry by ID
  Future<void> deleteEntry(String id) async {
    final entries = await getAllEntries();
    entries.removeWhere((e) => e.id == id);
    await _saveAll(entries);
  }

  /// Computes total Sadaqah for the month of [monthDate] (default: current month)
  Future<double> monthlyTotal([DateTime? monthDate]) async {
    final target = monthDate ?? DateTime.now();
    final yearMonth = DateFormat('yyyy-MM').format(target);
    final entries = await getAllEntries();

    return entries
        .where((e) => e.date.startsWith(yearMonth))
        .fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  /// Computes all-time total Sadaqah
  Future<double> totalAllTime() async {
    final entries = await getAllEntries();
    return entries.fold<double>(0.0, (sum, item) => sum + item.amount);
  }
}
