import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';

class HomeQuickActions extends ConsumerWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      {
        'title': l10n.navQuran,
        'icon': Icons.menu_book_rounded,
        'color': AppColors.gold,
        'onTap': () {
          ref.read(bottomNavIndexProvider.notifier).state = 2;
        },
      },
      {
        'title': l10n.navDua,
        'icon': Icons.favorite_border_rounded,
        'color': AppColors.goldLight,
        'onTap': () {
          ref.read(bottomNavIndexProvider.notifier).state = 3;
        },
      },
      {
        'title': l10n.qibla,
        'icon': Icons.explore_rounded,
        'color': AppColors.goldBright,
        'onTap': () {
          ref.read(prayerTabModeProvider.notifier).state = PrayerTabMode.qibla;
          ref.read(bottomNavIndexProvider.notifier).state = 1;
        },
      },
      {
        'title': l10n.navAi,
        'icon': Icons.auto_awesome,
        'color': AppColors.gold,
        'onTap': () {
          ref.read(bottomNavIndexProvider.notifier).state = 4;
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((act) {
            final color = act['color'] as Color;
            final onTap = act['onTap'] as VoidCallback;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            act['icon'] as IconData,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          act['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
