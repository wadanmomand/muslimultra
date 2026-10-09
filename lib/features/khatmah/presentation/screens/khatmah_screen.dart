import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/khatmah/presentation/providers/khatmah_providers.dart';

class KhatmahScreen extends ConsumerWidget {
  const KhatmahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final bgColor = isDark ? AppColors.midnightNavyDark : AppColors.sandBackground;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final stateAsync = ref.watch(khatmahStateProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('khatmah_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.khatmahTitle ?? 'Quran Khatmah Tracker',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: stateAsync.when(
        data: (state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.cardGradientDark : null,
                    color: isDark ? null : AppColors.sandCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withAlpha((0.35 * 255).round()),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? (0.25 * 255).round() : (0.04 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.khatmahCurrentGoal ?? 'Current Khatmah',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.completedCount} / 30 Paras',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha((0.15 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.gold.withAlpha((0.4 * 255).round()),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.gold, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  '${state.completedKhatmahs} ${l10n?.khatmahCompletedPlural ?? "Completed"}',
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: state.progressFraction,
                          backgroundColor: isDark
                              ? AppColors.midnightNavyDark
                              : AppColors.sandCardElevated,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${state.progressPercentage}% Completed',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${30 - state.completedCount} Paras remaining',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  l10n?.khatmahGridTitle ?? 'Tap a Para to Mark as Completed',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // 30-Para Grid (5 columns x 6 rows)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final paraNumber = index + 1;
                    final isCompleted = state.isParaCompleted(paraNumber);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: ValueKey('para_tile_$paraNumber'),
                        onTap: () async {
                          final newState = await ref
                              .read(khatmahControllerProvider)
                              .togglePara(paraNumber);

                          if (newState.completedKhatmahs > state.completedKhatmahs && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n?.khatmahCelebrationMessage ??
                                      'Mubarak! You completed a full Quran Khatmah! 🎉',
                                ),
                                backgroundColor: AppColors.gold,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            gradient: isCompleted ? AppColors.goldGradient : null,
                            color: isCompleted
                                ? null
                                : (isDark ? cardBg : AppColors.sandCardElevated),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.gold
                                  : borderColor.withAlpha((0.8 * 255).round()),
                              width: isCompleted ? 1.5 : 1.0,
                            ),
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: AppColors.gold.withAlpha((0.3 * 255).round()),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$paraNumber',
                                style: TextStyle(
                                  color: isCompleted
                                      ? AppColors.midnightNavyDark
                                      : primaryTextColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n?.juzLabel ?? 'Juz',
                                style: TextStyle(
                                  color: isCompleted
                                      ? AppColors.midnightNavyDark.withAlpha((0.8 * 255).round())
                                      : secondaryTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (_, __) => Center(
          child: Text(
            l10n?.khatmahLoadError ?? 'Unable to load Khatmah tracker.',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
      ),
    );
  }
}
