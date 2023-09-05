import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import 'budget_controller.dart';
import 'budget_state.dart';
import 'widget/dismissible_budget.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _controller = BudgetController();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  void callBack() {
    _controller.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          locale.budgetPageTitle,
          style: AppTextStyles.textStyleSemiBold18,
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
              decoration: BoxDecoration(
                color: colorScheme.onSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale.budgetPageCategory,
                            style: AppTextStyles.textStyleBold16.copyWith(
                              color: primary,
                            ),
                          ),
                          Text(
                            locale.budgetPageBudget,
                            style: AppTextStyles.textStyleBold16.copyWith(
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            // Budget State Loading
                            if (_controller.state is BudgetStateLoading) {
                              return CustomCircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              );
                            }

                            // Budget State Success
                            if (_controller.state is BudgetStateSuccess) {
                              final categories = _controller.categories;

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categories.length,
                                itemBuilder: (context, index) =>
                                    DismissibleBudget(
                                  controller: _controller,
                                  index: index,
                                  callBack: callBack,
                                ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
