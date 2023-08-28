import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> functionAlertDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  final locale = AppLocalizations.of(context)!;

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(content),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(locale.genericClose),
            ),
          ],
        ),
      ),
    ),
  );
}
