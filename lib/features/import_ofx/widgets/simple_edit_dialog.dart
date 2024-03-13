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
