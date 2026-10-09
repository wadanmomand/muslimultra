import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/hijri_calculator.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fast_log_entry.dart';

class LogFastDialog extends StatefulWidget {
  final FastLogEntry? initialEntry;
  final DateTime? initialDate;
  final ValueChanged<FastLogEntry> onSave;
  final ValueChanged<String>? onDelete;

  const LogFastDialog({
    super.key,
    this.initialEntry,
    this.initialDate,
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    FastLogEntry? initialEntry,
    DateTime? initialDate,
    required ValueChanged<FastLogEntry> onSave,
    ValueChanged<String>? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => LogFastDialog(
        initialEntry: initialEntry,
        initialDate: initialDate,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<LogFastDialog> createState() => _LogFastDialogState();
}

class _LogFastDialogState extends State<LogFastDialog> {
  late DateTime _selectedDate;
  late FastStatus _status;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialEntry?.gregorianDate ??
        widget.initialDate ??
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _status = widget.initialEntry?.status ?? FastStatus.kept;
    _notesController = TextEditingController(text: widget.initialEntry?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hijri = HijriCalculator.fromGregorian(_selectedDate);

    final y = _selectedDate.year.toString().padLeft(4, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final dateKey = '$y-$m-$d';

    return Dialog(
      backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: AppColors.gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.initialEntry == null ? l10n.logFastTitle : l10n.editFastTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Selector Button
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = DateTime(picked.year, picked.month, picked.day);
                  });
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, d MMMM y').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                            ),
                          ),
                          Text(
                            '${hijri.day} ${hijri.monthNameEn} ${hijri.year} AH',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Selector Tabs
            Text(
              l10n.fastStatusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusOption(
                  FastStatus.kept,
                  l10n.statusKept,
                  Icons.check_circle_rounded,
                  isDark,
                ),
                const SizedBox(width: 6),
                _buildStatusOption(
                  FastStatus.missed,
                  l10n.statusMissed,
                  Icons.cancel_rounded,
                  isDark,
                ),
                const SizedBox(width: 6),
                _buildStatusOption(
                  FastStatus.qada,
                  l10n.statusQada,
                  Icons.restore_rounded,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Optional Notes Field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notesOptional,
                hintText: l10n.notesPlaceholder,
                filled: true,
                fillColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                if (widget.initialEntry != null && widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    tooltip: l10n.deleteEntry,
                    onPressed: () {
                      widget.onDelete!(dateKey);
                      Navigator.of(context).pop();
                    },
                  ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final entry = FastLogEntry(
                        dateKey: dateKey,
                        gregorianDate: _selectedDate,
                        hijriFormatted: '${hijri.day} ${hijri.monthNameEn} ${hijri.year} AH',
                        hijriYear: hijri.year,
                        hijriMonth: hijri.month,
                        hijriDay: hijri.day,
                        status: _status,
                        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                        checklist: widget.initialEntry?.checklist,
                      );
                      widget.onSave(entry);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.midnightNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    FastStatus status,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _status == status;

    Color activeColor;
    switch (status) {
      case FastStatus.kept:
        activeColor = AppColors.gold;
        break;
      case FastStatus.missed:
        activeColor = AppColors.warning;
        break;
      case FastStatus.qada:
        activeColor = AppColors.info;
        break;
    }

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _status = status),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.18)
                : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
