import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/theme/app_typography.dart';
import 'package:muslim_ultra/features/tasbih/presentation/providers/tasbih_providers.dart';
import 'package:muslim_ultra/features/tasbih/presentation/widgets/tasbih_progress_ring.dart';
import 'package:muslim_ultra/features/tasbih/presentation/widgets/custom_target_dialog.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  void _showResetConfirmDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.restart_alt_rounded, color: AppColors.gold, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.resetConfirmTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.resetConfirmDesc,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.15),
              foregroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.error, width: 1),
              ),
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(tasbihProvider);
    final notifier = ref.read(tasbihProvider.notifier);

    final selectedPreset = state.selectedPreset;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tasbih,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          // Today's total count badge (Task 4)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history_rounded, size: 13, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  '${l10n.todayTotal}: ${state.todayTotal}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldLight : AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Preset Selector Horizontal Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: state.presets.map((preset) {
                    final isSelected = preset.id == selectedPreset.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          preset.transliteration,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppColors.midnightNavyDark
                                : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.gold,
                        backgroundColor: isDark
                            ? AppColors.midnightNavyCard
                            : AppColors.sandCardElevated,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.gold
                              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                        ),
                        onSelected: (_) => notifier.selectPreset(preset),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Active Dhikr Card (Arabic, Transliteration, Translation)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : AppColors.midnightNavy.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Arabic Text
                    Text(
                      selectedPreset.arabic,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.quranAyahText(
                        fontSize: 24,
                        color: isDark ? AppColors.goldLight : AppColors.midnightNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Transliteration
                    Text(
                      selectedPreset.transliteration,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Translation
                    Text(
                      l10n.translate(selectedPreset.translationKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Dominant Tap Target & Progress Ring (Task 1 & Task 3)
              TasbihProgressRing(
                progress: state.progress,
                count: state.currentCount,
                target: state.target,
                isCompleted: state.isCompleted,
                onTap: () => notifier.increment(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // 4. Completion celebration banner if target reached
              if (state.isCompleted)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.targetReached,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),

              // 5. Action Controls (Set Custom Target & Reset Counter)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Set Target button
                  Flexible(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: Text(
                        l10n.customTarget,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppColors.goldLight : AppColors.goldDark,
                        side: BorderSide(
                          color: isDark ? AppColors.gold.withValues(alpha: 0.4) : AppColors.sandBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onPressed: () {
                        CustomTargetDialog.show(
                          context,
                          currentTarget: state.target,
                          onTargetSet: (val) => notifier.setCustomTarget(val),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Reset button (Task 1)
                  IconButton.filledTonal(
                    icon: const Icon(Icons.restart_alt_rounded, size: 20),
                    tooltip: l10n.reset,
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.midnightNavyCardElevated
                          : AppColors.sandCardElevated,
                      foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (state.currentCount > 0) {
                        _showResetConfirmDialog(
                          context,
                          l10n,
                          isDark,
                          () => notifier.reset(),
                        );
                      } else {
                        notifier.reset();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
