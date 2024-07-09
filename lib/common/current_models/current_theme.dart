// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

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
