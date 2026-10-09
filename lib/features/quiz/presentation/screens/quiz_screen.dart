import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/quiz/presentation/providers/quiz_providers.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _localSelectedIndex;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    final bgColor = isDark ? AppColors.midnightNavyDark : AppColors.sandBackground;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final questionAsync = ref.watch(todayQuizQuestionProvider);
    final answerAsync = ref.watch(todayQuizAnswerProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('quiz_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.quizTitle ?? 'Daily Quiz Challenge',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              l10n?.quizSubtitle ?? '+20 XP for correct answer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: questionAsync.when(
        data: (question) {
          final answerRecord = answerAsync.value;
          final isAnswered = answerRecord != null || _localSelectedIndex != null;
          final selectedIndex = answerRecord?.selectedIndex ?? _localSelectedIndex;
          final isCorrect = answerRecord?.isCorrect ??
              (selectedIndex != null && selectedIndex == question.correctIndex);

          final questionText = question.localizedQuestion(localeCode);
          final options = question.localizedOptions(localeCode);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.cardGradientDark : null,
                    color: isDark ? null : AppColors.sandCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.gold.withAlpha((0.3 * 255).round()),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha((0.15 * 255).round()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              question.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '+20 XP',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        questionText,
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4 Option Buttons
                ...List.generate(options.length, (idx) {
                  final optionText = options[idx];
                  final isThisSelected = selectedIndex == idx;
                  final isThisCorrect = idx == question.correctIndex;

                  Color optionBg = cardBg;
                  Color optionBorder = borderColor;
                  Color textColor = primaryTextColor;

                  if (isAnswered) {
                    if (isThisCorrect) {
                      optionBg = AppColors.gold.withAlpha((0.2 * 255).round());
                      optionBorder = AppColors.gold;
                      textColor = AppColors.gold;
                    } else if (isThisSelected && !isThisCorrect) {
                      optionBg = const Color(0xFFEF4444).withAlpha((0.15 * 255).round());
                      optionBorder = const Color(0xFFEF4444);
                      textColor = const Color(0xFFF87171);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: ValueKey('quiz_option_$idx'),
                        onTap: (isAnswered || _isSubmitting)
                            ? null
                            : () async {
                                setState(() {
                                  _localSelectedIndex = idx;
                                  _isSubmitting = true;
                                });
                                await ref
                                    .read(quizControllerProvider)
                                    .submitAnswer(question, idx);
                                if (mounted) {
                                  setState(() {
                                    _isSubmitting = false;
                                  });
                                }
                              },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: optionBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: optionBorder,
                              width: isThisSelected || (isAnswered && isThisCorrect) ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isAnswered && isThisCorrect
                                      ? AppColors.gold
                                      : (isAnswered && isThisSelected && !isThisCorrect
                                          ? const Color(0xFFEF4444)
                                          : (isDark
                                              ? AppColors.midnightNavyDark
                                              : AppColors.sandCardElevated)),
                                  border: Border.all(
                                    color: isAnswered && (isThisCorrect || isThisSelected)
                                        ? Colors.transparent
                                        : borderColor,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + idx), // A, B, C, D
                                  style: TextStyle(
                                    color: isAnswered && isThisCorrect
                                        ? AppColors.midnightNavyDark
                                        : (isAnswered && isThisSelected && !isThisCorrect
                                            ? Colors.white
                                            : secondaryTextColor),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14.5,
                                    fontWeight: isThisSelected || (isAnswered && isThisCorrect)
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isAnswered && isThisCorrect)
                                const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20)
                              else if (isAnswered && isThisSelected && !isThisCorrect)
                                const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                if (isAnswered) ...[
                  const SizedBox(height: 14),
                  // Explanation Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.gold.withAlpha((0.08 * 255).round())
                          : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? AppColors.gold.withAlpha((0.4 * 255).round())
                            : borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.celebration_rounded : Icons.menu_book_rounded,
                              color: AppColors.gold,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCorrect
                                  ? (l10n?.quizCorrectHeading ?? 'Correct! +20 XP')
                                  : (l10n?.quizExplanationHeading ?? 'Explanation'),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (question.explainEn.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            question.explainEn,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (question.source.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Source: ${question.source}',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n?.quizLoadError ?? 'Unable to load today\'s quiz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
        ),
      ),
    );
  }
}
