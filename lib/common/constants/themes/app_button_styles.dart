import 'package:flutter/material.dart';

class AppButtonStyles {
  AppButtonStyles._();

  static primaryButtonColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;

    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all(primary),
        foregroundColor: MaterialStateProperty.all(onPrimary));
  }
}
