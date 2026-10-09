import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/share_card/presentation/widgets/ayah_share_card.dart';

class AyahSharePreviewDialog extends StatefulWidget {
  final AyahModel ayah;
  final String surahName;
  final String? translationText;

  const AyahSharePreviewDialog({
    super.key,
    required this.ayah,
    required this.surahName,
    this.translationText,
  });

  static Future<void> show(
    BuildContext context, {
    required AyahModel ayah,
    required String surahName,
    String? translationText,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AyahSharePreviewDialog(
        ayah: ayah,
        surahName: surahName,
        translationText: translationText,
      ),
    );
  }

  @override
  State<AyahSharePreviewDialog> createState() => _AyahSharePreviewDialogState();
}

class _AyahSharePreviewDialogState extends State<AyahSharePreviewDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareImage() async {
    setState(() => _isSharing = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final xFile = XFile.fromData(
        pngBytes,
        mimeType: 'image/png',
        name: 'ayah_${widget.ayah.surahNumber}_${widget.ayah.numberInSurah}.png',
      );

      await Share.shareXFiles(
        [xFile],
        text: '${widget.surahName} (${widget.ayah.surahNumber}:${widget.ayah.numberInSurah}) — via Muslim Ultra',
      );
    } catch (e) {
      debugPrint('AyahSharePreviewDialog: Failed to export/share card: $e');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? AppColors.midnightNavyDark : AppColors.sandCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.share_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.sharePreviewTitle ?? 'Share Ayah Card',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Preview
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: AyahShareCard(
                    boundaryKey: _boundaryKey,
                    ayah: widget.ayah,
                    surahName: widget.surahName,
                    translationText: widget.translationText,
                    languageCode: locale.languageCode,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Share Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                key: const ValueKey('btn_share_card_export'),
                onPressed: _isSharing ? null : _shareImage,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.midnightNavyDark,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isSharing
                      ? (l10n?.shareGeneratingImage ?? 'Generating image...')
                      : (l10n?.shareCardButton ?? 'Share Card'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.midnightNavyDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
