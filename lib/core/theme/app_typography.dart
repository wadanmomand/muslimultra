import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Muslim Ultra Typography System
/// Handles multi-script typography (Inter/Outfit for English, Amiri for Arabic & Urdu, etc.)
abstract class AppTypography {
  // Base font family getters
  static String get primaryFontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';
  static String get arabicFontFamily => GoogleFonts.amiri().fontFamily ?? 'Amiri';
  static String get urduFontFamily => GoogleFonts.notoNastaliqUrdu().fontFamily ?? 'NotoNastaliqUrdu';

  /// Returns font family dynamically based on language code
  static TextStyle getTextStyleForLocale({
    required String languageCode,
    required TextStyle baseStyle,
  }) {
    if (languageCode == 'ar') {
      return GoogleFonts.amiri(
        textStyle: baseStyle.copyWith(
          height: (baseStyle.height ?? 1.2) * 1.2,
        ),
      );
    } else if (languageCode == 'ur') {
      return GoogleFonts.notoNastaliqUrdu(
        textStyle: baseStyle.copyWith(
          height: (baseStyle.height ?? 1.2) * 1.4,
        ),
      );
    } else {
      return GoogleFonts.inter(textStyle: baseStyle);
    }
  }

  // Display & Headers
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Quranic script style
  static TextStyle quranAyahText({Color color = AppColors.goldLight, double fontSize = 24}) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      height: 2.0,
    );
  }
}
