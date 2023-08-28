import 'package:flutter/material.dart';

import '../constants/themes/app_text_styles.dart';
import './secondary_button.dart';

Future<dynamic> customModelBottomSheet(
  BuildContext context, {
  required String content,
  required String buttonText,
  String? secondMessage,
  Widget? secondWidget,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (context) => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: AppTextStyles.textStyleSemiBold18.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SecondaryButton(
              onTap: () => Navigator.pop(context),
              label: buttonText,
            ),
            if (secondMessage != null) const SizedBox(height: 16),
            if (secondMessage != null)
              Text(
                secondMessage,
                style: AppTextStyles.textStyleSemiBold16.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (secondWidget != null) secondWidget,
          ],
        ),
      ),
    ),
  );
}
