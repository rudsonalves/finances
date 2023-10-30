import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/extensions/money_masked_text_controller.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/widgets/row_of_two_bottons.dart';
import '../../../locator.dart';

class ChangeBudgetDialog extends StatefulWidget {
  final CategoryDbModel category;
  final double medium;
  final double medium12;
  final void Function(double value) previousIndex;
  final void Function(double value) closeUpdate;
  final void Function(double value) nextIndex;

  const ChangeBudgetDialog({
    super.key,
    required this.category,
    required this.medium,
    required this.medium12,
    required this.previousIndex,
    required this.closeUpdate,
    required this.nextIndex,
  });

  @override
  State<ChangeBudgetDialog> createState() => _ChangeBudgetDialogState();
}

class _ChangeBudgetDialogState extends State<ChangeBudgetDialog> {
  final money = locator.get<MoneyMaskedText>();
  final _budgetController = getMoneyMaskedTextController(0.0);
  late bool _income;

  @override
  void initState() {
    super.initState();
    _income = widget.category.categoryBudget > 0;
    _budgetController.updateValue(widget.category.categoryBudget.abs());
    _budgetController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _budgetController.thousandSeparator.length,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _budgetController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = colorScheme.primary;
    final AppLocalizations locale = AppLocalizations.of(context)!;

    final categoryName = widget.category.categoryName;

    return SimpleDialog(
      contentPadding: const EdgeInsets.only(
        top: 8,
        right: 16,
        left: 16,
        bottom: 16,
      ),
      title: Text(
        categoryName,
        textAlign: TextAlign.center,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${locale.budgetEditDialogLastMonths}: '),
            Text(
              money.text(widget.medium),
              style: AppTextStyles.textStyleBold14.copyWith(
                color: widget.medium < 0 ? customColors.minusred : primary,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${locale.budgetEditDialog12Month}: '),
            Text(
              money.text(widget.medium12),
              style: AppTextStyles.textStyleBold14.copyWith(
                color: widget.medium12 < 0 ? customColors.minusred : primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RowOfTwoBottons(
          income: _income,
          changeState: (state) {
            setState(() {
              _income = state;
            });
          },
        ),
        TextField(
          style: AppTextStyles.textStyleBold16.copyWith(
            color: !_income ? customColors.minusred : primary,
          ),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller: _budgetController,
          decoration: InputDecoration(
            labelText: locale.budgetEditDialogBudget,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: IconButton.filled(
                tooltip: locale.budgetEditDialogPrevius,
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  final budgetValue = _income
                      ? _budgetController.numberValue
                      : -_budgetController.numberValue;
                  widget.previousIndex(budgetValue);
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: locale.budgetEditDialogUpdate,
              onPressed: () {
                final budgetValue = _income
                    ? _budgetController.numberValue
                    : -_budgetController.numberValue;
                widget.closeUpdate(budgetValue);
              },
              icon: const Icon(Icons.close),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: IconButton.filled(
                tooltip: locale.budgetEditDialogNext,
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  final budgetValue = _income
                      ? _budgetController.numberValue
                      : -_budgetController.numberValue;
                  widget.nextIndex(budgetValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
