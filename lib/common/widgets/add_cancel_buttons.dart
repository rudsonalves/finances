import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/app_button_styles.dart';

class AddCancelButtons extends StatelessWidget {
  final String? addLabel;
  final IconData? addIcon;
  final void Function() addCallback;
  final void Function() cancelCallback;

  const AddCancelButtons({
    super.key,
    this.addLabel,
    this.addIcon,
    required this.addCallback,
    required this.cancelCallback,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          label: Text(
            addLabel != null ? addLabel! : locale.addCancelButtonsAdd,
          ),
          onPressed: addCallback,
          style: AppButtonStyles.primaryButtonColor(context),
          icon: Icon(addIcon != null ? addIcon! : Icons.add),
        ),
        ElevatedButton.icon(
          label: Text(
            locale.addCancelButtonsCancel,
          ),
          onPressed: cancelCallback,
          style: AppButtonStyles.primaryButtonColor(context),
          icon: const Icon(Icons.cancel),
        ),
      ],
    );
  }
}
