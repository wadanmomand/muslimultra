import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/data/services/notification_service.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

class QuietHoursSettingSheet extends ConsumerStatefulWidget {
  const QuietHoursSettingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuietHoursSettingSheet(),
    );
  }

  @override
  ConsumerState<QuietHoursSettingSheet> createState() => _QuietHoursSettingSheetState();
}

class _QuietHoursSettingSheetState extends ConsumerState<QuietHoursSettingSheet> {
  bool _canExactAlarm = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final canExact = await PrayerNotificationService.canScheduleExactAlarms();
    if (mounted) {
      setState(() {
        _canExactAlarm = canExact;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(notificationSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final startH = (settings.quietHoursStartMinutes ~/ 60).toString().padLeft(2, '0');
    final startM = (settings.quietHoursStartMinutes % 60).toString().padLeft(2, '0');
    final endH = (settings.quietHoursEndMinutes ~/ 60).toString().padLeft(2, '0');
    final endM = (settings.quietHoursEndMinutes % 60).toString().padLeft(2, '0');

    final prayers = [
      (name: 'Fajr', label: l10n.fajr, enabled: settings.enableFajr),
      (name: 'Sunrise', label: l10n.sunrise, enabled: settings.enableSunrise),
      (name: 'Dhuhr', label: l10n.dhuhr, enabled: settings.enableDhuhr),
      (name: 'Asr', label: l10n.asr, enabled: settings.enableAsr),
      (name: 'Maghrib', label: l10n.maghrib, enabled: settings.enableMaghrib),
      (name: 'Isha', label: l10n.isha, enabled: settings.enableIsha),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withValues(alpha: 0.3) : AppColors.sandBorder,
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: AppColors.gold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.prayerNotifications,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Exact Alarm Permission Warning Banner (if disabled on Android 12+)
              if (!_canExactAlarm) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.exactAlarmTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.exactAlarmDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.midnightNavyDark,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            await PrayerNotificationService.requestExactAlarmPermission();
                            await _checkPermissions();
                          },
                          child: Text(
                            l10n.enableExactAlarm,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Per-Prayer Notification Toggles
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Column(
                  children: prayers.map((p) {
                    return SwitchListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                        ),
                      ),
                      secondary: Icon(
                        p.enabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                        size: 20,
                        color: p.enabled ? AppColors.gold : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                      ),
                      activeTrackColor: AppColors.gold,
                      activeThumbColor: AppColors.midnightNavyDark,
                      value: p.enabled,
                      onChanged: (val) {
                        ref.read(notificationSettingsProvider.notifier).togglePrayer(p.name);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 15-Minute Pre-Prayer Reminder
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    l10n.prePrayerReminder,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.prePrayerReminderDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                  ),
                  secondary: const Icon(Icons.alarm, color: AppColors.gold, size: 22),
                  activeTrackColor: AppColors.gold,
                  activeThumbColor: AppColors.midnightNavyDark,
                  value: settings.enablePrePrayerReminder,
                  onChanged: (val) {
                    ref.read(notificationSettingsProvider.notifier).togglePrePrayerReminder();
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Quiet Hours Section
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.quietHoursTitle,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        l10n.quietHoursDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                        ),
                      ),
                      secondary: const Icon(Icons.bedtime_outlined, color: AppColors.gold, size: 22),
                      activeTrackColor: AppColors.gold,
                      activeThumbColor: AppColors.midnightNavyDark,
                      value: settings.enableQuietHours,
                      onChanged: (val) {
                        ref.read(notificationSettingsProvider.notifier).setQuietHours(enabled: val);
                      },
                    ),
                    if (settings.enableQuietHours) ...[
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Start', style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '$startH:$startM',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: AppColors.goldLight, size: 16),
                          Column(
                            children: [
                              const Text('End', style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '$endH:$endM',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Audio Notice Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note_outlined, color: AppColors.gold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.athanAudioNotice,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                            ),
                          ),
                          Text(
                            l10n.athanAudioDesc,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
