// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/app_button_styles.dart';
import '../constants/themes/app_text_styles.dart';
import '../widgets/markdown_rich_text.dart';

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
  final buttonStyle = AppButtonStyles.primaryButtonColor(context);

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
      content: MarkdownRichText.richText(
        content,
        color: primary,
      ),
      actions: [
        ElevatedButton(
          style: buttonStyle,
          onPressed: () => Navigator.pop(context),
          child: Text(
            locale.genericClose,
            style: TextStyle(color: onPrimary),
          ),
        ),
      ],
    ),
  );
}
