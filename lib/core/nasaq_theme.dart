import "package:flutter/material.dart";

/// نظام التصميم الخاص بمنصة «نَسَق» المستوحى من الهوية العربية التراثية المعاصرة
class NasaqColors {
  // الخلفيات الرملية والعاجية الدافئة
  static const Color sandBackgroundTop = Color(0xFFFBF9F5);
  static const Color sandBackgroundBottom = Color(0xFFEDE5D5);
  static const Color cardSurface = Color(0xFFFFFDF9);
  static const Color cardBorder = Color(0xFFE6DEC8);

  // ألوان الهوية الأساسية
  static const Color primaryNavy = Color(0xFF2B465B);
  static const Color secondaryNavy = Color(0xFF1E3344);
  static const Color accentGold = Color(0xFFC5A572);
  static const Color accentGoldLight = Color(0xFFE5D4B3);
  static const Color iconAzure = Color(0xFF3A7CA5);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF243B4A);
  static const Color textSecondary = Color(0xFF6E6A63);
  static const Color textMuted = Color(0xFF9C9588);

  // ألوان الوضع الليلي الفاخر (عند التبديل الاختياري)
  static const Color darkBackground = Color(0xFF101922);
  static const Color darkSurface = Color(0xFF192633);
  static const Color darkBorder = Color(0xFF2C3E50);
}

class NasaqTheme {
  static ThemeData get lightHeritageTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NasaqColors.primaryNavy,
      brightness: Brightness.light,
      primary: NasaqColors.primaryNavy,
      secondary: NasaqColors.accentGold,
      tertiary: NasaqColors.iconAzure,
      surface: NasaqColors.cardSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NasaqColors.sandBackgroundTop,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: NasaqColors.primaryNavy,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: NasaqColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: NasaqColors.cardBorder, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NasaqColors.primaryNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkHeritageTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NasaqColors.primaryNavy,
      brightness: Brightness.dark,
      primary: NasaqColors.accentGold,
      secondary: NasaqColors.iconAzure,
      surface: NasaqColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NasaqColors.darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF5F1E8),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: NasaqColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: NasaqColors.darkBorder, width: 1.2),
        ),
      ),
    );
  }
}
