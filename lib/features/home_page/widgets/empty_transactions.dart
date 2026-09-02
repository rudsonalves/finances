import 'package:finances/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/themes/app_text_styles.dart';

class EmptyTransactions extends StatelessWidget {
  final Color color;

  const EmptyTransactions({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_trasactions.png',
            width: 100,
            height: 100,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: 12),
          Text(
            locale.homePageNoTransactions,
            style: AppTextStyles.textStyleMedium14.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
