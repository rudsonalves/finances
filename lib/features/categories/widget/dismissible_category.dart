import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_button_styles.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/functions/function_alert_dialog.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/widgets/markdown_rich_text.dart';
import '../../../locator.dart';
import '../../../services/database/database_helper.dart';
import '../categories_controller.dart';
import '../../../common/functions/base_dismissible_container.dart';
import 'add_category_page.dart';

class DismissibleCategory extends StatefulWidget {
  final CategoriesController controller;
  final int index;
  final Function? callBack;
  final void Function(CategoryDbModel)? budgetEdit;

  const DismissibleCategory({
    super.key,
    required this.controller,
    required this.index,
    this.callBack,
    this.budgetEdit,
  });

  @override
  State<DismissibleCategory> createState() => _DismissibleCategoryState();
}

class _DismissibleCategoryState extends State<DismissibleCategory> {
  Future<bool?> removeCategoryDialog(
    BuildContext context,
    String categoryName,
  ) async {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final buttonStyle = AppButtonStyles.primaryButtonColor(context);

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale.dismissibleCategoryConfirm),
        content: Text(
          locale.dismissibleCategorySureDeleteCategory(categoryName),
        ),
        actions: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              locale.dismissibleCategoryDelete,
              style: TextStyle(color: onPrimary),
            ),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              locale.dismissibleCategoryCancel,
              style: TextStyle(color: onPrimary),
            ),
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
    final money = locator<MoneyMaskedText>();

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
          elevation: .5,
          color: colorScheme.onPrimary,
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: category.categoryIcon.iconWidget(size: 32),
            title: Text(
              category.categoryName,
            ),
            trailing: Text(
              money.text(category.categoryBudget),
              style: AppTextStyles.textStyleBold18.copyWith(
                color: category.categoryBudget < 0
                    ? customColors.minusred
                    : colorScheme.primary,
              ),
            ),
            onTap: () {
              if (widget.budgetEdit != null) {
                widget.budgetEdit!(category);
              }
            },
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Edit direction
            await showDialog(
              context: context,
              builder: (context) => AddCategoryPage(
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
                  content: MarkdownRichText.richText(
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

            final int categoryCount = await locator
                .get<DatabaseHelper>()
                .countTransactionForCategoryId(category.categoryId!);

            if (categoryCount > 0) {
              if (!mounted) return false;
              await functionAlertDialog(
                context,
                title: locale.genericAttention,
                content: locale.budgetPageDeleteAlert(
                  categoryCount,
                  category.categoryName,
                ),
                icon: Icons.warning,
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
