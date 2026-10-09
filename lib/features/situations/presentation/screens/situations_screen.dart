import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/situations/presentation/providers/situations_providers.dart';
import 'package:muslim_ultra/features/situations/presentation/screens/situation_detail_screen.dart';

class SituationsScreen extends ConsumerWidget {
  const SituationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final situationsAsync = ref.watch(allSituationsProvider);

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('situations_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              l10n?.situationsScreenTitle ?? 'Life Situations Guide',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
            ),
            Text(
              l10n?.situationsScreenSubtitle ?? 'Comfort words, Quranic verses & dhikr',
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
      body: situationsAsync.when(
        data: (situations) {
          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: situations.length,
            itemBuilder: (context, index) {
              final item = situations[index];
              final title = item.getTitle(locale.languageCode);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('situation_card_${item.id}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SituationDetailScreen(situation: item),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : AppColors.midnightNavy.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            color: AppColors.gold,
                            size: 20,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  l10n?.situationsAyatCount(item.ayat.length) ??
                                      '${item.ayat.length} ayat',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: AppColors.gold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (_, __) => Center(
          child: Text(
            l10n?.situationsLoadError ?? 'Unable to load Life Situations',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
      ),
    );
  }
}
