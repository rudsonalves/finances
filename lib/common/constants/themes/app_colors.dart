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

import 'colors/custom_color.g.dart';

class AppColors {
  AppColors._();

  static List<Color> getColorsGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return [
      colorScheme.primary,
      customColors.sourceSubprimary!,
    ];
  }

  static List<Color> getMediumColorsGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return [
      customColors.sourceMediumprimary!,
      colorScheme.onPrimary.withAlpha(155),
      //Colors.transparent,
      //customColors.sourceSubprimary!,
    ];
  }

  static List<Color> getGrayGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      colorScheme.secondary,
      colorScheme.outline,
    ];
  }
}
