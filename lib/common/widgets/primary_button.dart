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
    );
  }
}
