import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/deen/data/milestones.dart';

class MilestoneDialog extends StatelessWidget {
  final Milestone milestone;

  const MilestoneDialog({
    super.key,
    required this.milestone,
  });

  static Future<void> show(BuildContext context, Milestone milestone) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => MilestoneDialog(milestone: milestone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      key: const Key('milestone_dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big Gold Badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                milestone.icon,
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 20),

            // Milestone Title
            Text(
              milestone.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Warm copy
            Text(
              milestone.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Share Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                key: const Key('milestone_share_button'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: milestone.getShareText()));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.milestoneCopiedSnackbar ?? 'Milestone copied to clipboard! 🤲',
                        ),
                        backgroundColor: AppColors.midnightNavyCard,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.share_rounded, color: AppColors.midnightNavyDark, size: 20),
                label: Text(
                  l10n?.shareMilestoneButton ?? 'Share Achievement',
                  style: const TextStyle(
                    color: AppColors.midnightNavyDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                key: const Key('milestone_dismiss_button'),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n?.milestoneDismissButton ?? 'Alhamdulillah',
                  style: TextStyle(
                    color: isDark ? AppColors.goldLight : AppColors.goldDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
