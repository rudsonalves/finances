import 'package:flutter/material.dart';

import '../constants/themes/app_text_styles.dart';

class LargeBoldText extends StatelessWidget {
  final String text;

  const LargeBoldText(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.textStyleBold32.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
