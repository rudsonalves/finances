import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/app_text_styles.dart';
import '../widgets/markdown_text.dart';

Future<void> functionAlertDialog(
  BuildContext context, {
  required String title,
  required String content,
  IconData? icon,
}) async {
  final locale = AppLocalizations.of(context)!;
  final colorScheme = Theme.of(context).colorScheme;
  final primary = colorScheme.primary;
  final onPrimary = colorScheme.onPrimary;

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: icon != null
          ? Icon(
              icon,
              color: primary,
              size: 32,
            )
          : null,
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      titleTextStyle: AppTextStyles.textStyleBold24.copyWith(
        color: primary,
      ),
      content: MarkdownText.richText(
        content,
        color: primary,
      ),
      actions: [
        ElevatedButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(primary),
          ),
          onPressed: () => Navigator.pop(context),
          label: Text(
            locale.genericClose,
            style: TextStyle(color: onPrimary),
          ),
          icon: Icon(
            Icons.close,
            color: onPrimary,
          ),
        ),
      ],
    ),
  );

  // return await showDialog(
  //   context: context,
  //   builder: (context) => AlertDialog(
  //     title: Text(
  //       title,
  //       textAlign: TextAlign.center,
  //     ),
  //     content: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           Text(content),
  //           const SizedBox(height: 12),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text(locale.genericClose),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );
}
