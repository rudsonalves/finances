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
    final buttonStyle = AppButtonStyles.primaryButtonColor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: addCallback,
          style: buttonStyle,
          child: Text(
            addLabel != null ? addLabel! : locale.addCancelButtonsAdd,
          ),
        ),
        ElevatedButton(
          onPressed: cancelCallback,
          style: buttonStyle,
          child: Text(
            locale.addCancelButtonsCancel,
          ),
        ),
      ],
    );
  }
}
