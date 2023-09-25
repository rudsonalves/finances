import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_colors.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/current_models/current_user.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/widgets/custom_circular_progress_indicator.dart';
import '../../../locator.dart';
import '../../../repositories/category/category_repository.dart';
import '../graphics/line_graphic.dart';
import '../graphics/model/graphic_line_data.dart';
import '../statistic_controller.dart';
import 'statistic_card_controller.dart';
import 'statistic_cart.state.dart';

class StatisticCard extends StatefulWidget {
  final StatisticsController pageController;

  const StatisticCard(
    this.pageController, {
    super.key,
  });

  @override
  State<StatisticCard> createState() => _StatisticCardState();
}

class _StatisticCardState extends State<StatisticCard> {
  bool horizontalGrid = true;
  bool verticalGrid = true;

  ExtendedDate currentDate = ExtendedDate.now();

  final _controller = locator.get<StatisticCardController>();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  List<GraphicLineData> processesData() {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final List<GraphicLineData> graphicData = [];
    final categories = locator.get<CategoryRepository>().categoriesMap;

    for (final plotData in _controller.graphicData) {
      Color color = Colors.black;
      if (plotData.name == 'Incomes') {
        color = customColors.lowgreen!;
      } else if (plotData.name == 'Expenses') {
        color = customColors.minusred!;
      } else {
        if (categories.containsKey(plotData.name)) {
          color = Color(categories[plotData.name]!.categoryIcon.iconColor);
        } else {
          color = Colors.black;
        }
      }

      graphicData.add(
        GraphicLineData(
          data: List<FlSpot>.generate(
            plotData.data.length,
            (index) => FlSpot(
              index.toDouble(),
              plotData.data[index],
            ),
          ),
          name: plotData.name,
          color: color,
        ),
      );
    }

    return graphicData;
  }

  List<String> xLabels() {
    final basicLabels = widget.pageController.strDates;

    return List<String>.generate(
      basicLabels.length,
      (index) => basicLabels[index].substring(0, 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = colorScheme.primary;
    final money = locator.get<MoneyMaskedText>();
    final locale = AppLocalizations.of(context)!;
    final currentUser = locator.get<CurrentUser>();

    return Positioned(
      left: 4,
      right: 4,
      top: 0,
      child: Card(
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: 20,
            right: 20,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // Statistics State Loading
              if (_controller.state is StatisticCardStateLoading) {
                return const CustomCircularProgressIndicator();
              }

              // Statistics State Success
              if (_controller.state is StatisticCardStateSuccess) {
                final String strDate = widget.pageController.strDate;
                final double balance = widget.pageController.incomes[strDate]! +
                    widget.pageController.expanses[strDate]!;

                final List<GraphicLineData> graphicData = processesData();

                final List<String> graphicXLabes = xLabels();

                bool noData = locator.get<StatisticsController>().noData;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Tooltip(
                              message: locale.statisticCardPreviusMonth,
                              child: InkWell(
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: primary,
                                ),
                                onTap: () {
                                  setState(() {
                                    widget.pageController.previusMonth();
                                  });
                                },
                              ),
                            ),
                          ),
                          Text(
                            widget.pageController.strDate,
                            style: AppTextStyles.textStyleSemiBold14.copyWith(
                              color: primary,
                            ),
                          ),
                          Expanded(
                            child: Tooltip(
                              message: locale.statisticCardNextMonth,
                              child: InkWell(
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: primary,
                                ),
                                onTap: () {
                                  setState(() {
                                    widget.pageController.nextMonth();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                '${locale.statisticCardIncomes}: ',
                                style: AppTextStyles.textStyleBold14.copyWith(
                                  color: primary,
                                ),
                              ),
                              Text(
                                money.text(
                                    widget.pageController.incomes[strDate]!),
                                style: AppTextStyles.textStyleBold14.copyWith(
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                '${locale.statisticCardExpenses}: ',
                                style: AppTextStyles.textStyleBold14.copyWith(
                                  color: primary,
                                ),
                              ),
                              Text(
                                money.text(
                                    widget.pageController.expanses[strDate]!),
                                style: AppTextStyles.textStyleBold14.copyWith(
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            locale.statisticCardBalance,
                            style: AppTextStyles.textStyleBold16.copyWith(
                              color: primary,
                            ),
                          ),
                          Text(
                            money.text(balance),
                            style: AppTextStyles.textStyleBold16.copyWith(
                              color: balance < -0.005
                                  ? customColors.minusred
                                  : customColors.lowgreen,
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            tooltip: locale.statisticsPageChartSettings,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.more_outlined,
                              color: colorScheme.primary,
                            ),
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'Grid',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.grid_4x4,
                                      color: currentUser.userGrpShowGrid
                                          ? colorScheme.primary
                                          : CustomColors.unselectedText,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Grid'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'Curve',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.show_chart,
                                      color: currentUser.userGrpIsCurved
                                          ? colorScheme.primary
                                          : CustomColors.unselectedText,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Curve'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Dots',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timeline,
                                      color: currentUser.userGrpShowDots
                                          ? colorScheme.primary
                                          : CustomColors.unselectedText,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Show dots'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Area',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.area_chart,
                                      color: currentUser.userGrpAreaChart
                                          ? colorScheme.primary
                                          : CustomColors.unselectedText,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Area chart'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              switch (value) {
                                case 'Grid':
                                  setState(() {
                                    currentUser.userGrpShowGrid =
                                        !currentUser.userGrpShowGrid;
                                  });
                                  await currentUser.updateUserGrpShowGrid();
                                  break;
                                case 'Curve':
                                  setState(() {
                                    currentUser.userGrpIsCurved =
                                        !currentUser.userGrpIsCurved;
                                  });
                                  await currentUser.updateUserGrpIsCurved();
                                  break;
                                case 'Dots':
                                  setState(() {
                                    currentUser.userGrpShowDots =
                                        !currentUser.userGrpShowDots;
                                  });
                                  await currentUser.updateUserGrpShowDots();
                                  break;
                                case 'Area':
                                  setState(() {
                                    currentUser.userGrpAreaChart =
                                        !currentUser.userGrpAreaChart;
                                  });
                                  await currentUser.updateUserGrpAreaChart();
                              }
                            },
                          ),
                        ],
                      ),
                      if (!noData)
                        AspectRatio(
                          aspectRatio: 1.9,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0,
                              bottom: 0,
                              left: 8,
                              right: 12,
                            ),
                            child: LineGraphic(
                              fontColor: primary,
                              data: graphicData,
                              xLabels: graphicXLabes,
                              drawHorizontalLine: horizontalGrid,
                              drawVerticalLine: verticalGrid,
                              showGrid: currentUser.userGrpShowGrid,
                              isCurved: currentUser.userGrpIsCurved,
                              showDots: currentUser.userGrpShowDots,
                              areaChart: currentUser.userGrpAreaChart,
                            ),
                          ),
                        ),
                      if (noData)
                        Container(
                          height: 170,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: primary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              locale.statisticsPageNoStatistics,
                              style: AppTextStyles.textStyleBold14.copyWith(
                                color: primary,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                );
              }

              // Statistic Card State Error
              return Expanded(
                child: Center(
                  child: Text(locale.statisticsPageNoStatistics),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
