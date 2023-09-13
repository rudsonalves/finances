import 'package:finances/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/app_constants.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../common/constants/themes/colors/custom_color.g.dart';
import '../../common/extensions/money_masked_text.dart';
import '../../common/models/category_db_model.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import '../statistics/statistic_controller.dart';
import 'budget_controller.dart';
import 'budget_state.dart';
import 'widget/dismissible_budget.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage>
    with AutomaticKeepAliveClientMixin {
  final _controller = locator.get<BudgetController>();
  final _statController = locator.get<StatisticsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _statController.init();
    _controller.init();
  }

  void callBack() {
    _controller.getAllCategories();
  }

  Future<void> budgetEdit(
      BuildContext context, CategoryDbModel category) async {
    final mediumMonth =
        _statController.getReferences(StatisticMedium.mediumMonth);
    final medium12 = _statController.getReferences(StatisticMedium.medium12);
    final money = locator.get<MoneyMaskedText>();
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = colorScheme.primary;
    final budgetController = TextEditingController();
    final AppLocalizations locale = AppLocalizations.of(context)!;

    final categories = _controller.categories;
    int index = categories.indexWhere(
      (cat) => category.categoryName == cat.categoryName,
    );
    bool continueEditing = true;

    while (continueEditing) {
      category = categories[index];

      String categoryName = category.categoryName;
      budgetController.text = category.categoryBudget.toStringAsFixed(2);
      double medium = mediumMonth[categoryName] ?? 0;
      double medium1 = medium12[categoryName] ?? 0;

      await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
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
                  money.text(medium),
                  style: AppTextStyles.textStyleBold14.copyWith(
                    color: medium < 0 ? customColors.minusred : primary,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${locale.budgetEditDialog12Month}: '),
                Text(
                  money.text(medium1),
                  style: AppTextStyles.textStyleBold14.copyWith(
                    color: medium1 < 0 ? customColors.minusred : primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              style: AppTextStyles.textStyleBold16,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              controller: budgetController,
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
                      if (index > 0) {
                        index--;
                      }
                      updateBudget(category, budgetController.text);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: locale.budgetEditDialogUpdate,
                  onPressed: () {
                    updateBudget(category, budgetController.text);
                    continueEditing = false;
                  },
                  icon: const Icon(Icons.update),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: IconButton.filled(
                    tooltip: locale.budgetEditDialogNext,
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      if (index < categories.length - 1) {
                        index++;
                      }
                      updateBudget(category, budgetController.text);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> updateBudget(CategoryDbModel category, String budget) async {
    double? value = double.tryParse(budget);
    if (value != null) {
      if (category.categoryBudget != value) {
        category.categoryBudget = value;
        await _controller.updateCategoryBudget(category);
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = colorScheme.primary;
    final locale = AppLocalizations.of(context)!;
    final money = locator.get<MoneyMaskedText>();

    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: Text(
          locale.budgetPageTitle,
          style: AppTextStyles.textStyleSemiBold18,
        ),
        actions: [
          PopupMenuButton<StatisticMedium>(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_horiz,
            ),
            itemBuilder: (context) => [
              PopupMenuItem<StatisticMedium>(
                value: StatisticMedium.none,
                child: Text(locale.budgetPageResetValues),
              ),
              PopupMenuItem<StatisticMedium>(
                value: StatisticMedium.mediumMonth,
                child: Text(locale.budgetPageLastMonths),
              ),
              PopupMenuItem<StatisticMedium>(
                value: StatisticMedium.medium12,
                child: Text(locale.budgetPage12Month),
              ),
            ],
            onSelected: (value) {
              _controller.setAllBudgets(value);
            },
          )
        ],
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
              decoration: BoxDecoration(
                color: colorScheme.onSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Budget State Loading
                    if (_controller.state is BudgetStateLoading) {
                      return CustomCircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      );
                    }

                    // Budget State Success
                    if (_controller.state is BudgetStateSuccess) {
                      final categories = _controller.categories;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Row(
                              children: [
                                Text(
                                  '${locale.budgetPageTotal}: ',
                                  style: AppTextStyles.textStyleBold18.copyWith(
                                    color: primary,
                                  ),
                                ),
                                Text(
                                  money.text(_controller.totalBudget),
                                  style: AppTextStyles.textStyleBold18.copyWith(
                                    color: _controller.totalBudget < 0
                                        ? customColors.minusred
                                        : colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Row(
                              children: [
                                Text(
                                  locale.budgetPageCategory,
                                  style: AppTextStyles.textStyleBold16.copyWith(
                                    color: primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  locale.budgetPageBudget,
                                  style: AppTextStyles.textStyleBold16.copyWith(
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categories.length,
                                itemBuilder: (context, index) =>
                                    DismissibleBudget(
                                  controller: _controller,
                                  index: index,
                                  callBack: callBack,
                                  budgetEdit: (edit) =>
                                      budgetEdit(context, edit),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Budget State Error
                    return Center(
                      child: Text(
                        locale.categoryPageTryLate,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
