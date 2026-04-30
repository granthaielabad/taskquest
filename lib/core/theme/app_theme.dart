import 'package:flutter/material.dart';
import 'package:taskquest/core/providers/theme_provider.dart';

class AppTheme {
  // ── Theme Seeds ───────────────────────────────────────────────
  static const Color seedDefault = Color(0xFF111111);

  // ── Base Colors ──────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF7F6F2);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color borderLight = Color(0xFFDCDAD1);
  static const Color borderDark = Color(0xFF222222);
  static const Color muted = Color(0xFF666666);
  static const Color dimmed = Color(0xFFCCCAC4);

  // ── Dracula (VS Code) ─────────────────────────────────────────
  static const Color draculaBg = Color(0xFF282A36);
  static const Color draculaSurface = Color(
    0xFF363948,
  ); // Slightly lighter than BG
  static const Color draculaPrimary = Color(0xFFBD93F9);
  static const Color draculaAccent = Color(0xFFFF79C6);
  static const Color draculaBorder = Color(0xFF44475A);

  // ── Monokai (VS Code) ─────────────────────────────────────────
  static const Color monokaiBg = Color(0xFF272822);
  static const Color monokaiSurface = Color(0xFF32332B);
  static const Color monokaiPrimary = Color(0xFFF92672);
  static const Color monokaiAccent = Color(0xFFA6E22E);
  static const Color monokaiBorder = Color(0xFF49483E);

  // ── Cyberpunk ────────────────────────────────────────────────
  static const Color cyberpunkBg = Color(0xFF030E1B);
  static const Color cyberpunkSurface = Color(0xFF0E2439);
  static const Color cyberpunkPrimary = Color(0xFF00FF9F);
  static const Color cyberpunkAccent = Color(0xFFFF0055);
  static const Color cyberpunkBorder = Color(0xFF00B8FF);

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
    String fontStyle = 'Syne / DM Mono',
    ThemePreset preset = ThemePreset.taskQuest,
  }) {
    final isDark = brightness == Brightness.dark;
    final bool isDarkPreset = preset != ThemePreset.taskQuest;

    // Choose font families based on selected style
    final String headingFont = fontStyle == 'Syne / DM Mono'
        ? 'Syne'
        : fontStyle == 'System Default'
        ? 'Roboto'
        : 'Georgia';
    final String bodyFont = fontStyle == 'Syne / DM Mono'
        ? 'DM Mono'
        : fontStyle == 'System Default'
        ? 'Roboto'
        : 'Georgia';

    final TextStyle hXL = headingXL.copyWith(fontFamily: headingFont);
    final TextStyle hL = headingL.copyWith(fontFamily: headingFont);
    final TextStyle hM = headingM.copyWith(fontFamily: headingFont);
    final TextStyle bM = bodyMono.copyWith(fontFamily: bodyFont);
    final TextStyle lM = labelMono.copyWith(fontFamily: bodyFont);

    // Determine colors based on preset
    Color primaryColor = isDark ? white : black;
    Color surfaceColor = isDark ? backgroundDark : backgroundLight;
    Color bgColor = isDark ? backgroundDark : backgroundLight;
    Color borderColor = isDark ? borderDark : borderLight;
    Color onSurfaceColor = isDark ? white : black;

    if (preset == ThemePreset.dracula) {
      primaryColor = draculaPrimary;
      surfaceColor = draculaSurface;
      bgColor = draculaBg;
      borderColor = draculaBorder;
      onSurfaceColor = white;
    } else if (preset == ThemePreset.monokai) {
      primaryColor = monokaiPrimary;
      surfaceColor = monokaiSurface;
      bgColor = monokaiBg;
      borderColor = monokaiBorder;
      onSurfaceColor = white;
    } else if (preset == ThemePreset.cyberpunk) {
      primaryColor = cyberpunkPrimary;
      surfaceColor = cyberpunkSurface;
      bgColor = cyberpunkBg;
      borderColor = cyberpunkBorder;
      onSurfaceColor = white;
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: (isDark || isDarkPreset) ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: (preset == ThemePreset.taskQuest)
          ? (isDark ? black : white)
          : white,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      onSurfaceVariant: isDarkPreset
          ? onSurfaceColor.withValues(alpha: 0.7)
          : (isDark ? onSurfaceColor.withValues(alpha: 0.6) : black),
      outline: borderColor,
      surfaceContainerHighest: (isDark || isDarkPreset)
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFE8E7E0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: (isDark || isDarkPreset) ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,

      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: hM.copyWith(color: onSurfaceColor),
        iconTheme: IconThemeData(color: onSurfaceColor),
      ),

      textTheme: TextTheme(
        displayLarge: hXL.copyWith(color: onSurfaceColor),
        displayMedium: hL.copyWith(color: onSurfaceColor),
        displaySmall: hM.copyWith(color: onSurfaceColor),
        bodyLarge: bM.copyWith(color: onSurfaceColor),
        bodyMedium: bM.copyWith(color: onSurfaceColor),
        labelSmall: lM.copyWith(
          color: (isDark || isDarkPreset) ? dimmed : muted,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: (preset == ThemePreset.taskQuest && !isDark)
              ? white
              : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          textStyle: TextStyle(
            fontFamily: headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: (isDark || isDarkPreset)
            ? const Color(0xFF1A1A1A)
            : white,
        labelStyle: bM.copyWith(fontSize: 11, color: onSurfaceColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
      ),
    );
  }

  // ── Backward Compatibility ────────────────────────────────────
  static ThemeData get lightTheme => createTheme(brightness: Brightness.light);
  static ThemeData get darkTheme => createTheme(brightness: Brightness.dark);
}
