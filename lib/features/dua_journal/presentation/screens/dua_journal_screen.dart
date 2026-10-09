import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/dua_journal/domain/models/journal_entry.dart';
import 'package:muslim_ultra/features/dua_journal/presentation/providers/dua_journal_providers.dart';

class DuaJournalScreen extends ConsumerStatefulWidget {
  const DuaJournalScreen({super.key});

  @override
  ConsumerState<DuaJournalScreen> createState() => _DuaJournalScreenState();
}

class _DuaJournalScreenState extends ConsumerState<DuaJournalScreen> {
  void _showAddDuaDialog(BuildContext context, AppLocalizations? l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Text('🤲', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                l10n?.duaJournalAddTitle ?? 'New Dua',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('input_dua_journal_text'),
                controller: textController,
                maxLines: 5,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: l10n?.duaJournalInputHint ?? 'Write your personal prayer or hope...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.midnightNavyDark : AppColors.sandCardElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n?.duaJournalPrivacyNotice ?? 'Private — stays on your device.',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              key: const ValueKey('btn_save_dua_journal'),
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  await ref.read(duaJournalControllerProvider).addEntry(text);
                  if (context.mounted) {
                    Navigator.of(dialogCtx).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n?.save ?? 'Save',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id, AppLocalizations? l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            l10n?.deleteEntry ?? 'Delete Entry?',
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: Text(
            l10n?.duaJournalDeleteConfirm ?? 'Are you sure you want to remove this dua from your journal?',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
              ),
            ),
            TextButton(
              key: const ValueKey('btn_confirm_delete_dua'),
              onPressed: () async {
                await ref.read(duaJournalControllerProvider).deleteEntry(id);
                if (context.mounted) Navigator.of(dialogCtx).pop();
              },
              child: Text(
                l10n?.deleteEntry ?? 'Delete',
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final bgColor = isDark ? AppColors.midnightNavyDark : AppColors.sandBackground;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final currentFilter = ref.watch(duaJournalFilterProvider);
    final filteredEntries = ref.watch(filteredJournalEntriesProvider);
    final allEntriesAsync = ref.watch(duaJournalEntriesProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('dua_journal_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.duaJournalTitle ?? 'Dua Journal',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('btn_add_dua_appbar'),
            icon: const Icon(Icons.add_rounded, color: AppColors.gold, size: 26),
            tooltip: l10n?.duaJournalAddTitle ?? 'New Dua',
            onPressed: () => _showAddDuaDialog(context, l10n),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('fab_add_dua'),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.midnightNavyDark,
        elevation: 4,
        icon: const Icon(Icons.edit_note_rounded),
        label: Text(
          l10n?.duaJournalAddTitle ?? 'New Dua',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddDuaDialog(context, l10n),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Privacy Notice Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withAlpha((0.25 * 255).round()),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.duaJournalPrivacyNotice ?? 'Private — stays on your device.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Segmented Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip(
                  keyName: 'chip_filter_all',
                  label: l10n?.filterAll ?? 'All',
                  isSelected: currentFilter == DuaJournalFilter.all,
                  onTap: () => ref.read(duaJournalFilterProvider.notifier).state = DuaJournalFilter.all,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  keyName: 'chip_filter_pending',
                  label: l10n?.duaJournalFilterPending ?? 'Pending',
                  isSelected: currentFilter == DuaJournalFilter.pending,
                  onTap: () => ref.read(duaJournalFilterProvider.notifier).state = DuaJournalFilter.pending,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  keyName: 'chip_filter_answered',
                  label: l10n?.duaJournalFilterAnswered ?? 'Answered 🤲',
                  isSelected: currentFilter == DuaJournalFilter.answered,
                  onTap: () => ref.read(duaJournalFilterProvider.notifier).state = DuaJournalFilter.answered,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Entries List
          Expanded(
            child: allEntriesAsync.when(
              data: (_) {
                if (filteredEntries.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha((0.15 * 255).round()),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🤲', style: TextStyle(fontSize: 36)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n?.duaJournalEmptyTitle ?? 'Your Personal Dua Sanctuary',
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n?.duaJournalEmptySubtitle ??
                                'Record your private prayers, hopes, and reflections. Track answered duas over time.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                  itemCount: filteredEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    return _buildJournalCard(
                      context: context,
                      entry: entry,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      l10n: l10n,
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => Center(
                child: Text(
                  l10n?.duaJournalLoadError ?? 'Unable to load journal.',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String keyName,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(keyName),
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gold
                  : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.gold
                    : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.midnightNavyDark : AppColors.gold,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJournalCard({
    required BuildContext context,
    required JournalEntry entry,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required AppLocalizations? l10n,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = dateFormat.format(entry.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isAnswered
              ? AppColors.gold.withAlpha((0.5 * 255).round())
              : borderColor,
          width: entry.isAnswered ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? (0.2 * 255).round() : (0.04 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Date + Answered Badge + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  if (entry.isAnswered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.duaJournalStatusAnswered ?? 'Answered 🤲',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                      size: 18,
                    ),
                    onPressed: () => _confirmDelete(context, entry.id, l10n),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Main Dua Text
          Text(
            entry.text,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 14,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.7, color: AppColors.midnightNavyBorder),
          const SizedBox(height: 8),

          // Action Toggle: Mark as Answered
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                key: ValueKey('btn_toggle_answered_${entry.id}'),
                onPressed: () {
                  ref.read(duaJournalControllerProvider).toggleAnswered(entry.id);
                },
                icon: Icon(
                  entry.isAnswered
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: AppColors.gold,
                  size: 17,
                ),
                label: Text(
                  entry.isAnswered
                      ? (l10n?.duaJournalActionMarkPending ?? 'Mark as pending')
                      : (l10n?.duaJournalActionMarkAnswered ?? 'Mark as answered 🤲'),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
