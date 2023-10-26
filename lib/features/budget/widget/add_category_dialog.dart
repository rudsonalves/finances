import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_icons.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/models/icons_model.dart';
import '../../../common/widgets/add_cancel_buttons.dart';
import '../../../common/widgets/row_of_two_bottons.dart';
import '../../../locator.dart';
import '../budget_controller.dart';
import 'category_text_form_field.dart';
import 'select_icon_row.dart';

class AddCategoryDialog extends StatefulWidget {
  final bool addCategory;
  final CategoryDbModel? editCategory;
  final Function? callBack;

  const AddCategoryDialog({
    Key? key,
    this.addCategory = true,
    this.editCategory,
    this.callBack,
  }) : super(key: key);

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _categoryController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  bool _categoryIsIncome = false;

  late IconModel _iconModel;
  int? _categoryId;

  @override
  void initState() {
    super.initState();

    if (widget.editCategory != null) {
      _categoryController.text = widget.editCategory!.categoryName;
      _categoryId = widget.editCategory!.categoryId;
      _iconModel = widget.editCategory!.categoryIcon;
      _categoryIsIncome = widget.editCategory!.categoryIsIncome;
    } else {
      _categoryController.text = '';
      _iconModel = IconModel(
        iconName: 'attach money',
        iconFontFamily: IconsFontFamily.MaterialIcons,
        iconColor: 0xFF14A01B,
      );
      _categoryIsIncome = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _categoryController.dispose();
    if (widget.callBack != null) widget.callBack!();
  }

  void cancelCallback(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> addCallback() async {
    CategoryDbModel newCategory = CategoryDbModel(
      categoryId: _categoryId,
      categoryIcon: _iconModel,
      categoryName: _categoryController.text,
      categoryIsIncome: _categoryIsIncome,
    );
    final locale = AppLocalizations.of(context)!;
    final controller = locator.get<BudgetController>();

    if (_categoryId != null) {
      await controller.updateCategory(newCategory);
      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      List<String> categoriesNames = controller.categoryNames;

      if (!categoriesNames.contains(newCategory.categoryName)) {
        await controller.addCategory(newCategory);
        if (!context.mounted) return;
        Navigator.pop(context, newCategory);
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

  void changeState(bool state) {
    setState(() {
      _categoryIsIncome = state;
    });
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
          // CategoryName
          child: CategoryTextFormField(
            controller: _categoryController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.addCategoryDialogCannotEmpty;
              }
              return null;
            },
          ),
        ),
        // Primary use
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            locale.categoryDialogQuestion,
            style: AppTextStyles.textStyleSemiBold14.copyWith(
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        RowOfTwoBottons(
          income: _categoryIsIncome,
          changeState: changeState,
        ),
        // Icon x color selection
        SelectIconRow(
          iconModel: _iconModel,
          iconCallback: (IconModel newIcon) {
            setState(() {
              _iconModel.iconName = newIcon.iconName;
              _iconModel.iconFontFamily = newIcon.iconFontFamily;
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
