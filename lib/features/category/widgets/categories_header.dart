import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';

class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primary = colorScheme.primary;
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 12),
        Icon(Icons.delete, color: primary),
        const Spacer(),
        Icon(
          Icons.arrow_back,
          color: primary,
        ),
        const Spacer(),
        Text(
          locale.categoriesHeaderTitle,
          style: AppTextStyles.textStyleSemiBold18.copyWith(
            color: primary,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward,
          color: primary,
        ),
        const Spacer(),
        Icon(Icons.edit, color: primary),
        const SizedBox(width: 12),
      ],
    );
  }
}
