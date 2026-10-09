import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hajj/domain/models/hajj_step.dart';
import 'package:muslim_ultra/features/hajj/presentation/providers/hajj_providers.dart';

class HajjStepDetailScreen extends ConsumerWidget {
  final HajjStep step;
  final List<HajjStep> allStepsInPhase;

  const HajjStepDetailScreen({
    super.key,
    required this.step,
    this.allStepsInPhase = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final completedStepsAsync = ref.watch(completedHajjStepsProvider);
    final isCompleted = completedStepsAsync.valueOrNull?.contains(step.step) ?? false;

    final title = step.localizedTitle(locale);
    final desc = step.localizedDesc(locale);
    final phase = step.localizedPhase(locale);
    final duaTranslation = step.localizedDuaTranslation(locale);

    final currentIndex = allStepsInPhase.indexOf(step);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex >= 0 && currentIndex < allStepsInPhase.length - 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('hajj_detail_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$phase • ${l10n?.hajjStepNumberPrefix(step.step) ?? "Step ${step.step}"}',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('btn_toggle_step_completed_appbar'),
            tooltip: isCompleted
                ? (l10n?.hajjMarkPendingButton ?? 'Mark as pending')
                : (l10n?.hajjMarkDoneButton ?? 'Mark as done'),
            icon: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
              color: isCompleted ? AppColors.gold : AppColors.darkTextMuted,
              size: 24,
            ),
            onPressed: () async {
              final isDone = await ref.read(hajjControllerProvider).toggleStep(step.step);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isDone
                          ? (l10n?.hajjStepCompletedToast ?? 'Step marked as completed ✓')
                          : (l10n?.hajjStepPendingToast ?? 'Step marked as pending'),
                    ),
                    backgroundColor: AppColors.midnightNavyCard,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step Number Badge + Title
            Container(
              padding: const EdgeInsets.all(18),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${step.step}',
                          style: const TextStyle(
                            color: AppColors.midnightNavyDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dua Card (if present)
            if (step.hasDua) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.hajjDuaSectionTitle ?? 'Recommended Dua / Dhikr',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          tooltip: l10n?.copyHadith ?? 'Copy Dua',
                          icon: const Icon(Icons.copy_rounded, color: AppColors.gold, size: 18),
                          onPressed: () async {
                            final copyText = '${step.duaAr}\n\n${duaTranslation ?? ""}\n(${step.source ?? ""})';
                            await Clipboard.setData(ClipboardData(text: copyText.trim()));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n?.hadithCopiedToast ?? 'Dua copied to clipboard'),
                                  backgroundColor: AppColors.midnightNavyCard,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Large Arabic Dua
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.midnightNavyDark.withValues(alpha: 0.6)
                            : AppColors.sandBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.midnightNavyBorder.withValues(alpha: 0.6)
                              : AppColors.sandBorder.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        step.duaAr!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.8,
                          color: isDark ? AppColors.goldBright : AppColors.goldDark,
                        ),
                      ),
                    ),

                    if (duaTranslation != null && duaTranslation.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        duaTranslation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                        ),
                      ),
                    ],

                    if (step.source != null && step.source!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${l10n?.sourceLabel ?? "Source"}: ${step.source!}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // "Mark as Done" Action Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                key: const ValueKey('btn_mark_step_done'),
                onPressed: () async {
                  final isDone = await ref.read(hajjControllerProvider).toggleStep(step.step);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isDone
                              ? (l10n?.hajjStepCompletedToast ?? 'Step marked as completed ✓')
                              : (l10n?.hajjStepPendingToast ?? 'Step marked as pending'),
                        ),
                        backgroundColor: AppColors.midnightNavyCard,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                icon: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  color: AppColors.midnightNavyDark,
                ),
                label: Text(
                  isCompleted
                      ? (l10n?.hajjCompletedButtonLabel ?? 'Completed ✓ (Tap to Undo)')
                      : (l10n?.hajjMarkDoneButton ?? 'Mark as Done ✓'),
                  style: const TextStyle(
                    color: AppColors.midnightNavyDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? AppColors.goldLight : AppColors.gold,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Prev / Next Navigation Row
            if (hasPrevious || hasNext) ...[
              Row(
                children: [
                  if (hasPrevious)
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('btn_prev_step'),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => HajjStepDetailScreen(
                                step: allStepsInPhase[currentIndex - 1],
                                allStepsInPhase: allStepsInPhase,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.gold),
                        label: Text(
                          l10n?.previousName ?? 'Previous',
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 12),
                  if (hasNext)
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('btn_next_step'),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => HajjStepDetailScreen(
                                step: allStepsInPhase[currentIndex + 1],
                                allStepsInPhase: allStepsInPhase,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n?.nextName ?? 'Next',
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.gold),
                          ],
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
