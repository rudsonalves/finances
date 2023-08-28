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
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return [
      customColors.sourceMediumprimary!,
      customColors.sourceSubprimary!,
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
