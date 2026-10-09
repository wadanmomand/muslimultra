import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/hijri_calculator.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fast_log_entry.dart';
import 'package:muslim_ultra/features/fasting/domain/models/ramadan_checklist.dart';
import 'package:muslim_ultra/features/fasting/presentation/providers/fasting_providers.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/fasting_today_card.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/fasting_stats_row.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/ramadan_checklist_card.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/fasting_log_list.dart';
import 'package:muslim_ultra/features/fasting/presentation/widgets/log_fast_dialog.dart';

class FastingDashboardScreen extends ConsumerWidget {
  const FastingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final countdown = ref.watch(liveFastingCountdownProvider);
    final isFastingToday = ref.watch(fastingIntentionProvider);
    final stats = ref.watch(fastingStatsProvider);
    final logEntries = ref.watch(fastLogEntriesProvider);
    final isRamadan = ref.watch(isRamadanActiveProvider);

    final todayKey = ref.watch(todayDateKeyProvider);
    final todayEntry = logEntries.where((e) => e.dateKey == todayKey).firstOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          l10n.fastingTrackerTitle,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.gold),
            tooltip: l10n.addFastBtn,
            onPressed: () {
              LogFastDialog.show(
                context,
                onSave: (entry) => ref.read(fastLogEntriesProvider.notifier).saveEntry(entry),
                onDelete: (key) => ref.read(fastLogEntriesProvider.notifier).deleteEntry(key),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Live Fasting Today Card
            FastingTodayCard(
              countdown: countdown,
              isFastingToday: isFastingToday,
              onIntentionChanged: (val) {
                ref.read(fastingIntentionProvider.notifier).setIntention(val);
              },
              onLogFastPressed: () {
                final now = DateTime.now();
                final todayClean = DateTime(now.year, now.month, now.day);
                final hijri = HijriCalculator.fromGregorian(todayClean);

                LogFastDialog.show(
                  context,
                  initialEntry: todayEntry ??
                      FastLogEntry(
                        dateKey: todayKey,
                        gregorianDate: todayClean,
                        hijriFormatted: '${hijri.day} ${hijri.monthNameEn} ${hijri.year} AH',
                        hijriYear: hijri.year,
                        hijriMonth: hijri.month,
                        hijriDay: hijri.day,
                        status: isFastingToday ? FastStatus.kept : FastStatus.kept,
                      ),
                  onSave: (entry) => ref.read(fastLogEntriesProvider.notifier).saveEntry(entry),
                  onDelete: (key) => ref.read(fastLogEntriesProvider.notifier).deleteEntry(key),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. Fasting Stats Row
            FastingStatsRow(stats: stats),
            const SizedBox(height: 16),

            // 3. Ramadan Daily Checklist (active in Ramadan or when recorded)
            if (isRamadan || todayEntry?.checklist != null) ...[
              RamadanChecklistCard(
                checklist: todayEntry?.checklist ?? const RamadanChecklist(),
                onChecklistChanged: (updatedChecklist) {
                  final now = DateTime.now();
                  final todayClean = DateTime(now.year, now.month, now.day);
                  final hijri = HijriCalculator.fromGregorian(todayClean);

                  final updatedEntry = (todayEntry ??
                          FastLogEntry(
                            dateKey: todayKey,
                            gregorianDate: todayClean,
                            hijriFormatted: '${hijri.day} ${hijri.monthNameEn} ${hijri.year} AH',
                            hijriYear: hijri.year,
                            hijriMonth: hijri.month,
                            hijriDay: hijri.day,
                            status: FastStatus.kept,
                          ))
                      .copyWith(checklist: updatedChecklist);

                  ref.read(fastLogEntriesProvider.notifier).saveEntry(updatedEntry);
                },
              ),
              const SizedBox(height: 16),
            ],

            // 4. Fasting History Log
            FastingLogList(
              entries: logEntries,
              onSaveEntry: (entry) => ref.read(fastLogEntriesProvider.notifier).saveEntry(entry),
              onDeleteEntry: (key) => ref.read(fastLogEntriesProvider.notifier).deleteEntry(key),
              onAddPressed: () {
                LogFastDialog.show(
                  context,
                  onSave: (entry) => ref.read(fastLogEntriesProvider.notifier).saveEntry(entry),
                  onDelete: (key) => ref.read(fastLogEntriesProvider.notifier).deleteEntry(key),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
