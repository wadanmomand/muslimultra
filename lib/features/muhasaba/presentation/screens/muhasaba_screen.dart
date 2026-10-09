import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/muhasaba/data/muhasaba_reminder_service.dart';
import 'package:muslim_ultra/features/muhasaba/data/muhasaba_repository.dart';
import 'package:muslim_ultra/features/muhasaba/domain/models/muhasaba_questions.dart';
import 'package:muslim_ultra/features/muhasaba/presentation/providers/muhasaba_providers.dart';
import 'package:muslim_ultra/features/muhasaba/presentation/widgets/muhasaba_summary_card.dart';

class MuhasabaScreen extends ConsumerStatefulWidget {
  const MuhasabaScreen({super.key});

  @override
  ConsumerState<MuhasabaScreen> createState() => _MuhasabaScreenState();
}

class _MuhasabaScreenState extends ConsumerState<MuhasabaScreen> {
  final String _today = MuhasabaRepository.formatDate(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);

    final selectedDate = ref.watch(muhasabaSelectedDateProvider);
    final formState = ref.watch(muhasabaFormNotifierProvider(selectedDate));
    final formNotifier = ref.read(muhasabaFormNotifierProvider(selectedDate).notifier);

    final isToday = selectedDate == _today;
    final fourteenDaysAsync = ref.watch(muhasaba14DaysProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              l10n?.muhasabaTitle ?? 'Muhasaba',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
            ),
            Text(
              l10n?.muhasabaSubtitle ?? 'Nightly Self-Accountability',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('btn_muhasaba_reminder_toggle'),
            icon: const Icon(Icons.notifications_active_outlined, color: AppColors.gold, size: 22),
            tooltip: l10n?.muhasabaReminderSetting ?? 'Nightly Reminder',
            onPressed: () => _showReminderDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekly mini-view summary card
                    const MuhasabaSummaryCard(),
                    const SizedBox(height: 16),

                    // Privacy notice label
                    Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.gold),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n?.muhasabaPrivacyNote ?? 'Private — stays on your device.',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 14-Day Date Pager
                    _buildDatePager(context, fourteenDaysAsync, selectedDate),
                    const SizedBox(height: 16),

                    // Read-only notification badge if viewing past dates
                    if (!isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.history_rounded, size: 16, color: AppColors.gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n?.muhasabaReadOnlyBadge ?? 'Viewing past reflection (Read-only)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Progress bar & label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.muhasabaProgress(formState.answeredCount, 6) ??
                              '${formState.answeredCount} of 6 answered',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                        if (formState.isCompleted)
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.gold),
                              const SizedBox(width: 4),
                              Text(
                                l10n?.muhasabaAllCompleted ?? 'All 6 completed',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: formState.answeredCount / 6.0,
                        backgroundColor: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Six Questions List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final q = MuhasabaQuestions.list[index];
                    final currentAnswer = formState.answers[q.id];
                    final qText = q.getText(locale.languageCode);

                    return _buildQuestionCard(
                      context,
                      index: index + 1,
                      question: q,
                      questionText: qText,
                      currentAnswer: currentAnswer,
                      isReadOnly: !isToday,
                      onSelect: (val) {
                        if (isToday) {
                          formNotifier.setAnswer(q.id, val);
                        }
                      },
                    );
                  },
                  childCount: MuhasabaQuestions.list.length,
                ),
              ),
            ),

            // Save Button (Only on Today's form)
            if (isToday)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      key: const ValueKey('btn_save_muhasaba'),
                      onPressed: formState.isSaving
                          ? null
                          : () async {
                              final success = await formNotifier.save();
                              if (context.mounted && success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline_rounded,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            l10n?.muhasabaSavedToast ?? 'Reflection saved securely',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.midnightNavy,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: AppColors.gold, width: 0.8),
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.midnightNavyDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: formState.isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.midnightNavyDark,
                              ),
                            )
                          : Text(
                              l10n?.muhasabaSave ?? 'Save Reflection',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePager(
    BuildContext context,
    AsyncValue<List<MapEntry<DateTime, MuhasabaEntry?>>> fourteenDaysAsync,
    String selectedDate,
  ) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return fourteenDaysAsync.when(
      data: (daysList) {
        return SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: daysList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = daysList[index];
              final date = entry.key;
              final dateStr = MuhasabaRepository.formatDate(date);
              final isSelected = dateStr == selectedDate;
              final isDayCompleted = entry.value != null && entry.value!.isCompleted;

              String label;
              if (index == 0) {
                label = l10n?.muhasabaToday ?? 'Today';
              } else if (index == 1) {
                label = l10n?.muhasabaYesterday ?? 'Yesterday';
              } else {
                label = DateFormat('MMM d', l10n?.localeName).format(date);
              }

              return InkWell(
                onTap: () {
                  ref.read(muhasabaSelectedDateProvider.notifier).state = dateStr;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.midnightNavyCard : AppColors.sandCard)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.gold
                              : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDayCompleted)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 10,
                              color: AppColors.gold,
                            )
                          else
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandBorder,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context, {
    required int index,
    required MuhasabaQuestion question,
    required String questionText,
    required int? currentAnswer,
    required bool isReadOnly,
    required ValueChanged<int?> onSelect,
  }) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentAnswer != null
              ? AppColors.gold.withValues(alpha: 0.5)
              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : AppColors.midnightNavy.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Options: Yes (2), Partly (1), No (0)
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  context,
                  key: ValueKey('option_${question.id}_2'),
                  label: l10n?.muhasabaYes ?? 'Yes',
                  icon: Icons.check_circle_outline_rounded,
                  isSelected: currentAnswer == 2,
                  isReadOnly: isReadOnly,
                  onTap: () => onSelect(currentAnswer == 2 ? null : 2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionButton(
                  context,
                  key: ValueKey('option_${question.id}_1'),
                  label: l10n?.muhasabaPartly ?? 'Partly',
                  icon: Icons.adjust_rounded,
                  isSelected: currentAnswer == 1,
                  isReadOnly: isReadOnly,
                  onTap: () => onSelect(currentAnswer == 1 ? null : 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOptionButton(
                  context,
                  key: ValueKey('option_${question.id}_0'),
                  label: l10n?.muhasabaNo ?? 'No',
                  icon: Icons.radio_button_unchecked_rounded,
                  isSelected: currentAnswer == 0,
                  isReadOnly: isReadOnly,
                  onTap: () => onSelect(currentAnswer == 0 ? null : 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required Key key,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isReadOnly,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: isReadOnly ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.18)
                : (isDark ? AppColors.midnightNavyCardElevated : AppColors.sandBackground),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.gold
                  : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppColors.gold
                    : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.gold
                        : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              title: Row(
                children: [
                  const Icon(Icons.nights_stay_rounded, color: AppColors.gold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.muhasabaReminderSetting ?? 'Nightly Muhasaba Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              content: FutureBuilder<bool>(
                future: MuhasabaReminderService.isReminderEnabled(),
                builder: (context, snapshot) {
                  final isEnabled = snapshot.data ?? true;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.muhasabaReminderBody ??
                            'Take a quiet moment with Allah: How was your day?',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: AppColors.gold.withValues(alpha: 0.5),
                        activeThumbColor: AppColors.gold,
                        title: Text(
                          l10n?.muhasabaReminderSetting ?? 'Nightly Reminder',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '10:00 PM',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                          ),
                        ),
                        value: isEnabled,
                        onChanged: (val) async {
                          await MuhasabaReminderService.setReminderEnabled(val);
                          setDialogState(() {});
                        },
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'OK',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
