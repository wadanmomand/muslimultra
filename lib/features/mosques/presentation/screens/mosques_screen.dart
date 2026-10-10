import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/mosques/domain/models/mosque.dart';
import 'package:muslim_ultra/features/mosques/data/mosques_repository.dart';
import 'package:muslim_ultra/features/mosques/presentation/providers/mosques_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

class MosquesScreen extends ConsumerWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = ref.watch(locationProvider);
    final selectedRadius = ref.watch(mosquesRadiusProvider);
    final mosquesAsync = ref.watch(nearbyMosquesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          l10n.mosquesTitle,
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
        actions: [
          IconButton(
            tooltip: l10n.mosquesGpsTooltip,
            icon: const Icon(Icons.my_location_rounded, size: 20),
            onPressed: () async {
              await ref.read(locationProvider.notifier).useGpsLocation();
              ref.invalidate(nearbyMosquesProvider);
            },
          ),
          IconButton(
            tooltip: l10n.mosquesRefreshTooltip,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () {
              ref.invalidate(nearbyMosquesProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Location + Radius Header
          _buildFilterHeader(context, ref, isDark, l10n, location.displayName, selectedRadius),

          // Main Content
          Expanded(
            child: mosquesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (err, _) => _buildErrorState(context, ref, isDark, l10n, err),
              data: (result) => _buildMosquesList(context, ref, isDark, l10n, result),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
    String locationName,
    int selectedRadius,
  ) {
    final radii = [
      {'meters': 1000, 'label': l10n.mosquesRadius1km},
      {'meters': 2000, 'label': l10n.mosquesRadius2km},
      {'meters': 5000, 'label': l10n.mosquesRadius5km},
      {'meters': 10000, 'label': l10n.mosquesRadius10km},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Location Strip
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Radius Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: radii.map((r) {
                final meters = r['meters'] as int;
                final label = r['label'] as String;
                final isSelected = selectedRadius == meters;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.midnightNavyDark
                            : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.gold,
                    backgroundColor:
                        isDark ? AppColors.midnightNavyCard : AppColors.sandBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.gold
                            : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(mosquesRadiusProvider.notifier).state = meters;
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosquesList(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
    MosquesQueryResult result,
  ) {
    if (result.mosques.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mosque_outlined,
                size: 56,
                color: AppColors.gold.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.mosquesEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mosquesEmptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: result.mosques.length + (result.isFromCache ? 1 : 0),
      itemBuilder: (context, index) {
        if (result.isFromCache && index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.mosquesCachedNotice,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final mosqueIndex = result.isFromCache ? index - 1 : index;
        final mosque = result.mosques[mosqueIndex];
        return _buildMosqueCard(context, isDark, l10n, mosque);
      },
    );
  }

  Widget _buildMosqueCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    Mosque mosque,
  ) {
    final distanceText = mosque.distanceMeters >= 1000
        ? '${(mosque.distanceMeters / 1000).toStringAsFixed(1)} km'
        : '${mosque.distanceMeters.round()} m';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openMapAffordance(context, l10n, mosque),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mosque Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.mosque_outlined,
                    color: AppColors.gold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (mosque.street != null || mosque.city != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          [mosque.street, mosque.city].whereType<String>().join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.sandTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Distance + Bearing Indicator
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        distanceText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.goldLight : AppColors.goldDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                          angle: mosque.bearingDegrees * (math.pi / 180.0),
                          child: const Icon(
                            Icons.navigation_rounded,
                            size: 14,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${mosque.bearingDegrees.round()}°',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.sandTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
    Object error,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.mosquesOfflineTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.mosquesOfflineMessage,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(nearbyMosquesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                l10n.mosquesRetry,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMapAffordance(
    BuildContext context,
    AppLocalizations l10n,
    Mosque mosque,
  ) {
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mosque.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${mosque.latitude.toStringAsFixed(5)}, ${mosque.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_rounded, color: AppColors.gold, size: 22),
                  ),
                  title: Text(
                    l10n.mosquesOpenMaps,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    mapsUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                  ),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: mapsUrl));
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.mosquesMapLinkCopied),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.midnightNavy,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
