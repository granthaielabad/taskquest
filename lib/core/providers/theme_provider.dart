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
