import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primary = colorScheme.primary;
    final Color onPrimary = colorScheme.onPrimary;
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        height: 82,
        child: Column(
          children: [
            Text(content),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(primary),
                foregroundColor: MaterialStateProperty.all(onPrimary),
              ),
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
