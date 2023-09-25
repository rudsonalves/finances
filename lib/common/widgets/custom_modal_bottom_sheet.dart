import 'package:flutter/material.dart';

import '../constants/themes/app_text_styles.dart';

Future<dynamic> customModelBottomSheet(
  BuildContext context, {
  required String content,
  required Widget buttonText,
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
              textAlign: TextAlign.center,
              style: AppTextStyles.textStyleSemiBold16.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            buttonText,
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
