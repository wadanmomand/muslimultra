import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hajj/domain/models/hajj_step.dart';
import 'package:muslim_ultra/features/hajj/presentation/providers/hajj_providers.dart';
import 'package:muslim_ultra/features/hajj/presentation/screens/hajj_step_detail_screen.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/hijri_calculator.dart';

class HajjGuideScreen extends ConsumerWidget {
  const HajjGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    final stepsAsync = ref.watch(hajjStepsProvider);
    final selectedPhaseIndex = ref.watch(selectedPhaseIndexProvider);
    final completedStepsAsync = ref.watch(completedHajjStepsProvider);
    final completedSet = completedStepsAsync.valueOrNull ?? <int>{};

    // Dhul-Hijjah check (Hijri month 12)
    final currentHijri = HijriCalculator.fromGregorian(DateTime.now());
    final isDhulHijjah = currentHijri.month == 12;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('hajj_guide_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.hajjGuideTitle ?? 'Hajj & Umrah Guide',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: stepsAsync.when(
        data: (allSteps) {
          // Group steps by phase
          final phases = <String>['Umrah', 'Hajj', 'Checklist'];
          final activePhase = phases[selectedPhaseIndex.clamp(0, phases.length - 1)];
          final phaseSteps = allSteps
              .where((s) => s.phaseEn.toLowerCase() == activePhase.toLowerCase())
              .toList();

          final completedInPhase =
              phaseSteps.where((s) => completedSet.contains(s.step)).length;
          final totalInPhase = phaseSteps.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dhul-Hijjah Near Banner (Step 3)
              if (isDhulHijjah)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n?.dhulHijjahBannerText ?? 'Hajj days are near — review the rites.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.goldBright : AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Phase Segmented Selector Tabs (Umrah | Hajj | Checklist)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    ),
                  ),
                  child: Row(
                    children: List.generate(phases.length, (idx) {
                      final phaseName = phases[idx];
                      final isSelected = selectedPhaseIndex == idx;
                      String localizedName = phaseName;
                      if (phaseName == 'Umrah') localizedName = l10n?.hajjPhaseUmrah ?? 'Umrah';
                      if (phaseName == 'Hajj') localizedName = l10n?.hajjPhaseHajj ?? 'Hajj';
                      if (phaseName == 'Checklist') localizedName = l10n?.hajjPhaseChecklist ?? 'Checklist';

                      return Expanded(
                        child: InkWell(
                          key: ValueKey('hajj_tab_$idx'),
                          onTap: () {
                            ref.read(selectedPhaseIndexProvider.notifier).state = idx;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              localizedName,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.midnightNavyDark
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.sandTextSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Progress Bar & Counter Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedInPhase / $totalInPhase ${l10n?.hajjStepsCompletedCount ?? "steps completed"}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.goldLight : AppColors.goldDark,
                      ),
                    ),
                    if (totalInPhase > 0)
                      Text(
                        '${((completedInPhase / totalInPhase) * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.goldLight : AppColors.goldDark,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Step Timeline List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: phaseSteps.length + 1, // +1 for scholar disclaimer footer
                  itemBuilder: (context, index) {
                    if (index == phaseSteps.length) {
                      return _buildScholarDisclaimer(context, l10n, isDark);
                    }

                    final step = phaseSteps[index];
                    final isStepDone = completedSet.contains(step.step);
                    final isLast = index == phaseSteps.length - 1;

                    return _buildTimelineStepCard(
                      context,
                      step: step,
                      phaseSteps: phaseSteps,
                      isCompleted: isStepDone,
                      isLast: isLast,
                      locale: locale,
                      isDark: isDark,
                      l10n: l10n,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${l10n?.hajjLoadError ?? "Unable to load guide"}: $err',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStepCard(
    BuildContext context, {
    required HajjStep step,
    required List<HajjStep> phaseSteps,
    required bool isCompleted,
    required bool isLast,
    required String locale,
    required bool isDark,
    required AppLocalizations? l10n,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Step Badge + Connecting Line
          SizedBox(
            width: 38,
            child: Column(
              children: [
                // Step Badge (Gold Circle)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isCompleted ? null : AppColors.goldGradient,
                    color: isCompleted ? AppColors.gold : null,
                    border: Border.all(
                      color: AppColors.goldBright,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: AppColors.midnightNavyDark, size: 18)
                      : Text(
                          '${step.step}',
                          style: const TextStyle(
                            color: AppColors.midnightNavyDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                ),
                // Connecting vertical line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? AppColors.gold.withValues(alpha: 0.6)
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Right: Step Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('hajj_step_card_${step.step}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HajjStepDetailScreen(
                          step: step,
                          allStepsInPhase: phaseSteps,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.gold.withValues(alpha: 0.4)
                            : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : AppColors.midnightNavy.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.localizedTitle(locale),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.sandTextPrimary,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.gold,
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step.localizedDesc(locale),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.sandTextSecondary,
                          ),
                        ),
                        if (step.hasDua) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🤲', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  l10n?.hajjDuaBadge ?? 'Dua included',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.goldLight : AppColors.goldDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarDisclaimer(BuildContext context, AppLocalizations? l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Center(
        child: Text(
          l10n?.hajjScholarDisclaimer ?? 'Always follow your group\'s scholar for specific details.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontStyle: FontStyle.italic,
            color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
          ),
        ),
      ),
    );
  }
}
