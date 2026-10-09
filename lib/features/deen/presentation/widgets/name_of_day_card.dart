import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/asma/presentation/screens/asma_list_screen.dart';
import 'package:muslim_ultra/features/deen/data/name_of_day.dart';

final todayNameOfAllahProvider = FutureProvider<AsmaOfDay>((ref) async {
  return NameOfDayService.getTodayName();
});

class NameOfDayCard extends ConsumerWidget {
  const NameOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final nameAsync = ref.watch(todayNameOfAllahProvider);

    return nameAsync.when(
      data: (name) {
        final meaning = name.localizedMeaning(localeCode);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('name_of_day_card_inkwell'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AsmaListScreen()),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor.withAlpha((0.7 * 255).round()),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? (0.2 * 255).round() : (0.04 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Badge with number
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '#${name.number}',
                        style: const TextStyle(
                          color: AppColors.midnightNavyDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Transliteration & Meaning
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.nameOfDayBadge ?? 'NAME OF ALLAH OF THE DAY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name.transliteration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            meaning,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Arabic Name
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            name.arabic,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
