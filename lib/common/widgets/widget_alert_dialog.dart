import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> singleMessageAlertDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  await showDialog(
    context: context,
    builder: (context) => WidgetAlertDialog(
      title: title,
      content: [
        Text(message),
      ],
    ),
  );
}

class WidgetAlertDialog extends StatelessWidget {
  final String title;
  final List<Widget> content;
  final List<Widget>? actions;

  const WidgetAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(color: primary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...content,
        ],
      ),
      actions: actions ??
          [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(locale.genericClose),
            ),
          ],
    );
  }
}
