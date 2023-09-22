import 'package:flutter/material.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final void Function()? onTap;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color onPrimary = colorScheme.onPrimary;
    Color outline = colorScheme.outline;

    double height = 58;
    // double width = 350;
    BorderRadius borderRadiusCircular = BorderRadius.circular(height / 2);

    BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: borderRadiusCircular,
      gradient: LinearGradient(
        colors: onTap != null
            ? AppColors.getColorsGradient(context)
            : AppColors.getGrayGradient(context),
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: [
        BoxShadow(
          color: outline,
          offset: const Offset(1, 3),
          blurRadius: 3,
          spreadRadius: 0.3,
        ),
      ],
    );

    return Material(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 5,
          left: 26,
          right: 26,
        ),
        child: Ink(
          height: height,
          // width: width,
          decoration: boxDecoration,
          child: InkWell(
            borderRadius: borderRadiusCircular,
            onTap: onTap,
            child: Center(
              child: Semantics(
                label: label,
                child: Text(
                  label,
                  style: AppTextStyles.textStyleSemiBold18.copyWith(
                    color: onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
