import 'package:flutter/material.dart';

class AppColors {
  // Light Mode
  static const Color bgLight0 = Color(0xFFFFFFFF);
  static const Color bgLight1 = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0x0A000000);
  static const Color surface2Light = Color(0x0F000000);
  static const Color borderLight = Color(0x1A000000);
  static const Color textLight = Color(0xDE000000);
  static const Color mutedLight = Color(0x99000000);
  static const Color shadowLight = Color(0x1F000000);

  // Dark Mode
  static const Color bgDark0 = Color(0xFF0B1220);
  static const Color bgDark1 = Color(0xFF0F1A2E);
  static const Color surfaceDark = Color(0x0FFFFFFF);
  static const Color surface2Dark = Color(0x17FFFFFF);
  static const Color borderDark = Color(0x1AFFFFFF);
  static const Color textDark = Color(0xEBFFFFFF);
  static const Color mutedDark = Color(0xA3FFFFFF);
  static const Color shadowDark = Color(0x59000000);

  // Accent Colors
  static const Color accentLight = Color(0xFF2563EB);
  static const Color accent2Light = Color(0xFF7C3AED);
  static const Color accentDark = Color(0xFF4F86FF);
  static const Color accent2Dark = Color(0xFF7C5CFF);

  // Card Gradient Colors
  static const Color card1Start = Color(0xD9256BEB);
  static const Color card1End = Color(0xBF7C3AED);
  static const Color card2Start = Color(0xD9FB923C);
  static const Color card2End = Color(0xBFF97316);
  static const Color card3Start = Color(0xD922C55E);
  static const Color card3End = Color(0xBF3B82F6);
  static const Color card4Start = Color(0xD9EF4444);
  static const Color card4End = Color(0xBFF87171);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFB923C);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Montserrat',
      scaffoldBackgroundColor: AppColors.bgLight0,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentLight,
        secondary: AppColors.accent2Light,
        surface: AppColors.bgLight1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Montserrat',
      scaffoldBackgroundColor: AppColors.bgDark0,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentDark,
        secondary: AppColors.accent2Dark,
        surface: AppColors.bgDark1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
