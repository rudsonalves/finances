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

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/current_models/current_user.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../locator.dart';
import '../../../repositories/category/abstract_category_repository.dart';
import '../models/statistic_result.dart';
import '../statistic_card/statistic_card_controller.dart';
import 'variation_column.dart';

class ListTileStatistic extends StatefulWidget {
  final StatisticResult category;

  const ListTileStatistic(
    this.category, {
    super.key,
  });

  @override
  State<ListTileStatistic> createState() => _ListTileStatisticState();
}

class _ListTileStatisticState extends State<ListTileStatistic> {
  final currentUser = locator<CurrentUser>();
  final categoryRepository = locator<AbstractCategoryRepository>();
  final controller = locator<StatisticCardController>();

  void setGraphic(String categoryName) async {
    if (currentUser.userCategoryList.contains(categoryName)) {
      await controller.removeFromCategoryList(categoryName);
    } else {
      await controller.addToCategoryList(categoryName);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.category.categoryName;
    final icon = categoryRepository.categoriesMap[categoryName]!.categoryIcon
        .iconWidget();
    final money = locator<MoneyMaskedText>();
    final minus = widget.category.monthSum < 0;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Card(
      elevation: currentUser.userCategoryList.contains(categoryName) ? 1 : 0,
      child: ListTile(
        leading: icon,
        title: Row(
          children: [
            Text(categoryName),
            const Spacer(),
            Text(
              money.text(widget.category.monthSum),
              style: AppTextStyles.textStyleSemiBold16.copyWith(
                  color: minus ? customColors.minusred : customColors.lowgreen,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            VariationColumn(widget.category.variation),
          ],
        ),
        onTap: () => setGraphic(categoryName),
      ),
    );
  }
}
