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

import '../constants/themes/app_text_styles.dart';

class CustomTextButton extends StatelessWidget {
  final String labelMessage;
  final String labelButton;
  final void Function()? onPressed;

  const CustomTextButton({
    super.key,
    required this.labelMessage,
    required this.labelButton,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color primary = colorScheme.primary;
    Color outline = colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          // minimumSize: const Size(14, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelMessage,
              style: AppTextStyles.textStyleSemiBold14.copyWith(
                color: outline,
              ),
            ),
            Text(
              ' $labelButton',
              style: AppTextStyles.textStyleSemiBold16.copyWith(
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
