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

import '../../locator.dart';
import '../constants/themes/app_text_styles.dart';
import '../constants/themes/colors/custom_color.g.dart';
import '../extensions/money_masked_text.dart';

Widget incomeExpanseShowValue(
  BuildContext context, {
  required String text,
  required double value,
  required IconData icon,
}) {
  final MoneyMaskedText money = locator<MoneyMaskedText>();

  final colorScheme = Theme.of(context).colorScheme;
  final customColors = Theme.of(context).extension<CustomColors>()!;

  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 4),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: customColors.sourceMediumprimary,
          child: Icon(
            icon,
            color: colorScheme.onPrimary,
            size: 16,
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTextStyles.textStyleMedium14.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
          Text(
            money.text(value),
            style: AppTextStyles.textStyleSemiBold16.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    ],
  );
}
