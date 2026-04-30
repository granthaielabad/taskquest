import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class TextScaleNotifier extends Notifier<double> {
  @override
  double build() => 1.0;

  void setTextScale(double scale) {
    state = scale;
  }
}

final textScaleProvider = NotifierProvider<TextScaleNotifier, double>(() {
  return TextScaleNotifier();
});

class ReduceMotionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setReduceMotion(bool value) {
    state = value;
  }
}

final reduceMotionProvider = NotifierProvider<ReduceMotionNotifier, bool>(() {
  return ReduceMotionNotifier();
});

class FontStyleNotifier extends Notifier<String> {
  @override
  String build() => 'Syne / DM Mono';

  void setFontStyle(String style) {
    state = style;
  }
}

final fontStyleProvider = NotifierProvider<FontStyleNotifier, String>(() {
  return FontStyleNotifier();
});

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

enum ThemePreset { taskQuest, dracula, monokai, cyberpunk }

class ThemePresetNotifier extends Notifier<ThemePreset> {
  @override
  ThemePreset build() => ThemePreset.taskQuest;

  void setPreset(ThemePreset preset) {
    state = preset;
  }
}

final themePresetProvider = NotifierProvider<ThemePresetNotifier, ThemePreset>(
  () {
    return ThemePresetNotifier();
  },
);

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  () {
    return NavigationIndexNotifier();
  },
);
