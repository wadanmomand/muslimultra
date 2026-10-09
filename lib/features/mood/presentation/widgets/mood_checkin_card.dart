import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/mood/presentation/providers/mood_providers.dart';
import 'package:muslim_ultra/features/mood/presentation/screens/mood_screen.dart';

class MoodCheckinCard extends ConsumerWidget {
  const MoodCheckinCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final todayMoodAsync = ref.watch(todayMoodProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.midnightNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('mood_checkin_card_tap'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MoodScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: todayMoodAsync.when(
                      data: (m) => Text(
                        m?.emoji ?? '🤲',
                        style: const TextStyle(fontSize: 20),
                      ),
                      loading: () => const Text('🤲', style: TextStyle(fontSize: 20)),
                      error: (_, __) => const Text('🤲', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.moodCheckinCardTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      todayMoodAsync.when(
                        data: (m) {
                          if (m != null) {
                            return Text(
                              '${m.localizedMood(locale)} • ${l10n.tapToViewDhikr}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.goldLight : AppColors.goldDark,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return Text(
                            l10n.moodCheckinCardSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.sandTextSecondary,
                            ),
                          );
                        },
                        loading: () => Text(
                          l10n.moodCheckinCardSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.sandTextSecondary,
                          ),
                        ),
                        error: (_, __) => Text(
                          l10n.moodCheckinCardSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.sandTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
