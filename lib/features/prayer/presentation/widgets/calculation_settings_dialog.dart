import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/data/services/location_service.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

class CalculationSettingsDialog extends ConsumerWidget {
  const CalculationSettingsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CalculationSettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(prayerParametersProvider);
    final currentLocation = ref.watch(locationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, color: AppColors.gold),
                      SizedBox(width: 8),
                      Text(
                        'Calculation & Location Settings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Location Selection
              const Text(
                'Location / City',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Active: ${currentLocation.displayName}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.my_location, size: 16, color: AppColors.gold),
                          label: const Text('Use GPS', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                          onPressed: () async {
                            await ref.read(locationProvider.notifier).useGpsLocation();
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    // Preset City Switcher
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: LocationService.presetLocations.map((loc) {
                        final isSelected = currentLocation.cityName == loc.cityName;
                        return ChoiceChip(
                          label: Text(loc.cityName, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: AppColors.gold.withValues(alpha: 0.25),
                          onSelected: (_) {
                            ref.read(locationProvider.notifier).setLocation(loc);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Calculation Method
              const Text(
                'Calculation Method (Spec §3 M1)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Column(
                  children: CalculationMethod.values.map((m) {
                    final isSelected = params.method == m;
                    return InkWell(
                      onTap: () {
                        ref.read(prayerParametersProvider.notifier).setMethod(m);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppColors.gold : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                m.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.gold : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Asr Juristic Method (Madhab)
              const Text(
                'Asr Juristic Method (Madhab)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
              const SizedBox(height: 8),
              Row(
                children: Madhab.values.map((madhab) {
                  final isSelected = params.madhab == madhab;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          ref.read(prayerParametersProvider.notifier).setMadhab(madhab);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold.withValues(alpha: 0.2)
                                : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.gold : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                madhab.name == 'standard' ? 'Standard' : 'Hanafi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.gold : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                madhab.name == 'standard' ? 'Shafi\'i/Maliki/Hanbali' : 'Shadow Factor 2x',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 4. Hijri Calendar Adjustment (±1 day)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hijri Date Adjustment (Umm al-Qura)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold),
                  ),
                  Text(
                    '${params.hijriOffsetDays > 0 ? '+' : ''}${params.hijriOffsetDays} Day(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Slider(
                value: params.hijriOffsetDays.toDouble(),
                min: -2.0,
                max: 2.0,
                divisions: 4,
                activeColor: AppColors.gold,
                inactiveColor: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                onChanged: (val) {
                  ref.read(prayerParametersProvider.notifier).setHijriOffset(val.round());
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
