import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/quran/domain/models/tajweed_rule.dart';

class TajweedLegendSheet extends StatelessWidget {
  const TajweedLegendSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TajweedLegendSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      _TajweedCategory(
        title: l10n.tajweedCategoryQalqalah,
        icon: Icons.graphic_eq_rounded,
        rules: [
          TajweedRuleType.qalqalah,
        ],
      ),
      _TajweedCategory(
        title: l10n.tajweedCategoryGhunnah,
        icon: Icons.sync_alt_rounded,
        rules: [
          TajweedRuleType.ghunnah,
          TajweedRuleType.idghaamGhunnah,
          TajweedRuleType.idghaamNoGhunnah,
          TajweedRuleType.idghaamShafawi,
          TajweedRuleType.idghaamMutajanisayn,
          TajweedRuleType.idghaamMutaqaribayn,
        ],
      ),
      _TajweedCategory(
        title: l10n.tajweedCategoryIkhfa,
        icon: Icons.visibility_off_outlined,
        rules: [
          TajweedRuleType.ikhfa,
          TajweedRuleType.ikhfaShafawi,
          TajweedRuleType.iqlab,
        ],
      ),
      _TajweedCategory(
        title: l10n.tajweedCategoryMadd,
        icon: Icons.linear_scale_rounded,
        rules: [
          TajweedRuleType.madd2,
          TajweedRuleType.madd246,
          TajweedRuleType.maddMunfasil,
          TajweedRuleType.maddMuttasil,
          TajweedRuleType.madd6,
        ],
      ),
      _TajweedCategory(
        title: l10n.tajweedCategorySilent,
        icon: Icons.volume_off_rounded,
        rules: [
          TajweedRuleType.hamzatWasl,
          TajweedRuleType.lamShamsiyyah,
          TajweedRuleType.silent,
        ],
      ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withValues(alpha: isDark ? 0.35 : 0.25),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Strip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.palette_outlined,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tajweedLegend,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.tajweedLegendSubtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable List of Categories & Rules
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, catIdx) {
                  final cat = categories[catIdx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 16, color: AppColors.gold),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cat.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Rules List
                        ...cat.rules.map((rule) {
                          final ruleColor = rule.getColor(isDark);
                          final ruleName = l10n.getTajweedRuleName(rule.id);
                          final ruleDesc = l10n.getTajweedRuleDescription(rule.id);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Color Swatch Indicator
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: ruleColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ruleColor.withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Rule Title & Description
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ruleName,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: ruleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ruleDesc,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          height: 1.35,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.sandTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TajweedCategory {
  final String title;
  final IconData icon;
  final List<TajweedRuleType> rules;

  const _TajweedCategory({
    required this.title,
    required this.icon,
    required this.rules,
  });
}
