import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_day_data.dart';
import 'package:muslim_ultra/features/hijri/presentation/providers/hijri_providers.dart';
import 'package:muslim_ultra/features/hijri/presentation/widgets/hijri_countdown_chip.dart';
import 'package:muslim_ultra/features/hijri/presentation/widgets/hijri_event_bottom_sheet.dart';
import 'package:muslim_ultra/features/hijri/presentation/widgets/hijri_month_grid.dart';

class HijriCalendarScreen extends ConsumerStatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  ConsumerState<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends ConsumerState<HijriCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    final monthData = ref.watch(currentHijriMonthDataProvider);
    final selectedDay = ref.watch(selectedHijriDayProvider);
    final nextMajorEvent = ref.watch(nextMajorEventProvider);
    final todayHijri = ref.watch(hijriDateProvider);

    final monthTitle = '${monthData.localizedMonthName(langCode)} ${monthData.hijriYear} ${l10n.ahSuffix}';
    final gregorianRange = _formatGregorianRange(monthData.gregorianStartDate, monthData.gregorianEndDate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          l10n.hijriCalendar,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.gold),
            tooltip: l10n.today,
            onPressed: () {
              ref.read(displayedHijriMonthProvider.notifier).resetToToday(
                    todayHijri.year,
                    todayHijri.month,
                  );
              // Select today
              final todayDayData = monthData.days.where((d) => d.isToday).firstOrNull;
              ref.read(selectedHijriDayProvider.notifier).state = todayDayData;
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -100) {
              // Swiped left
              if (isRtl) {
                ref.read(displayedHijriMonthProvider.notifier).goToPreviousMonth();
              } else {
                ref.read(displayedHijriMonthProvider.notifier).goToNextMonth();
              }
            } else if (details.primaryVelocity! > 100) {
              // Swiped right
              if (isRtl) {
                ref.read(displayedHijriMonthProvider.notifier).goToNextMonth();
              } else {
                ref.read(displayedHijriMonthProvider.notifier).goToPreviousMonth();
              }
            }
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Next Major Event Countdown Chip
              if (nextMajorEvent != null) ...[
                HijriCountdownChip(info: nextMajorEvent),
                const SizedBox(height: 16),
              ],

              // 2. Calendar Card Container
              Container(
                padding: const EdgeInsets.all(16),
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
                  children: [
                    // Month Navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.gold, size: 28),
                          onPressed: () {
                            ref.read(displayedHijriMonthProvider.notifier).goToPreviousMonth();
                          },
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                monthTitle,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                gregorianRange,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.gold.withValues(alpha: 0.9),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 28),
                          onPressed: () {
                            ref.read(displayedHijriMonthProvider.notifier).goToNextMonth();
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    // Month Days Grid
                    HijriMonthGrid(
                      monthData: monthData,
                      selectedDay: selectedDay,
                      onDaySelected: (day) {
                        ref.read(selectedHijriDayProvider.notifier).state = day;
                        if (day.hasNamedEvent) {
                          final event = day.events.first;
                          final todayClean = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                          );
                          final diff = day.gregorianDate.difference(todayClean).inDays;
                          HijriEventBottomSheet.show(
                            context,
                            event: event,
                            hijriDate: day.hijriDate,
                            gregorianDate: day.gregorianDate,
                            daysRemaining: diff,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Moon-sighting Disclaimer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.midnightNavyCard.withValues(alpha: 0.6)
                      : AppColors.sandCard.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.nightlight_round, size: 14, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.moonSightingDisclaimer,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Events in this Month / Selected Day
              _buildEventsSection(context, monthData, selectedDay, isDark, langCode),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection(
    BuildContext context,
    dynamic monthData,
    HijriDayData? selectedDay,
    bool isDark,
    String langCode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final events = monthData.allEvents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_note_rounded, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.eventsThisMonth,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (events.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              ),
            ),
            child: Center(
              child: Text(
                l10n.noEventsThisDay,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
              ),
            ),
          )
        else
          ...events.map((event) {
            final dayData = monthData.days.where((d) => d.hijriDay == event.hijriDay).firstOrNull;
            final todayClean = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );
            final daysDiff = dayData?.gregorianDate.difference(todayClean).inDays;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  if (dayData != null) {
                    HijriEventBottomSheet.show(
                      context,
                      event: event,
                      hijriDate: dayData.hijriDate,
                      gregorianDate: dayData.gregorianDate,
                      daysRemaining: daysDiff,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: event.isMajor
                          ? AppColors.gold.withValues(alpha: 0.4)
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${event.hijriDay}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                            if (dayData != null)
                              Text(
                                '${dayData.gregorianDate.day}/${dayData.gregorianDate.month}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.localizedName(langCode),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.localizedDescription(langCode),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (daysDiff != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: daysDiff == 0
                                ? AppColors.gold
                                : (isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            daysDiff == 0
                                ? l10n.todayEvent
                                : daysDiff == 1
                                    ? l10n.tomorrow
                                    : l10n.inDays(daysDiff),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: daysDiff == 0
                                  ? AppColors.midnightNavy
                                  : AppColors.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _formatGregorianRange(DateTime start, DateTime end) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${start.day}–${end.day} ${monthNames[start.month - 1]} ${start.year}';
      }
      return '${start.day} ${monthNames[start.month - 1]} – ${end.day} ${monthNames[end.month - 1]} ${start.year}';
    }
    return '${start.day} ${monthNames[start.month - 1]} ${start.year} – ${end.day} ${monthNames[end.month - 1]} ${end.year}';
  }
}
