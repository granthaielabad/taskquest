import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors (from your Figma) ──────────────────────────
  static const Color background = Color(0xFFF7F6F2);  // warm parchment
  static const Color black = Color(0xFF111111);
  static const Color border = Color(0xFFE2E1DC);
  static const Color muted = Color(0xFF777777);
  static const Color dimmed = Color(0xFFCCCAC4);
  static const Color white = Color(0xFFFFFFFF);

  // ── Text Styles ──────────────────────────────────────────────
  static const TextStyle headingXL = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 28,
    letterSpacing: -0.84,
    color: black,
  );

  static const TextStyle headingL = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 22,
    letterSpacing: -0.5,
    color: black,
  );

  static const TextStyle headingM = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    letterSpacing: -0.3,
    color: black,
  );

  static const TextStyle labelMono = TextStyle(
    fontFamily: 'DM Mono',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    letterSpacing: 1.4,
    color: muted,
  );

  static const TextStyle bodyMono = TextStyle(
    fontFamily: 'DM Mono',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: muted,
  );

  // ── Theme ────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: black,
      surface: background,
      onPrimary: white,
      outline: border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      titleTextStyle: headingM,
    ),
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
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      surface: Color(0xFF0A0A0A),
      onPrimary: Color(0xFF0A0A0A),
      outline: Color(0xFF222222),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0A0A),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Syne',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: -0.3,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0A0A0A),
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