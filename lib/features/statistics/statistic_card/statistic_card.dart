import 'package:finances/common/current_models/current_user.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/widgets/custom_circular_progress_indicator.dart';
import '../../../locator.dart';
import '../graphics/line_graphic.dart';
import '../graphics/model/graphic_line_data.dart';
import '../statistic_controller.dart';
import '../statistic_state.dart';

class StatisticCard extends StatefulWidget {
  final StatisticsController controller;

  const StatisticCard({
    super.key,
    required this.controller,
  });

  @override
  State<StatisticCard> createState() => _StatisticCardState();
}

class _StatisticCardState extends State<StatisticCard> {
  bool horizontalGrid = true;
  bool verticalGrid = true;

  ExtendedDate currentDate = ExtendedDate.now();

  List<GraphicLineData> incomesExpensesData() {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    final incomes = widget.controller.incomes.values.toList().reversed.toList();
    final expanses =
        widget.controller.expanses.values.toList().reversed.toList();

    final List<GraphicLineData> graphicData = [];

    graphicData.add(
      GraphicLineData(
        data: List<FlSpot>.generate(
          incomes.length,
          (index) => FlSpot(
            index.toDouble(),
            incomes[index],
          ),
        ),
        name: 'Incomes',
        color: customColors.lowgreen!,
      ),
    );

    graphicData.add(
      GraphicLineData(
        data: List<FlSpot>.generate(
          expanses.length,
          (index) => FlSpot(
            index.toDouble(),
            expanses[index].abs(),
          ),
        ),
        name: 'Expenses',
        color: customColors.minusred!,
      ),
    );

    return graphicData;
  }

  List<String> xLabels() {
    final basicLabels = widget.controller.strDates;

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
    final user = locator.get<CurrentUser>();

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
            animation: widget.controller,
            builder: (context, _) {
              // Statistics State Loading
              if (widget.controller.state is StatisticsStateLoading) {
                return const CustomCircularProgressIndicator();
              }

              // Statistics State Success
              if (widget.controller.state is StatisticsStateSuccess) {
                final String strDate = widget.controller.strDate;
                final double balance = widget.controller.incomes[strDate]! +
                    widget.controller.expanses[strDate]!;

                final List<GraphicLineData> graphicData = incomesExpensesData();

                final List<String> graphicXLabes = xLabels();

                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: primary,
                              ),
                              onTap: () {
                                setState(() {
                                  widget.controller.previusMonth();
                                });
                              },
                            ),
                          ),
                          Text(
                            widget.controller.strDate,
                            style: AppTextStyles.textStyleSemiBold14.copyWith(
                              color: primary,
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: primary,
                              ),
                              onTap: () {
                                setState(() {
                                  widget.controller.nextMonth();
                                });
                              },
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
                                money.text(widget.controller.incomes[strDate]!),
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
                                money
                                    .text(widget.controller.expanses[strDate]!),
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
                                      color: user.userGrpShowGrid
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
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
                                      color: user.userGrpIsCurved
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
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
                                      color: user.userGrpShowDots
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
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
                                      color: user.userGrpAreaChart
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
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
                                    user.userGrpShowGrid =
                                        !user.userGrpShowGrid;
                                  });
                                  break;
                                case 'Curve':
                                  setState(() {
                                    user.userGrpIsCurved =
                                        !user.userGrpIsCurved;
                                  });
                                  break;
                                case 'Dots':
                                  setState(() {
                                    user.userGrpShowDots =
                                        !user.userGrpShowDots;
                                  });
                                  break;
                                default:
                                  setState(() {
                                    user.userGrpAreaChart =
                                        !user.userGrpAreaChart;
                                  });
                              }
                              await user.updateUser();
                            },
                          ),
                        ],
                      ),
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
                            showGrid: user.userGrpShowGrid,
                            isCurved: user.userGrpIsCurved,
                            showDots: user.userGrpShowDots,
                            areaChart: user.userGrpAreaChart,
                          ),
                        ),
                      ),
                    ],
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
        ),
      ),
    );
  }
}
