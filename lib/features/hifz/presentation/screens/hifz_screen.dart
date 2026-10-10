import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_item.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_stats.dart';
import 'package:muslim_ultra/features/hifz/presentation/providers/hifz_providers.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';
import 'package:muslim_ultra/features/quran/domain/models/surah.dart';

class HifzScreen extends ConsumerStatefulWidget {
  const HifzScreen({super.key});

  @override
  ConsumerState<HifzScreen> createState() => _HifzScreenState();
}

class _HifzScreenState extends ConsumerState<HifzScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    ref.invalidate(hifzAllItemsProvider);
    ref.invalidate(hifzSabqProvider);
    ref.invalidate(hifzSabqiProvider);
    ref.invalidate(hifzManzilProvider);
    ref.invalidate(hifzStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(hifzStatsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          l10n.hifzTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.goldLight : AppColors.goldDark,
          ),
        ),
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.goldLight : AppColors.goldDark,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: isDark ? AppColors.goldLight : AppColors.goldDark,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: l10n.hifzTabSabq),
            Tab(text: l10n.hifzTabSabqi),
            Tab(text: l10n.hifzTabManzil),
          ],
        ),
      ),
      body: Column(
        children: [
          // Daily Plan & Stats Banner
          _buildStatsHeader(context, isDark, l10n, statsAsync.value ?? HifzStats.empty()),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSabqTab(context, isDark, l10n),
                _buildSabqiTab(context, isDark, l10n),
                _buildManzilTab(context, isDark, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    HifzStats stats,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Due & Memorized summary
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stats.dueCount} ${l10n.hifzDueTodayCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('·', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${stats.memorizedCount} ${l10n.hifzMemorizedCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Streak Badge
          if (stats.streakDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.streakDays}d',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // TAB 1: SABQ (New Lessons)
  Widget _buildSabqTab(BuildContext context, bool isDark, AppLocalizations l10n) {
    final sabqAsync = ref.watch(hifzSabqProvider);
    final selectedSurahNum = ref.watch(hifzSelectedSurahNumberProvider);
    final fromAyah = ref.watch(hifzFromAyahProvider);
    final toAyah = ref.watch(hifzToAyahProvider);

    final currentSurah = TanzilQuranData.allSurahs.firstWhere(
      (s) => s.number == selectedSurahNum,
      orElse: () => TanzilQuranData.allSurahs.first,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // New Lesson Selector Card
        _buildNewLessonCard(context, isDark, l10n, currentSurah, fromAyah, toAyah),
        const SizedBox(height: 16),

        // Section Title: Active Learning Ayat
        Text(
          l10n.hifzActiveLessonsTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.goldLight : AppColors.goldDark,
          ),
        ),
        const SizedBox(height: 10),

        sabqAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          ),
          error: (_, __) => Center(
            child: Text(
              l10n.hifzEmptySabq,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 40,
                      color: AppColors.gold.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.hifzEmptySabq,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: items
                  .map((item) => _buildAyahHifzCard(context, isDark, l10n, item))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNewLessonCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    SurahModel currentSurah,
    int fromAyah,
    int toAyah,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_task_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.hifzStartLessonTitle,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Surah Dropdown Picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: currentSurah.number,
                dropdownColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                items: TanzilQuranData.allSurahs.map((s) {
                  return DropdownMenuItem<int>(
                    value: s.number,
                    child: Text(
                      '${s.number}. ${s.englishName} (${s.name})',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(hifzSelectedSurahNumberProvider.notifier).state = val;
                    final surah = TanzilQuranData.allSurahs.firstWhere((s) => s.number == val);
                    ref.read(hifzFromAyahProvider.notifier).state = 1;
                    ref.read(hifzToAyahProvider.notifier).state = surah.numberOfAyahs < 7 ? surah.numberOfAyahs : 7;
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // From Ayah & To Ayah Row
          Row(
            children: [
              Expanded(
                child: _buildAyahNumberPicker(
                  label: l10n.hifzFromAyahLabel,
                  value: fromAyah,
                  max: currentSurah.numberOfAyahs,
                  isDark: isDark,
                  onChanged: (val) {
                    ref.read(hifzFromAyahProvider.notifier).state = val;
                    if (toAyah < val) {
                      ref.read(hifzToAyahProvider.notifier).state = val;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAyahNumberPicker(
                  label: l10n.hifzToAyahLabel,
                  value: toAyah,
                  max: currentSurah.numberOfAyahs,
                  isDark: isDark,
                  onChanged: (val) {
                    ref.read(hifzToAyahProvider.notifier).state = val;
                    if (fromAyah > val) {
                      ref.read(hifzFromAyahProvider.notifier).state = val;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Start Lesson Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(hifzRepositoryProvider).startLesson(
                      currentSurah.number,
                      fromAyah,
                      toAyah,
                    );
                _refreshAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.hifzLessonStartedToast(currentSurah.englishName, fromAyah, toAyah),
                      ),
                      backgroundColor: AppColors.midnightNavy,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                l10n.hifzStartLessonButton,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahNumberPicker({
    required String label,
    required int value,
    required int max,
    required bool isDark,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove, size: 16),
                color: AppColors.gold,
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.add, size: 16),
                color: AppColors.gold,
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 2: SABQI (Recent Review)
  Widget _buildSabqiTab(BuildContext context, bool isDark, AppLocalizations l10n) {
    final sabqiAsync = ref.watch(hifzSabqiProvider);

    return sabqiAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
      error: (_, __) => Center(
        child: Text(
          l10n.hifzEmptySabqi,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.history_edu_rounded,
                    size: 48,
                    color: AppColors.gold.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.hifzEmptySabqi,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildAyahHifzCard(context, isDark, l10n, items[index]);
          },
        );
      },
    );
  }

  // TAB 3: MANZIL (Revision)
  Widget _buildManzilTab(BuildContext context, bool isDark, AppLocalizations l10n) {
    final manzilAsync = ref.watch(hifzManzilProvider);

    return manzilAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
      error: (_, __) => Center(
        child: Text(
          l10n.hifzEmptyManzil,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.military_tech_outlined,
                    size: 48,
                    color: AppColors.gold.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.hifzEmptyManzil,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildAyahHifzCard(context, isDark, l10n, items[index]);
          },
        );
      },
    );
  }

  // Generic Ayah Memorization Card
  Widget _buildAyahHifzCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    HifzItem item,
  ) {
    final surah = TanzilQuranData.allSurahs.firstWhere(
      (s) => s.number == item.surahNumber,
      orElse: () => TanzilQuranData.allSurahs.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isDue
              ? AppColors.gold.withValues(alpha: 0.5)
              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Reference Pill + Status Badge + Stability Tag
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${surah.englishName} ${item.surahNumber}:${item.ayahNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.goldLight : AppColors.goldDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Status Cycler Tag
                InkWell(
                  onTap: () async {
                    final nextStatus = (item.status + 1) % 3;
                    await ref.read(hifzRepositoryProvider).setStatus(
                          item.surahNumber,
                          item.ayahNumber,
                          nextStatus,
                        );
                    _refreshAll();
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    child: Text(
                      item.status == 2
                          ? l10n.hifzStatusMemorized
                          : (item.status == 1 ? l10n.hifzStatusLearning : l10n.hifzStatusNew),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: item.status == 2
                            ? AppColors.gold
                            : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Interval Stability Pill
                Text(
                  '${item.stability}d',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Arabic Snippet (Resolved dynamically from bundled Quran)
            if (item.arabicText != null && item.arabicText!.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.arabicText!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontFamily: 'Scheherazade',
                    height: 1.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Spaced Repetition Review Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(hifzRepositoryProvider).review(
                            item.surahNumber,
                            item.ayahNumber,
                            false, // Forgotten -> resets stability to 1
                          );
                      _refreshAll();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      side: BorderSide(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: Text(l10n.hifzButtonForgot, style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(hifzRepositoryProvider).review(
                            item.surahNumber,
                            item.ayahNumber,
                            true, // Remembered -> advances interval
                          );
                      _refreshAll();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.midnightNavyDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      l10n.hifzButtonReviewed,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
