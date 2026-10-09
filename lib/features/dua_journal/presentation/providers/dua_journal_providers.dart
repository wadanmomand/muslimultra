import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/dua_journal/data/dua_journal_repository.dart';
import 'package:muslim_ultra/features/dua_journal/domain/models/journal_entry.dart';

enum DuaJournalFilter { all, pending, answered }

final duaJournalRepositoryProvider = Provider<DuaJournalRepository>((ref) {
  return DuaJournalRepository();
});

final duaJournalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final repo = ref.watch(duaJournalRepositoryProvider);
  return repo.getAllEntries();
});

final duaJournalFilterProvider = StateProvider<DuaJournalFilter>((ref) {
  return DuaJournalFilter.all;
});

final filteredJournalEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entriesAsync = ref.watch(duaJournalEntriesProvider);
  final filter = ref.watch(duaJournalFilterProvider);
  final entries = entriesAsync.value ?? [];

  switch (filter) {
    case DuaJournalFilter.pending:
      return entries.where((e) => !e.isAnswered).toList();
    case DuaJournalFilter.answered:
      return entries.where((e) => e.isAnswered).toList();
    case DuaJournalFilter.all:
      return entries;
  }

});

class DuaJournalController {
  final Ref ref;
  final DuaJournalRepository repo;

  DuaJournalController(this.ref, this.repo);

  Future<void> addEntry(String text) async {
    await repo.addEntry(text);
    ref.invalidate(duaJournalEntriesProvider);
  }

  Future<void> toggleAnswered(String id) async {
    await repo.toggleAnswered(id);
    ref.invalidate(duaJournalEntriesProvider);
  }

  Future<void> deleteEntry(String id) async {
    await repo.deleteEntry(id);
    ref.invalidate(duaJournalEntriesProvider);
  }
}

final duaJournalControllerProvider = Provider<DuaJournalController>((ref) {
  final repo = ref.watch(duaJournalRepositoryProvider);
  return DuaJournalController(ref, repo);
});
