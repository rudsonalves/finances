import 'package:flutter/material.dart';

import '../constants/themes/app_text_styles.dart';

class LargeButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;

  const LargeButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color primary = colorScheme.primary;
    Color onPrimary = colorScheme.onPrimary;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(350, 60),
        elevation: 5,
        visualDensity: const VisualDensity(
          vertical: 0.5,
          horizontal: 0.5,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTextStyles.textStyleSemiBold18,
      ),
    );
  }
}
