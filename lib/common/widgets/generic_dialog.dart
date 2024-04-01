import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DialogActions {
  yesNo,
  addCancel,
  close,
  none,
}

class GenericDialog extends StatelessWidget {
  final String title;
  final List<Widget> content;
  final List<Widget>? actions;

  const GenericDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  static Future<bool> callDialog(
    BuildContext context, {
    required String title,
    required String message,
    DialogActions actions = DialogActions.none,
  }) async {
    final locale = AppLocalizations.of(context)!;

    List<Widget> listActions = [];

    switch (actions) {
      case DialogActions.yesNo:
        listActions.add(
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(locale.genericYes),
          ),
        );
        listActions.add(
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(locale.genericNo),
          ),
        );
        break;
      case DialogActions.addCancel:
        listActions.add(
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(locale.genericAdd),
          ),
        );
        listActions.add(
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(locale.genericCancel),
          ),
        );
        break;
      case DialogActions.close:
        listActions.add(
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(locale.genericClose),
          ),
        );
        break;
      case DialogActions.none:
        break;
    }

    bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => GenericDialog(
            title: title,
            content: [
              Text(message),
            ],
            actions: listActions.isEmpty ? null : listActions,
          ),
        ) ??
        false;

    return result;
  }

  @override
  Widget build(BuildContext context) {
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
      actions: actions,
    );
  }
}
