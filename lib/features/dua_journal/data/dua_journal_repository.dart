import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/dua_journal/domain/models/journal_entry.dart';

class DuaJournalRepository {
  static const String storageKey = 'dua_journal_v1';

  /// Loads all journal entries sorted newest first
  Future<List<JournalEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = json.decode(raw);
      final list = decoded
          .map((item) => JournalEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAllEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  /// Adds a new private dua entry
  Future<JournalEntry> addEntry(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Dua journal entry text cannot be empty');
    }

    final entries = await getAllEntries();
    final newEntry = JournalEntry(
      id: 'dua_${DateTime.now().millisecondsSinceEpoch}_${entries.length}',
      text: trimmed,
      createdAt: DateTime.now(),
    );

    entries.insert(0, newEntry);
    await _saveAllEntries(entries);
    return newEntry;
  }

  /// Toggles whether a dua has been answered
  Future<JournalEntry?> toggleAnswered(String id) async {
    final entries = await getAllEntries();
    final index = entries.indexWhere((e) => e.id == id);
    if (index < 0) return null;

    final current = entries[index];
    final updated = current.isAnswered
        ? current.copyWith(clearAnsweredAt: true)
        : current.copyWith(answeredAt: DateTime.now());

    entries[index] = updated;
    await _saveAllEntries(entries);
    return updated;
  }

  /// Gets an entry by ID
  Future<JournalEntry?> getEntryById(String id) async {
    final entries = await getAllEntries();
    try {
      return entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Deletes a dua journal entry
  Future<bool> deleteEntry(String id) async {
    final entries = await getAllEntries();
    final initialLength = entries.length;
    entries.removeWhere((e) => e.id == id);
    if (entries.length != initialLength) {
      await _saveAllEntries(entries);
      return true;
    }
    return false;
  }
}

