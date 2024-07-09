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

import '../../../common/constants/themes/app_button_styles.dart';
import '../../../common/widgets/basic_text_form_field.dart';

Future<String> simpleEditDialog(
  BuildContext context, {
  required String title,
  required String labelText,
  required String actionButtonText,
  required String cancelButtonText,
}) async {
  final buttonStyle = AppButtonStyles.primaryButtonColor(context);
  final controller = TextEditingController(text: labelText);

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: BasicTextFormField(
        controller: controller,
        labelText: controller.text,
      ),
      actions: [
        ElevatedButton(
          style: buttonStyle,
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(actionButtonText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, labelText),
          style: buttonStyle,
          child: Text(cancelButtonText),
        ),
      ],
    ),
  );
}
