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
