import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/sadaqah/presentation/providers/sadaqah_providers.dart';

class SadaqahScreen extends ConsumerWidget {
  const SadaqahScreen({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            l10n?.logSadaqahTitle ?? 'Log Sadaqah',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('sadaqah_amount_input'),
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: l10n?.amountLabel ?? 'Amount',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                  hintText: 'e.g. 50',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('sadaqah_note_input'),
                controller: noteController,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: l10n?.optionalNoteLabel ?? 'Note (optional)',
                  labelStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                  hintText: 'e.g. Mosque charity',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gold, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              key: const ValueKey('btn_save_sadaqah'),
              onPressed: () async {
                final amountText = amountController.text.trim();
                final amount = double.tryParse(amountText);
                if (amount != null && amount > 0) {
                  await ref.read(sadaqahControllerProvider).logSadaqah(
                        amount,
                        note: noteController.text.trim(),
                      );
                  if (context.mounted) {
                    Navigator.of(dialogCtx).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n?.save ?? 'Save',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final bgColor = isDark ? AppColors.midnightNavyDark : AppColors.sandBackground;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final monthlyTotalAsync = ref.watch(monthlySadaqahTotalProvider);
    final allTimeTotalAsync = ref.watch(allTimeSadaqahTotalProvider);
    final entriesAsync = ref.watch(sadaqahEntriesProvider);

    final formatter = NumberFormat('#,##0.##');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('sadaqah_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.sadaqahTitle ?? 'Sadaqah Tracker',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('btn_add_sadaqah_fab'),
        onPressed: () => _showAddDialog(context, ref),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.midnightNavyDark,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n?.logSadaqahTitle ?? 'Log Sadaqah',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  Text(
                    l10n?.sadaqahThisMonth ?? 'This Month\'s Sadaqah',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatter.format(monthlyTotalAsync.value ?? 0.0),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n?.sadaqahAllTime ?? "All-time total"}: ${formatter.format(allTimeTotalAsync.value ?? 0.0)}',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n?.sadaqahHistoryTitle ?? 'Recent Contributions',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor.withAlpha((0.7 * 255).round()),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.volunteer_activism_rounded,
                          color: secondaryTextColor.withAlpha((0.6 * 255).round()),
                          size: 36,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n?.sadaqahEmptyState ?? 'No contributions logged yet.\nTap below to add your first entry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor.withAlpha((0.7 * 255).round()),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha((0.15 * 255).round()),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.gold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatter.format(item.amount),
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.note?.isNotEmpty == true
                                      ? '${item.date} · ${item.note}'
                                      : item.date,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                              size: 20,
                            ),
                            onPressed: () async {
                              await ref
                                  .read(sadaqahControllerProvider)
                                  .deleteEntry(item.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
              error: (_, __) => Center(
                child: Text(
                  l10n?.sadaqahLoadError ?? 'Unable to load Sadaqah entries.',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
