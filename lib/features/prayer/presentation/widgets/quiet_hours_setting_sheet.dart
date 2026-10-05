import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

class QuietHoursSettingSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final startH = (settings.quietHoursStartMinutes ~/ 60).toString().padLeft(2, '0');
    final startM = (settings.quietHoursStartMinutes % 60).toString().padLeft(2, '0');
    final endH = (settings.quietHoursEndMinutes ~/ 60).toString().padLeft(2, '0');
    final endM = (settings.quietHoursEndMinutes % 60).toString().padLeft(2, '0');

    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
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
            const Row(
              children: [
                Icon(Icons.bedtime_outlined, color: AppColors.gold),
                SizedBox(width: 8),
                Text(
                  'Athan Quiet Hours Settings (Spec §3 M1)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Quiet Hours Mute'),
              subtitle: const Text('Silences Athan notifications during your designated sleep window'),
              activeTrackColor: AppColors.gold,
              activeThumbColor: AppColors.midnightNavyDark,
              value: settings.enableQuietHours,
              onChanged: (val) {
                ref.read(notificationSettingsProvider.notifier).setQuietHours(enabled: val);
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Start Time', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '$startH:$startM',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.goldLight),
                  Column(
                    children: [
                      const Text('End Time', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '$endH:$endM',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
