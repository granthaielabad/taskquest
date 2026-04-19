import 'package:flutter/material.dart';

class AppTheme {
  // ── Theme Seeds ───────────────────────────────────────────────
  static const Color seedDefault = Color(0xFF111111);

  // ── Base Colors ──────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF7F6F2);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color borderLight = Color(0xFFE2E1DC);
  static const Color borderDark = Color(0xFF222222);
  static const Color muted = Color(0xFF777777);
  static const Color dimmed = Color(0xFFCCCAC4);

  // ── Text Styles (Base) ────────────────────────────────────────
  static const TextStyle headingXL = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 28,
    letterSpacing: -0.84,
  );

  static const TextStyle headingL = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 22,
    letterSpacing: -0.5,
  );

  static const TextStyle headingM = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    letterSpacing: -0.3,
  );

  static const TextStyle labelMono = TextStyle(
    fontFamily: 'DM Mono',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    letterSpacing: 1.4,
  );

  static const TextStyle bodyMono = TextStyle(
    fontFamily: 'DM Mono',
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  // ── Theme Generator ──────────────────────────────────────────
  static ThemeData createTheme({
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    
    // Explicitly define the color scheme to be monochromatic
    final colorScheme = ColorScheme.fromSeed(
      seedColor: isDark ? white : black,
      brightness: brightness,
      primary: isDark ? white : black, // Force black/white primary
      onPrimary: isDark ? black : white,
      surface: isDark ? backgroundDark : backgroundLight,
      onSurface: isDark ? white : black,
      outline: isDark ? borderDark : borderLight,
      surfaceContainerHighest: isDark ? const Color(0xFF1A1A1A) : white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? backgroundDark : backgroundLight,
      
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? backgroundDark : backgroundLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingM.copyWith(color: isDark ? white : black),
        iconTheme: IconThemeData(color: isDark ? white : black),
      ),

      textTheme: TextTheme(
        displayLarge: headingXL.copyWith(color: isDark ? white : black),
        displayMedium: headingL.copyWith(color: isDark ? white : black),
        displaySmall: headingM.copyWith(color: isDark ? white : black),
        bodyLarge: bodyMono.copyWith(color: isDark ? white : black),
        bodyMedium: bodyMono.copyWith(color: isDark ? white : black),
        labelSmall: labelMono.copyWith(color: isDark ? dimmed : muted),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? borderDark : borderLight,
        thickness: 1,
        space: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? white : black,
          foregroundColor: isDark ? black : white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : white,
        labelStyle: bodyMono.copyWith(fontSize: 11, color: isDark ? white : black),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isDark ? borderDark : borderLight),
        ),
      ),
    );
  }

  // ── Backward Compatibility ────────────────────────────────────
  static ThemeData get lightTheme => createTheme(brightness: Brightness.light);
  static ThemeData get darkTheme => createTheme(brightness: Brightness.dark);
}
