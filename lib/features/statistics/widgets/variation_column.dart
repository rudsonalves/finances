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

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/constants/themes/icons/fontello_icons.dart';

class VariationColumn extends StatelessWidget {
  final double? value;

  const VariationColumn(
    this.value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    IconData icon;
    Color color;

    if (value != null) {
      if (value! > 0) {
        icon = FontelloIcons.up;
        color = customColors.lowgreen!;
      } else if (value! < 0) {
        icon = FontelloIcons.down;
        color = customColors.minusred!;
      } else {
        icon = Icons.horizontal_rule;
        color = colorScheme.primary;
      }
    } else {
      icon = Icons.report_gmailerrorred;
      color = colorScheme.primary;
    }

    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        Text(
          value != null ? '${value!.toStringAsFixed(0)}%' : '∞',
          style: AppTextStyles.textStyleBold10.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
