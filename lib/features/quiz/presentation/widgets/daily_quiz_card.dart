import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:muslim_ultra/features/quiz/presentation/screens/quiz_screen.dart';

class DailyQuizCard extends ConsumerWidget {
  const DailyQuizCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final answerAsync = ref.watch(todayQuizAnswerProvider);
    final isAnswered = answerAsync.value != null;
    final isCorrect = answerAsync.value?.isCorrect ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('daily_quiz_card_inkwell'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isAnswered
                    ? borderColor.withAlpha((0.6 * 255).round())
                    : AppColors.gold.withAlpha((0.5 * 255).round()),
                width: isAnswered ? 1.0 : 1.2,
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withAlpha((0.4 * 255).round()),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n?.dailyQuizCardHeading ?? 'DAILY CHALLENGE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha((0.15 * 255).round()),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '+20 XP',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAnswered
                            ? (isCorrect
                                ? (l10n?.quizAnsweredCorrect ?? 'Answered Correctly ✓')
                                : (l10n?.quizAnsweredCompleted ?? 'Challenge Completed ✓'))
                            : (l10n?.quizTodayReady ?? 'Today\'s Question is Ready!'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isAnswered
                            ? (l10n?.quizReviewHint ?? 'Tap to review explanation and source')
                            : (l10n?.quizTapToPlayHint ?? 'Test your Islamic knowledge'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.gold,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
