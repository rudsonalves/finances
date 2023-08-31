import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/app_text_styles.dart';
import '../../common/constants/themes/colors/custom_color.g.dart';
import '../../common/extensions/money_masked_text.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import '../../locator.dart';
import '../../repositories/category/category_repository.dart';
import 'statistic_card/statistic_card.dart';
import 'statistic_controller.dart';
import 'statistic_state.dart';

class StatisticsPage extends StatefulWidget {
  final void Function() backPage;

  const StatisticsPage({
    super.key,
    required this.backPage,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with AutomaticKeepAliveClientMixin {
  final _controller = locator.get<StatisticsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void didUpdateWidget(StatisticsPage statisticsPageWidget) {
    super.didUpdateWidget(statisticsPageWidget);

    if (_controller.redraw) {
      if (mounted) {
        _controller.getStatistics();
      }
    }
  }

  Widget variationColumn(double value) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    IconData icon;
    Color color;

    if (value > 0) {
      icon = Icons.upload;
      color = customColors.lowgreen!;
    } else if (value < 0) {
      icon = Icons.download;
      color = customColors.minusred!;
    } else {
      icon = Icons.horizontal_rule;
      color = colorScheme.primary;
    }

    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: AppTextStyles.textStyleBold10.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final locale = AppLocalizations.of(context)!;
    final money = locator.get<MoneyMaskedText>();
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final categoryRepository = locator.get<CategoryRepository>();

    return Center(
      child: Scaffold(
        appBar: CustomAppBar(
          centerTitle: true,
          enableColor: true,
          title: Text(
            locale.statisticsPageTitle,
            style: AppTextStyles.textStyleSemiBold18,
          ),
        ),
        body: Stack(
          children: [
            const AppTopBorder(),
            StatisticCard(
              controller: _controller,
            ),
            Positioned(
              top: 310,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          Text(
                            locale.statisticsPageCategory,
                            style: AppTextStyles.textStyleSemiBold18.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            locale.statisticsPageValue,
                            style: AppTextStyles.textStyleSemiBold18.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        // Statistics State Loading
                        if (_controller.state is StatisticsStateLoading) {
                          return const CustomCircularProgressIndicator();
                        }

                        // Statistics State Success
                        if (_controller.state is StatisticsStateSuccess) {
                          final String strDate = _controller.strDate;

                          if (_controller.statisticsList.isEmpty) {
                            return Expanded(
                              child: Center(
                                child: Text(locale.statisticsPageNoStatistics),
                              ),
                            );
                          }
                          return Expanded(
                            child: ListView.builder(
                              itemCount:
                                  _controller.statisticsList[strDate]!.length,
                              itemBuilder: (context, index) {
                                final item =
                                    _controller.statisticsList[strDate]![index];
                                final icon = categoryRepository
                                    .categoriesMap[item.categoryName]!
                                    .categoryIcon
                                    .iconWidget();
                                bool minus = item.totalSum < 0;
                                return ListTile(
                                  leading: icon,
                                  title: Row(
                                    children: [
                                      Text(item.categoryName),
                                      const Spacer(),
                                      Text(
                                        money.text(item.totalSum),
                                        style: AppTextStyles.textStyleSemiBold18
                                            .copyWith(
                                                color: minus
                                                    ? customColors.minusred
                                                    : customColors.lowgreen,
                                                fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: 4),
                                      variationColumn(item.variation),
                                    ],
                                  ),
                                  onTap: () {},
                                );
                              },
                            ),
                          );
                        }

                        // Statistics State Error
                        return Expanded(
                          child: Center(
                            child: Text(locale.statisticsPageNoStatistics),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
