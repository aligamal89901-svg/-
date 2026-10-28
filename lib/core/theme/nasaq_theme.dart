import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NasaqColors {
  // Luxury Light Paper Palette (الثيم الفاتح الورقي الأصيل)
  static const Color paperBackground = Color(0xFFF7F2E9);
  static const Color paperSurface = Color(0xFFFFFFFF);
  static const Color paperSurfaceAlt = Color(0xFFEFE8DB);
  static const Color inkPrimary = Color(0xFF14110E);
  static const Color inkMuted = Color(0xFF6E685F);

  // Accents (الذهب والزمرد الملكي)
  static const Color emeraldRoyal = Color(0xFF0F766E);
  static const Color emeraldLight = Color(0xFF14B886);
  static const Color goldArabic = Color(0xFFC29B38);
  static const Color goldMuted = Color(0xFFD9B26A);

  // توافق شامل وتوجيه للثيم الفاتح الملكي
  static const Color background = paperBackground;
  static const Color surface = paperSurface;
  static const Color surfaceSecondary = paperSurfaceAlt;
  static const Color textPrimary = inkPrimary;
  static const Color textMuted = inkMuted;
  static const Color emerald = emeraldRoyal;
  static const Color gold = goldArabic;

  // Glassmorphic Const Tokens
  static const Color glassSurface = Color(0xB8FFFFFF);
  static const Color glassBorder = Color(0xD9FFFFFF);
  static const Color glassBorderGold = Color(0x47D9B26A);

  // Specialization Accents
  static const Color designAccent = Color(0xFF7C3AED);
  static const Color codeAccent = Color(0xFF2563EB);
  static const Color terminalAccent = Color(0xFF0D9488);
  static const Color writingAccent = Color(0xFFD97706);
}

class NasaqTheme {
  static ThemeData get lightPaperTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: NasaqColors.paperBackground,
      primaryColor: NasaqColors.emeraldRoyal,
      colorScheme: const ColorScheme.light(
        primary: NasaqColors.emeraldRoyal,
        secondary: NasaqColors.goldArabic,
        surface: NasaqColors.paperSurface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.readexPro(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: NasaqColors.inkPrimary,
          height: 1.7,
        ),
        displayMedium: GoogleFonts.readexPro(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: NasaqColors.inkPrimary,
          height: 1.7,
        ),
        titleLarge: GoogleFonts.readexPro(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: NasaqColors.inkPrimary,
          height: 1.7,
        ),
        bodyLarge: GoogleFonts.ibmPlexSansArabic(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: NasaqColors.inkPrimary,
          height: 1.75,
        ),
        bodyMedium: GoogleFonts.ibmPlexSansArabic(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: NasaqColors.inkMuted,
          height: 1.7,
        ),
      ),
    );
  }
}
