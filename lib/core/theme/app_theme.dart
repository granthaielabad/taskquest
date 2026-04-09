import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors (Base) ──────────────────────────
  static const Color backgroundLight = Color(0xFFF7F6F2); // warm parchment
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color black = Color(0xFF111111);
  static const Color borderLight = Color(0xFFE2E1DC);
  static const Color borderDark = Color(0xFF222222);
  static const Color muted = Color(0xFF777777);
  static const Color dimmed = Color(0xFFCCCAC4);
  static const Color white = Color(0xFFFFFFFF);

  // ── Text Styles (Base - Use them with copyWith(color: ...)) ──
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

  // ── Theme ────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundLight,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: black,
      surface: backgroundLight,
      onPrimary: white,
      onSurface: black,
      outline: borderLight,
      onSurfaceVariant: muted,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Syne',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: -0.3,
        color: black,
      ),
      iconTheme: IconThemeData(color: black),
    ),
    textTheme: const TextTheme(
      displayLarge: headingXL,
      displayMedium: headingL,
      displaySmall: headingM,
      bodyLarge: bodyMono,
      bodyMedium: bodyMono,
    ).apply(bodyColor: black, displayColor: black),
    dividerTheme: const DividerThemeData(color: borderLight),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
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
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundDark,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      surface: backgroundDark,
      onPrimary: backgroundDark,
      onSurface: Colors.white,
      outline: borderDark,
      onSurfaceVariant: dimmed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Syne',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: -0.3,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      displayLarge: headingXL,
      displayMedium: headingL,
      displaySmall: headingM,
      bodyLarge: bodyMono,
      bodyMedium: bodyMono,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    dividerTheme: const DividerThemeData(color: borderDark),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: backgroundDark,
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
  );
}
