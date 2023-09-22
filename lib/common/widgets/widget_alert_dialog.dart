import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/app_button_styles.dart';

class WidgetAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  const WidgetAlertDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final buttonStyle = AppButtonStyles.primaryButtonColor(context);

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        height: 82,
        child: Column(
          children: [
            Text(content),
            const SizedBox(height: 12),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(locale.widgetAlertDialogClose),
            ),
          ],
        ),
      ),
    );
  }
}
