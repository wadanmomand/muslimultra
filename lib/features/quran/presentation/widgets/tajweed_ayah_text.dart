import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/theme/app_typography.dart';
import 'package:muslim_ultra/features/quran/domain/models/tajweed_rule.dart';

class TajweedAyahText extends StatelessWidget {
  final String textUthmani;
  final List<TajweedAnnotation>? annotations;
  final bool isTajweedEnabled;
  final bool isDark;
  final double fontSize;
  final String? endMarker;

  const TajweedAyahText({
    super.key,
    required this.textUthmani,
    this.annotations,
    required this.isTajweedEnabled,
    required this.isDark,
    required this.fontSize,
    this.endMarker,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTypography.quranAyahText(
      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
      fontSize: fontSize,
    ).copyWith(height: 2.15);

    final endMarkerStyle = TextStyle(
      fontFamily: AppTypography.arabicFontFamily,
      color: AppColors.gold,
      fontSize: fontSize * 0.92,
      fontWeight: FontWeight.bold,
    );

    // If Tajweed mode is off or no annotations available, render plain Arabic
    if (!isTajweedEnabled || annotations == null || annotations!.isEmpty) {
      if (endMarker != null) {
        return Text.rich(
          TextSpan(
            style: baseStyle,
            children: [
              TextSpan(text: textUthmani),
              TextSpan(text: endMarker, style: endMarkerStyle),
            ],
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        );
      }
      return Text(
        textUthmani,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    // Tajweed mode is ON -> build colored spans
    final spans = TajweedSpanBuilder.buildSpans(
      rawText: textUthmani,
      annotations: annotations!,
      isDark: isDark,
      baseStyle: baseStyle,
      endMarker: endMarker,
      endMarkerStyle: endMarkerStyle,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: spans,
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }
}
