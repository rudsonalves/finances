import 'package:flutter/material.dart';

class CurrentTheme {
  ValueNotifier<ThemeMode> themeMode$ = ValueNotifier(ThemeMode.system);

  ThemeMode get themeMode => themeMode$.value;

  void setThemeMode(ThemeMode theme) {
    themeMode$.value = theme;
  }

  void setThemeFromThemeName(String themeName) {
    if (themeName == 'system') {
      themeMode$.value = ThemeMode.system;
    } else if (themeName == 'dark') {
      themeMode$.value = ThemeMode.dark;
    } else {
      themeMode$.value = ThemeMode.light;
    }
  }

  String get themeName => themeMode$.value.name;
}
