import 'package:flutter/material.dart';

class NeoTheme {
  NeoTheme._();

  // =========================
  // COLORS
  // =========================

  static const Color background = Color(0xFF09090F);

  static const Color surface = Color(0xFF11111B);

  static const Color card = Color(0xFF171725);

  static const Color border = Color(0xFF26263A);

  static const Color accent = Color(0xFF8B5CF6);

  static const Color accentGlow = Color(0xFFA855F7);

  static const Color white = Colors.white;

  static const Color textPrimary = Color(0xFFF5F5F7);

  static const Color textSecondary = Color(0xFF9E9EB3);

  static const Color textHint = Color(0xFF686881);

  // =========================
  // GRADIENTS
  // =========================

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF111122), Color(0xFF09090F)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
  );

  // =========================
  // SHADOWS
  // =========================

  static List<BoxShadow> get glow => [
    BoxShadow(
      color: accent.withValues(alpha: .35),
      blurRadius: 40,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .35),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  // =========================
  // RADIUS
  // =========================

  static BorderRadius get radius12 => BorderRadius.circular(12);

  static BorderRadius get radius16 => BorderRadius.circular(16);

  static BorderRadius get radius20 => BorderRadius.circular(20);

  static BorderRadius get radius24 => BorderRadius.circular(24);

  static BorderRadius get radius28 => BorderRadius.circular(28);

  // =========================
  // SPACING
  // =========================

  static const double xs = 4;

  static const double sm = 8;

  static const double md = 16;

  static const double lg = 24;

  static const double xl = 32;

  static const double xxl = 40;

  // =========================
  // THEME
  // =========================

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      useMaterial3: true,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      dividerColor: border,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentGlow,
        surface: surface,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: Color(0xFF26233A),
        thumbColor: accentGlow,
        overlayColor: Color(0x228B5CF6),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 36,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(color: textSecondary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }
}
