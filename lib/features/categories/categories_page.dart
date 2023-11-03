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
import '../../locator.dart';
import '../help_manager/main_manager.dart';
import '../statistics/statistic_controller.dart';
import 'categories_controller.dart';
import 'categories_state.dart';
import 'widget/change_budget_dialog.dart';
import 'widget/dismissible_category.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with AutomaticKeepAliveClientMixin {
  final _controller = locator.get<CategoriesController>();
  final _statController = locator.get<StatisticsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _statController.init();
    _controller.init();
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  void callBack() {
    _controller.getAllCategories();
  }

  Future<void> budgetEdit(
    BuildContext context,
    CategoryDbModel category,
  ) async {
    final mediumMonth =
        _statController.getReferences(StatisticMedium.mediumMonth);
    final medium12Months =
        _statController.getReferences(StatisticMedium.medium12);

    final categories = _controller.categories;
    int index = categories.indexWhere(
      (cat) => category.categoryName == cat.categoryName,
    );
    bool continueEditing = true;
    final navigator = Navigator.of(context);
    final dialogContext = context;

    while (continueEditing) {
      final categoryBudget = categories[index];
      String categoryName = categoryBudget.categoryName;
      final medium = mediumMonth[categoryName] ?? 0;
      final medium12 = medium12Months[categoryName] ?? 0;

      await showDialog(
        context: dialogContext,
        builder: (dialogContext) => ChangeBudgetDialog(
          category: categoryBudget,
          medium: medium,
          medium12: medium12,
          previousIndex: (value) async {
            if (index > 0) {
              index--;
            }
            await updateBudget(categoryBudget, value);
            navigator.pop();
          },
          closeUpdate: (value) async {
            continueEditing = false;
            await updateBudget(categoryBudget, value);
            navigator.pop();
          },
          nextIndex: (value) async {
            if (index < categories.length - 1) {
              index++;
            }
            await updateBudget(categoryBudget, value);
            navigator.pop();
          },
        ),
      );
    }
  }

  Future<void> updateBudget(
    CategoryDbModel category,
    double budgetValue,
  ) async {
    if (category.categoryBudget != budgetValue) {
      category.categoryBudget = budgetValue;
      await _controller.updateCategoryBudget(category);
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
          SizedBox(
            width: 32,
            height: 32,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => managerTutorial(
                context,
                categoriesHelp,
              ),
              child: const Icon(
                Icons.question_mark,
                size: 20,
              ),
            ),
          ),
          PopupMenuButton<StatisticMedium>(
            icon: const Icon(
              Icons.more_vert,
            ),
            itemBuilder: (context) => [
              PopupMenuItem<StatisticMedium>(
                value: StatisticMedium.none,
                child: Column(
                  children: [
                    const Text('Budget'),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.refresh_sharp),
                      title: Text(locale.budgetPageResetValues),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<StatisticMedium>(
                value: StatisticMedium.mediumMonth,
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(locale.budgetPageLastMonths),
                ),
              ),
              PopupMenuItem<StatisticMedium>(
                value: StatisticMedium.medium12,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(locale.budgetPage12Month),
                ),
              ),
            ],
            onSelected: (value) {
              _controller.setAllBudgets(value);
            },
          ),
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
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Budget State Loading
                  if (_controller.state is CategoriesStateLoading) {
                    return CustomCircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    );
                  }

                  // Budget State Success
                  if (_controller.state is CategoriesStateSuccess) {
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
                                  DismissibleCategory(
                                controller: _controller,
                                index: index,
                                callBack: callBack,
                                budgetEdit: (edit) => budgetEdit(context, edit),
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
        ],
      ),
    );
  }
}
