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

import '../constants/themes/colors/app_colors.dart';

Container baseDismissibleContainer(
  BuildContext context, {
  required AlignmentGeometry alignment,
  required Color color,
  required IconData icon,
  String? label,
  bool enable = true,
}) {
  List<Alignment> alignLeft = [
    Alignment.bottomLeft,
    Alignment.topLeft,
    Alignment.centerLeft
  ];

  final colorScheme = Theme.of(context).colorScheme;
  late Widget rowIcon;

  Color enableColor = colorScheme.shadow;
  Color disableColor = AppColors.unselectedText;

  if (label != null) {
    if (alignLeft.contains(alignment)) {
      rowIcon = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: enable ? enableColor : disableColor,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: enable ? enableColor : disableColor,
            ),
          ),
        ],
      );
    } else {
      rowIcon = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: enable ? enableColor : disableColor,
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            icon,
            color: enable ? enableColor : disableColor,
          ),
        ],
      );
    }
  } else {
    rowIcon = Icon(icon);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    alignment: alignment,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: rowIcon,
  );
}
