import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

class QiblaCompassDial extends ConsumerWidget {
  const QiblaCompassDial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaData = ref.watch(qiblaDataProvider);
    final location = ref.watch(locationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isAligned = qiblaData.isAligned; // ±2° tolerance (Spec §3 M1)
    final headingAngleRad = (qiblaData.currentHeading * math.pi) / 180.0;
    final qiblaAngleRad = (qiblaData.qiblaBearing * math.pi) / 180.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Alignment Banner Badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isAligned
                  ? AppColors.gold.withValues(alpha: 0.25)
                  : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAligned ? AppColors.gold : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                width: isAligned ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAligned ? Icons.check_circle_rounded : Icons.explore_outlined,
                  color: isAligned ? AppColors.gold : AppColors.goldLight,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isAligned ? 'Aligned with Qibla (±2°)' : 'Rotate phone towards Kaaba',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isAligned ? AppColors.gold : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Compass Dial Stack
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              border: Border.all(
                color: isAligned ? AppColors.goldBright : AppColors.gold,
                width: isAligned ? 3.5 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isAligned
                      ? AppColors.gold.withValues(alpha: 0.45)
                      : AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: isAligned ? 32 : 16,
                  spreadRadius: isAligned ? 4 : 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating Dial with Cardinal Marks
                Transform.rotate(
                  angle: -headingAngleRad,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cardinal Directions
                      const Positioned(
                        top: 14,
                        child: Text(
                          'N',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.error),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        child: Text(
                          'S',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        child: Text(
                          'E',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        child: Text(
                          'W',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          ),
                        ),
                      ),
                      // Ticks around the dial
                      ...List.generate(12, (index) {
                        final angle = index * (math.pi / 6);
                        return Transform.rotate(
                          angle: angle,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: index % 3 == 0 ? 3 : 1.5,
                              height: index % 3 == 0 ? 10 : 6,
                              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                            ),
                          ),
                        );
                      }),
                      // Kaaba Needle Marker on the Dial
                      Transform.rotate(
                        angle: qiblaAngleRad,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isAligned ? AppColors.goldBright : AppColors.gold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.navigation_rounded,
                                color: AppColors.midnightNavyDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 70),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Pin
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bearing & Distance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAligned
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${qiblaData.qiblaBearing.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Qibla Bearing',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${qiblaData.distanceKm.toInt()} km',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Distance to Kaaba',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_pin, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      'From: ${location.displayName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Sensor Test Slider (Allows manually testing azimuth & heading on emulator/desktop)
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyDark : AppColors.sandCardElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Device Compass Heading Simulator',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${qiblaData.currentHeading.toStringAsFixed(1)}°',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold),
                      ),
                    ],
                  ),
                  Slider(
                    value: qiblaData.currentHeading,
                    min: 0.0,
                    max: 360.0,
                    activeColor: AppColors.gold,
                    onChanged: (val) {
                      ref.read(qiblaDataProvider.notifier).setManualHeading(val);
                    },
                  ),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.gps_fixed, size: 14, color: AppColors.gold),
                      label: const Text(
                        'Align to Qibla Exact (±0°)',
                        style: TextStyle(color: AppColors.gold, fontSize: 11),
                      ),
                      onPressed: () {
                        ref.read(qiblaDataProvider.notifier).setManualHeading(qiblaData.qiblaBearing);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
