import 'package:finances/features/budget/budget_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_icons.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/models/icons_model.dart';
import '../../../common/widgets/add_cancel_buttons.dart';
import '../../../locator.dart';
import 'category_text_form_field.dart';
import 'select_icon_row.dart';

class AddBudgetDialog extends StatefulWidget {
  final bool addCategory;
  final CategoryDbModel? editCategory;
  final Function? callBack;

  const AddBudgetDialog({
    Key? key,
    this.addCategory = true,
    this.editCategory,
    this.callBack,
  }) : super(key: key);

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final categoryController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  late IconModel iconModel;
  int? categoryId;

  @override
  void initState() {
    super.initState();

    if (widget.editCategory != null) {
      categoryController.text = widget.editCategory!.categoryName;
      categoryId = widget.editCategory!.categoryId;
      iconModel = widget.editCategory!.categoryIcon;
    } else {
      categoryController.text = '';
      iconModel = IconModel(
        iconName: 'attach money',
        iconFontFamily: IconsFontFamily.MaterialIcons,
        iconColor: 0xFF14A01B,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    categoryController.dispose();
    if (widget.callBack != null) widget.callBack!();
  }

  void cancelCallback(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> addCallback() async {
    CategoryDbModel newCategory = CategoryDbModel(
      categoryId: categoryId,
      categoryIcon: iconModel,
      categoryName: categoryController.text,
    );
    final locale = AppLocalizations.of(context)!;
    final controller = locator.get<BudgetController>();

    if (categoryId != null) {
      await controller.updateCategory(newCategory);
      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      List<String> categoriesNames = controller.categoryNames;

      if (!categoriesNames.contains(newCategory.categoryName)) {
        await controller.addCategory(newCategory);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        final customColors = Theme.of(context).extension<CustomColors>()!;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(locale.addCategoryDialogCategoryName),
            icon: Icon(
              Icons.warning,
              size: 32,
              color: customColors.sourceLightyellow,
            ),
            content: Text(locale.addCategoryDialogThisCategoryExists),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return SimpleDialog(
      title: Text(
        widget.addCategory
            ? locale.addCategoryDialogNewCategory
            : locale.addCategoryDialogEditCategory,
        style: AppTextStyles.textStyleSemiBold18.copyWith(
          color: primary,
        ),
      ),
      children: [
        Form(
          key: formKey,
          child: CategoryTextFormField(
            controller: categoryController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.addCategoryDialogCannotEmpty;
              }
              return null;
            },
          ),
        ),
        SelectIconRow(
          iconModel: iconModel,
          iconCallback: (IconModel newIcon) {
            setState(() {
              iconModel.iconName = newIcon.iconName;
              iconModel.iconFontFamily = newIcon.iconFontFamily;
            });
          },
        ),
        AddCancelButtons(
          addLabel: widget.addCategory
              ? locale.addCategoryDialogAdd
              : locale.addCategoryDialogUpdate,
          addIcon: widget.addCategory ? Icons.add : Icons.update,
          addCallback: () async {
            if (formKey.currentState != null &&
                formKey.currentState!.validate()) {
              await addCallback();
            }
          },
          cancelCallback: () => cancelCallback(context),
        ),
      ],
    );
  }
}
