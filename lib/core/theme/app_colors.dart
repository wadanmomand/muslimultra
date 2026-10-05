import 'package:flutter/material.dart';

/// Muslim Ultra Design Tokens - Colors (Spec §8)
/// Primary Palette: Midnight Navy (#0A1628), Gold (#C9A227), Sand (#F5F0E6)
/// NOTE: The spec deliberately avoids green.
abstract class AppColors {
  // Brand Core Tokens
  static const Color midnightNavy = Color(0xFF0A1628);
  static const Color gold = Color(0xFFC9A227);
  static const Color sand = Color(0xFFF5F0E6);

  // Dark Palette Shades (Derived from Midnight Navy & Gold)
  static const Color midnightNavyDark = Color(0xFF060E1A);
  static const Color midnightNavyCard = Color(0xFF14233C);
  static const Color midnightNavyCardElevated = Color(0xFF1B2E4E);
  static const Color midnightNavyBorder = Color(0xFF233A5F);

  // Gold Tones (Accents & Highlights)
  static const Color goldLight = Color(0xFFE2C96C);
  static const Color goldBright = Color(0xFFFFDF73);
  static const Color goldDark = Color(0xFF967616);
  static const Color goldMuted = Color(0xFF6B5514);

  // Light Palette Shades (Derived from Sand & Midnight Navy)
  static const Color sandBackground = Color(0xFFF5F0E6);
  static const Color sandCard = Color(0xFFFFFFFF);
  static const Color sandCardElevated = Color(0xFFFAF7F0);
  static const Color sandBorder = Color(0xFFE5DDD0);
  static const Color sandTextPrimary = Color(0xFF0A1628);
  static const Color sandTextSecondary = Color(0xFF5A6678);

  // Dark Theme Text Palette
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Functional / Status (Spec compliant)
  static const Color statusActive = Color(0xFFC9A227);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFDF73), Color(0xFFC9A227), Color(0xFF967616)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient midnightGradient = LinearGradient(
    colors: [Color(0xFF060E1A), Color(0xFF0A1628), Color(0xFF14233C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF14233C), Color(0xFF0F1B30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sandCardGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF7F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
