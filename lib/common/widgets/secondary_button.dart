import 'package:flutter/material.dart';

import '../constants/themes/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final void Function()? onTap;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color primary = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: label,
                child: Text(
                  label,
                  style: AppTextStyles.textStyleSemiBold18.copyWith(
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
