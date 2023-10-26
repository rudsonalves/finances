import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_icons.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/models/icons_model.dart';
import '../../../common/widgets/add_cancel_buttons.dart';
import '../../../common/widgets/app_top_border.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/row_of_two_bottons.dart';
import '../../../locator.dart';
import '../budget_controller.dart';
import 'category_text_form_field.dart';
import 'select_icon_row.dart';

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

  bool _categoryIsIncome = false;
  bool _addNewCategory = true;
  int? _categoryId;
  late IconModel _iconModel;

  @override
  void initState() {
    super.initState();
    if (widget.editCategory != null) {
      _addNewCategory = false;
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

  void cancelCallback(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          _addNewCategory
              ? locale.addCategoryDialogNewCategory
              : locale.addCategoryDialogEditCategory,
        ),
      ),
      body: Stack(
        children: [
          const AppTopBorder(),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.onSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
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
                  Text(
                    locale.categoryDialogQuestion,
                    style: AppTextStyles.textStyleSemiBold14.copyWith(
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  RowOfTwoBottons(
                    income: _categoryIsIncome,
                    changeState: changeState,
                  ),
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
                    addLabel: _addNewCategory
                        ? locale.addCategoryDialogAdd
                        : locale.addCategoryDialogUpdate,
                    addIcon: _addNewCategory ? Icons.add : Icons.update,
                    addCallback: () async {
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        await addCallback();
                      }
                    },
                    cancelCallback: () => cancelCallback(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
