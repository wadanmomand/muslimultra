import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fast_log_entry.dart';
import 'log_fast_dialog.dart';

class FastingLogList extends StatefulWidget {
  final List<FastLogEntry> entries;
  final ValueChanged<FastLogEntry> onSaveEntry;
  final ValueChanged<String> onDeleteEntry;
  final VoidCallback onAddPressed;

  const FastingLogList({
    super.key,
    required this.entries,
    required this.onSaveEntry,
    required this.onDeleteEntry,
    required this.onAddPressed,
  });

  @override
  State<FastingLogList> createState() => _FastingLogListState();
}

class _FastingLogListState extends State<FastingLogList> {
  FastStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredEntries = _selectedFilter == null
        ? widget.entries
        : widget.entries.where((e) => e.status == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title & Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.history_edu_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.fastHistoryTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: widget.onAddPressed,
              icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.gold),
              label: Text(
                l10n.addFastBtn,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(null, l10n.filterAll, isDark),
              const SizedBox(width: 6),
              _buildFilterChip(FastStatus.kept, l10n.statusKept, isDark),
              const SizedBox(width: 6),
              _buildFilterChip(FastStatus.missed, l10n.statusMissed, isDark),
              const SizedBox(width: 6),
              _buildFilterChip(FastStatus.qada, l10n.statusQada, isDark),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // List or Empty Placeholder
        if (filteredEntries.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 36,
                  color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.noFastsLogged,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.noFastsLoggedDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = filteredEntries[index];
              return _buildEntryCard(context, entry, isDark);
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(FastStatus? status, String label, bool isDark) {
    final isSelected = _selectedFilter == status;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = status),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold
              : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppColors.midnightNavy
                : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, FastLogEntry entry, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('EEE, d MMM y').format(entry.gregorianDate);

    Color badgeBg;
    Color badgeText;
    String statusLabel;
    IconData statusIcon;

    switch (entry.status) {
      case FastStatus.kept:
        badgeBg = AppColors.gold.withValues(alpha: 0.16);
        badgeText = AppColors.gold;
        statusLabel = l10n.statusKept;
        statusIcon = Icons.check_circle_rounded;
        break;
      case FastStatus.missed:
        badgeBg = isDark ? Colors.red.withValues(alpha: 0.18) : Colors.red.withValues(alpha: 0.12);
        badgeText = isDark ? const Color(0xFFFCA5A5) : Colors.red.shade700;
        statusLabel = l10n.statusMissed;
        statusIcon = Icons.cancel_rounded;
        break;
      case FastStatus.qada:
        badgeBg = AppColors.info.withValues(alpha: 0.16);
        badgeText = AppColors.info;
        statusLabel = l10n.statusQada;
        statusIcon = Icons.restore_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        LogFastDialog.show(
          context,
          initialEntry: entry,
          onSave: widget.onSaveEntry,
          onDelete: widget.onDeleteEntry,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 18, color: badgeText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.hijriFormatted,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                  ),
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeText.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
