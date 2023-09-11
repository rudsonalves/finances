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
        ElevatedButton(
          onPressed: addCallback,
          style: AppButtonStyles.primaryButtonColor(context),
          child: Text(
            addLabel != null ? addLabel! : locale.addCancelButtonsAdd,
          ),
          // icon: Icon(addIcon != null ? addIcon! : Icons.add),
        ),
        ElevatedButton(
          onPressed: cancelCallback,
          style: AppButtonStyles.primaryButtonColor(context),
          child: Text(
            locale.addCancelButtonsCancel,
          ),
          // icon: const Icon(Icons.cancel),
        ),
      ],
    );
  }
}
