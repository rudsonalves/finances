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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/current_models/current_user.dart';
import '../../../locator.dart';
import '../../../repositories/category/abstract_category_repository.dart';
import '../../../repositories/icons/abstract_icons_repository.dart';

class OfxStopCategories extends StatefulWidget {
  final List<int> userOfxStopCategories;
  const OfxStopCategories({
    super.key,
    required this.userOfxStopCategories,
  });

  static Future<List<int>> showOfxStopCategoriesDialog(
      BuildContext context) async {
    final primary = Theme.of(context).colorScheme.primary;
    final userOfxStopCategories = locator<CurrentUser>().userOfxStopCategories;
    final locale = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                locale.ofxStopCategoryTitle,
                style: AppTextStyles.textStyleBold16.copyWith(
                  color: primary,
                ),
              ),
            ),
            SizedBox(
              height: 400,
              child: OfxStopCategories(
                userOfxStopCategories: userOfxStopCategories,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(locale.genericClose),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return userOfxStopCategories;
  }

  @override
  State<OfxStopCategories> createState() => _OfxStopCategoriesState();
}

class _OfxStopCategoriesState extends State<OfxStopCategories> {
  final categories = locator<AbstractCategoryRepository>().categories;
  final iconRepository = locator<AbstractIconRepository>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: widget.userOfxStopCategories
                .contains(categories[index].categoryId!),
            onChanged: (value) {
              setState(() {
                if (value != null && value) {
                  widget.userOfxStopCategories
                      .add(categories[index].categoryId!);
                } else {
                  widget.userOfxStopCategories
                      .remove(categories[index].categoryId!);
                }
              });
            },
          ),
          Flexible(
            child: ListTile(
              leading: categories[index].categoryIcon.iconWidget(),
              title: Text(categories[index].categoryName),
            ),
          ),
        ],
      ),
    );
  }
}
