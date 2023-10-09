import 'package:flutter/material.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/current_models/current_user.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../locator.dart';
import '../../../repositories/category/category_repository.dart';
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
  final currentUser = locator.get<CurrentUser>();
  final categoryRepository = locator.get<CategoryRepository>();
  final controller = locator.get<StatisticCardController>();

  void setGraphic(String categoryName) async {
    if (currentUser.userCategoryList.contains(categoryName)) {
      await controller.removeFromCategoryList(categoryName);
    } else {
      await controller.addToCategoryList(categoryName);
    }

    setState(() {});
    // locator.get<StatisticCardController>().getGraphicDataPoints();
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.category.categoryName;
    final icon = categoryRepository.categoriesMap[categoryName]!.categoryIcon
        .iconWidget();
    final money = locator.get<MoneyMaskedText>();
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
              style: AppTextStyles.textStyleSemiBold18.copyWith(
                  color: minus ? customColors.minusred : customColors.lowgreen,
                  fontWeight: FontWeight.w700),
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
