import 'package:flutter/material.dart';

import '../constants/themes/app_text_styles.dart';

class CustomTextButton extends StatelessWidget {
  final String labelMessage;
  final String labelButton;
  final void Function()? onPressed;

  const CustomTextButton({
    super.key,
    required this.labelMessage,
    required this.labelButton,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color primary = colorScheme.primary;
    Color outline = colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0),
            minimumSize: const Size(14, 14),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerLeft),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelMessage,
              style: AppTextStyles.textStyle14.copyWith(
                color: outline,
              ),
            ),
            Text(
              ' $labelButton',
              style: AppTextStyles.textStyle14.copyWith(
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
