import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_icons.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/models/icons_model.dart';
import '../../../common/widgets/add_cancel_buttons.dart';
import '../../../locator.dart';
import '../budget_controller.dart';
import 'category_text_form_field.dart';
import 'new_icon_selection.dart';

class AddCategoryPage extends StatefulWidget {
  final CategoryDbModel? editCategory;
  final Function? callBack;

  const AddCategoryPage({
    super.key,
    this.editCategory,
    this.callBack,
  });

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  bool _addNewCategory = true;
  int? _categoryId;

  IconsFontFamily fontFamily = IconsFontFamily.TrademarkIcons;

  final ValueNotifier<IconModel> _categoryIcon = ValueNotifier(
    IconModel(
      iconName: 'attach money',
      iconFontFamily: IconsFontFamily.MaterialIcons,
      iconColor: 0xFF14A01B,
    ),
  );

  final ValueNotifier<bool> _isIncome = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.editCategory != null) {
      _addNewCategory = false;
      _categoryController.text = widget.editCategory!.categoryName;
      _categoryId = widget.editCategory!.categoryId;
      _categoryIcon.value = widget.editCategory!.categoryIcon;
      _isIncome.value = widget.editCategory!.categoryIsIncome;
    } else {
      _categoryController.text = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _categoryController.dispose();
    _categoryIcon.dispose();
    _isIncome.dispose();
    if (widget.callBack != null) widget.callBack!();
  }

  Future<void> _addCallback() async {
    CategoryDbModel newCategory = CategoryDbModel(
      categoryId: _categoryId,
      categoryIcon: _categoryIcon.value,
      categoryName: _categoryController.text,
      categoryIsIncome: _isIncome.value,
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

  void _cancelCallback() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Dialog(
      elevation: 5,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            children: [
              // Title
              Center(
                child: Text(
                  _addNewCategory
                      ? locale.addCategoryDialogNewCategory
                      : locale.addCategoryDialogEditCategory,
                  style: AppTextStyles.textStyleSemiBold20.copyWith(
                    color: primary,
                  ),
                ),
              ),

              // Category Name
              const SizedBox(height: 16),
              Form(
                key: _formKey,
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
              const SizedBox(height: 18),
              // Primary Use
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    locale.categoryDialogQuestion,
                    style: AppTextStyles.textStyleSemiBold16.copyWith(
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _isIncome.value = !_isIncome.value;
                    },
                    icon: const Icon(Icons.task_alt),
                    label: ListenableBuilder(
                      listenable: _isIncome,
                      builder: (context, _) {
                        return Text(
                          _isIncome.value
                              ? locale.rowOfTwoBottonsIncome
                              : locale.rowOfTwoBottonsExpense,
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Icon Selection
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${locale.iconSelectionDialogIconSelection}:',
                    //selectionIconRowQuestion,
                    style: AppTextStyles.textStyleSemiBold16.copyWith(
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Card(
                      elevation: 5,
                      shape: const CircleBorder(),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: ListenableBuilder(
                            listenable: _categoryIcon,
                            builder: (context, _) {
                              return _categoryIcon.value.iconWidget(size: 42);
                            }),
                      ),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final IconModel? iconResult = await showDialog(
                        context: context,
                        builder: (contex) => Dialog(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 800,
                            ),
                            child: NewIconSelection(
                              icon: _categoryIcon.value,
                            ),
                          ),
                        ),
                      );
                      if (iconResult != null) {
                        _categoryIcon.value = iconResult;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Actions Buttons
              AddCancelButtons(
                addLabel: _addNewCategory
                    ? locale.addCategoryDialogAdd
                    : locale.addCategoryDialogUpdate,
                addIcon: _addNewCategory ? Icons.add : Icons.update,
                addCallback: () async {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    await _addCallback();
                  }
                },
                cancelCallback: _cancelCallback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
