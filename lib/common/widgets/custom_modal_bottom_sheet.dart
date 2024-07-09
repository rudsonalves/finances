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

import '../constants/themes/app_text_styles.dart';

Future<dynamic> customModelBottomSheet(
  BuildContext context, {
  required String content,
  required Widget buttonText,
  String? secondMessage,
  Widget? secondWidget,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (context) => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              textAlign: TextAlign.center,
              style: AppTextStyles.textStyleSemiBold16.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            buttonText,
            if (secondMessage != null) const SizedBox(height: 16),
            if (secondMessage != null)
              Text(
                secondMessage,
                style: AppTextStyles.textStyleSemiBold16.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (secondWidget != null) secondWidget,
          ],
        ),
      ),
    ),
  );
}
