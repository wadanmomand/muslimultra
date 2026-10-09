import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_day_data.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_month_data.dart';

class HijriMonthGrid extends StatelessWidget {
  final HijriMonthData monthData;
  final HijriDayData? selectedDay;
  final ValueChanged<HijriDayData> onDaySelected;

  const HijriMonthGrid({
    super.key,
    required this.monthData,
    required this.selectedDay,
    required this.onDaySelected,
  });

  static const List<String> weekDaysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const List<String> weekDaysAr = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  static const List<String> weekDaysUr = ['اتوار', 'پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    final weekDays = langCode.startsWith('ar')
        ? weekDaysAr
        : langCode.startsWith('ur')
            ? weekDaysUr
            : weekDaysEn;

    // Sunday = 0, Mon = 1, ..., Sat = 6
    final firstDayWeekday = monthData.days.isNotEmpty ? (monthData.days.first.gregorianDate.weekday % 7) : 0;
    final totalCells = firstDayWeekday + monthData.daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Weekday header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: List.generate(7, (index) {
              final isFriday = (index == 5); // Friday
              return Expanded(
                child: Center(
                  child: Text(
                    weekDays[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isFriday ? FontWeight.bold : FontWeight.w600,
                      color: isFriday
                          ? AppColors.gold
                          : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),

        // Month Days Grid
        Table(
          children: List.generate(totalRows, (rowIndex) {
            return TableRow(
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayIndex = cellIndex - firstDayWeekday;

                if (dayIndex < 0 || dayIndex >= monthData.daysInMonth) {
                  return const SizedBox(height: 52);
                }

                final dayData = monthData.days[dayIndex];
                final isSelected = selectedDay != null &&
                    selectedDay!.hijriDay == dayData.hijriDay &&
                    selectedDay!.hijriMonth == dayData.hijriMonth &&
                    selectedDay!.hijriYear == dayData.hijriYear;

                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: _buildDayCell(context, dayData, isSelected, isDark),
                );
              }),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    HijriDayData day,
    bool isSelected,
    bool isDark,
  ) {
    final isToday = day.isToday;
    final hasMajorEvent = day.hasMajorEvent;
    final hasNamedEvent = day.hasNamedEvent;

    // Background color
    Color backgroundColor;
    if (isToday) {
      backgroundColor = AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.18);
    } else if (isSelected) {
      backgroundColor = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    } else if (hasMajorEvent) {
      backgroundColor = AppColors.gold.withValues(alpha: isDark ? 0.08 : 0.06);
    } else {
      backgroundColor = Colors.transparent;
    }

    // Border
    Border border;
    if (isToday) {
      border = Border.all(
        color: AppColors.gold,
        width: 1.6,
      );
    } else if (isSelected) {
      border = Border.all(
        color: AppColors.gold.withValues(alpha: 0.6),
        width: 1.2,
      );
    } else if (hasMajorEvent) {
      border = Border.all(
        color: AppColors.gold.withValues(alpha: 0.3),
        width: 1.0,
      );
    } else {
      border = Border.all(
        color: Colors.transparent,
        width: 1.0,
      );
    }

    return InkWell(
      onTap: () => onDaySelected(day),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hijri Day Number
                Text(
                  '${day.hijriDay}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || hasMajorEvent || isSelected
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: isToday
                        ? AppColors.gold
                        : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                  ),
                ),
                const SizedBox(height: 1),
                // Gregorian day number
                Text(
                  '${day.gregorianDate.day}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
              ],
            ),

            // Event Marker Dot
            if (hasNamedEvent)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: hasMajorEvent ? 6 : 4,
                  height: hasMajorEvent ? 6 : 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                    boxShadow: hasMajorEvent
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.6),
                              blurRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
