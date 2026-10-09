import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/deen/data/activity_heatmap.dart';

class ActivityHeatmapWidget extends StatefulWidget {
  final List<DayActivity> activities;
  final int totalWeeks;

  const ActivityHeatmapWidget({
    super.key,
    required this.activities,
    this.totalWeeks = 53,
  });

  @override
  State<ActivityHeatmapWidget> createState() => _ActivityHeatmapWidgetState();
}

class _ActivityHeatmapWidgetState extends State<ActivityHeatmapWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showDayDetails(BuildContext context, DayActivity activity, AppLocalizations? l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = '${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}-${activity.date.day.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha((0.4 * 255).round()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(activity.score * 100).toInt()}% ${l10n?.heatmapActivityLabel ?? "Activity"}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.check_circle_outline_rounded,
                l10n?.heatmapPrayersDone ?? 'Prayers Prayed',
                '${activity.prayersPrayed}/5',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.menu_book,
                l10n?.heatmapQuranMins ?? 'Quran Reading',
                '${activity.quranMinutes} min',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.nights_stay_outlined,
                l10n?.heatmapFasting ?? 'Fasting Status',
                activity.isFasting
                    ? (l10n?.heatmapFastKept ?? 'Fasted ✓')
                    : (l10n?.heatmapNoFast ?? 'None'),
                isDark,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.auto_awesome,
                l10n?.heatmapXpEarned ?? 'Estimated XP',
                '+${activity.estimatedXp} XP',
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyDark : AppColors.sandCardElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForIntensity(int level, bool isDark) {
    switch (level) {
      case 1:
        return AppColors.gold.withAlpha((0.25 * 255).round());
      case 2:
        return AppColors.gold.withAlpha((0.50 * 255).round());
      case 3:
        return AppColors.gold.withAlpha((0.75 * 255).round());
      case 4:
        return AppColors.gold;
      case 0:
      default:
        return isDark
            ? AppColors.midnightNavyDark.withAlpha((0.6 * 255).round())
            : AppColors.sandCardElevated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final totalWeeks = widget.totalWeeks;
    final cellWidth = 11.5;
    final cellSpacing = 3.0;
    final rowCount = 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.cardGradientDark : null,
        color: isDark ? null : AppColors.sandCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withAlpha((0.35 * 255).round()),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.midnightNavyDark,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n?.heatmapTitle ?? 'Year in Deen',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n?.heatmapSubtitle ?? '52 Weeks Activity',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),


          const SizedBox(height: 14),

          // Scrollable Grid of 53 Weeks x 7 Days
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: (rowCount * cellWidth) + ((rowCount - 1) * cellSpacing),
              child: Row(
                children: List.generate(totalWeeks, (weekIdx) {
                  return Padding(
                    padding: EdgeInsets.only(right: weekIdx < totalWeeks - 1 ? cellSpacing : 0),
                    child: Column(
                      children: List.generate(rowCount, (dayIdx) {
                        final itemIndex = (weekIdx * 7) + dayIdx;
                        final activity = itemIndex < widget.activities.length
                            ? widget.activities[itemIndex]
                            : DayActivity(date: DateTime.now(), score: 0);

                        final level = activity.intensityLevel;
                        final cellColor = _colorForIntensity(level, isDark);

                        return Padding(
                          padding: EdgeInsets.only(bottom: dayIdx < rowCount - 1 ? cellSpacing : 0),
                          child: InkWell(
                            key: ValueKey('heatmap_cell_${weekIdx}_$dayIdx'),
                            onTap: () => _showDayDetails(context, activity, l10n),
                            borderRadius: BorderRadius.circular(2.5),
                            child: Container(
                              width: cellWidth,
                              height: cellWidth,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(2.5),
                                border: Border.all(
                                  color: level > 0
                                      ? AppColors.gold.withAlpha((0.4 * 255).round())
                                      : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                                  width: 0.6,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legend: Less -> 5 steps -> More
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n?.heatmapLegendLess ?? 'Less',
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              ...List.generate(5, (idx) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _colorForIntensity(idx, isDark),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: idx > 0
                          ? AppColors.gold.withAlpha((0.4 * 255).round())
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      width: 0.5,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text(
                l10n?.heatmapLegendMore ?? 'More',
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
