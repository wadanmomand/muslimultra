import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/fasting/domain/models/ramadan_checklist.dart';

class RamadanChecklistCard extends StatelessWidget {
  final RamadanChecklist checklist;
  final ValueChanged<RamadanChecklist> onChecklistChanged;

  const RamadanChecklistCard({
    super.key,
    required this.checklist,
    required this.onChecklistChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      {
        'title': l10n.checklistSuhoor,
        'subtitle': l10n.checklistSuhoorSub,
        'value': checklist.suhoor,
        'onChanged': (bool val) => onChecklistChanged(checklist.copyWith(suhoor: val)),
      },
      {
        'title': l10n.checklistFastKept,
        'subtitle': l10n.checklistFastKeptSub,
        'value': checklist.fastKept,
        'onChanged': (bool val) => onChecklistChanged(checklist.copyWith(fastKept: val)),
      },
      {
        'title': l10n.checklistTaraweeh,
        'subtitle': l10n.checklistTaraweehSub,
        'value': checklist.taraweeh,
        'onChanged': (bool val) => onChecklistChanged(checklist.copyWith(taraweeh: val)),
      },
      {
        'title': l10n.checklistQuran,
        'subtitle': l10n.checklistQuranSub,
        'value': checklist.quran,
        'onChanged': (bool val) => onChecklistChanged(checklist.copyWith(quran: val)),
      },
      {
        'title': l10n.checklistDua,
        'subtitle': l10n.checklistDuaSub,
        'value': checklist.dua,
        'onChanged': (bool val) => onChecklistChanged(checklist.copyWith(dua: val)),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.midnightNavy.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.checklist_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.ramadanChecklistTitle,
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${checklist.completedCount}/5',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: checklist.progressFraction,
              minHeight: 5,
              backgroundColor: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final title = item['title'] as String;
            final subtitle = item['subtitle'] as String;
            final val = item['value'] as bool;
            final onChanged = item['onChanged'] as ValueChanged<bool>;

            return InkWell(
              onTap: () => onChanged(!val),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: val,
                      onChanged: (newVal) => onChanged(newVal ?? false),
                      activeColor: AppColors.gold,
                      checkColor: AppColors.midnightNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                              decoration: val ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
