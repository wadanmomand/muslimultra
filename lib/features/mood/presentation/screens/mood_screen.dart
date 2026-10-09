import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/mood/domain/models/mood_item.dart';
import 'package:muslim_ultra/features/mood/presentation/providers/mood_providers.dart';
import 'package:muslim_ultra/features/tasbih/presentation/screens/tasbih_screen.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final moodsAsync = ref.watch(moodListProvider);
    final activeMoodAsync = ref.watch(activeMoodItemProvider);
    final selectedKey = ref.watch(selectedMoodKeyProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          l10n.moodScreenTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: moodsAsync.when(
        data: (moods) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header prompt
                Text(
                  l10n.moodHeaderPrompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.moodHeaderSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // 8 Mood Chips in a responsive Wrap
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: moods.map((m) {
                    final isSelected = (selectedKey != null &&
                            selectedKey.toLowerCase() == m.moodEn.toLowerCase()) ||
                        (selectedKey == null &&
                            activeMoodAsync.valueOrNull?.moodEn.toLowerCase() ==
                                m.moodEn.toLowerCase());

                    final label = m.localizedMood(locale);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(moodControllerProvider).selectAndLogMood(m.moodEn);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold.withValues(alpha: 0.18)
                                : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.gold
                                  : (isDark
                                      ? AppColors.midnightNavyBorder
                                      : AppColors.sandBorder),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? AppColors.goldBright : AppColors.goldDark)
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.sandTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Active Dhikr Card
                activeMoodAsync.when(
                  data: (activeMood) {
                    if (activeMood == null) {
                      return const SizedBox.shrink();
                    }

                    return _buildDhikrCard(
                      context,
                      ref,
                      mood: activeMood,
                      locale: locale,
                      isDark: isDark,
                      l10n: l10n,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading moods: $err',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrCard(
    BuildContext context,
    WidgetRef ref, {
    required MoodItem mood,
    required String locale,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final translation = mood.localizedDua(locale);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : AppColors.midnightNavy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of card: Emoji + Mood title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.localizedMood(locale),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                      ),
                    ),
                    Text(
                      l10n.recommendedDhikrLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Arabic Dua (Large)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.midnightNavyDark.withValues(alpha: 0.6)
                  : AppColors.sandBackground.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.midnightNavyBorder.withValues(alpha: 0.6)
                    : AppColors.sandBorder.withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              mood.duaAr,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.8,
                color: isDark ? AppColors.goldBright : AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Translation (EN/UR)
          if (translation.isNotEmpty && translation != mood.duaAr) ...[
            Text(
              translation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Source
          if (mood.source.isNotEmpty) ...[
            Text(
              mood.source,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
              ),
            ),
            const SizedBox(height: 22),
          ],

          // Start Dhikr Button
          ElevatedButton.icon(
            key: const Key('start_dhikr_button'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TasbihScreen()),
              );
            },
            icon: const Icon(Icons.fingerprint_rounded, color: AppColors.midnightNavyDark),
            label: Text(
              l10n.startDhikrButton,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.midnightNavyDark,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}
