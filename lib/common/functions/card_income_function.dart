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
  MoneyMaskedText money = locator.get<MoneyMaskedText>();

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
