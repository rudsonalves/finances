import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/widgets/markdown_text.dart';
import '../../../locator.dart';
import '../budget_controller.dart';
import '../../../common/functions/base_dismissible_container.dart';
import 'add_budget_dialog.dart';

class DismissibleBudget extends StatefulWidget {
  final BudgetController controller;
  final int index;
  final Function? callBack;

  const DismissibleBudget({
    super.key,
    required this.controller,
    required this.index,
    this.callBack,
  });

  @override
  State<DismissibleBudget> createState() => _DismissibleBudgetState();
}

class _DismissibleBudgetState extends State<DismissibleBudget> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<bool?> removeCategoryDialog(
    BuildContext context,
    String categoryName,
  ) async {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale.dismissibleCategoryConfirm),
        content: Text(
          locale.dismissibleCategorySureDeleteCategory(categoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(locale.dismissibleCategoryDelete),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(locale.dismissibleCategoryCancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final locale = AppLocalizations.of(context)!;
    final money = locator.get<MoneyMaskedText>();

    final category = widget.controller.categories[widget.index];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Dismissible(
        key: UniqueKey(),
        background: baseDismissibleContainer(
          context,
          alignment: Alignment.centerLeft,
          color: customColors.lightgreenContainer!,
          icon: Icons.edit,
          label: locale.dismissibleCategoryEdit,
        ),
        secondaryBackground: baseDismissibleContainer(
          context,
          alignment: Alignment.centerRight,
          color: colorScheme.errorContainer,
          icon: Icons.delete,
          label: locale.dismissibleCategoryDelete,
        ),
        child: Card(
          elevation: 0,
          color: colorScheme.onPrimary,
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: category.categoryIcon.iconWidget(size: 32),
            title: Text(
              category.categoryName,
            ),
            trailing: Text(
              money.text(category.categoryBudget),
              style: AppTextStyles.textStyleBold18,
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Edit direction
            await showDialog(
              context: context,
              builder: (context) => AddBudgetDialog(
                addCategory: false,
                editCategory: category,
                callBack: widget.callBack,
              ),
            );
            return false;
          }
          if (direction == DismissDirection.endToStart) {
            // Delete direction
            if (category.categoryId == 1) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(locale.dismissibleCategoryReservedCategory),
                  content: MarkdownText.richText(
                    locale.dismissibleCategoryCategoryIsReserved(
                      category.categoryName,
                    ),
                    normalStyle: AppTextStyles.textStyle14,
                    boldStyle: AppTextStyles.textStyleBold14,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  actions: [
                    TextButton(
                      child: Text(locale.genericClose),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
              return false;
            }

            if (!mounted) return false;
            bool? result = await removeCategoryDialog(
              context,
              category.categoryName,
            );

            if (result == true) {
              await widget.controller.removeCategory(category);
              if (widget.callBack != null) widget.callBack!();
              return true;
            }
            return false;
          }
          return false;
        },
      ),
    );
  }
}
