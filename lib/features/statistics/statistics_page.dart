import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/app_constants.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import '../../locator.dart';
import '../help_manager/main_manager.dart';
import 'statistic_card/statistic_card.dart';
import 'statistic_controller.dart';
import 'statistic_state.dart';
import 'widgets/list_tile_statistic.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _controller = locator.get<StatisticsController>();
  late StatisticMedium statReference;

  @override
  void initState() {
    super.initState();
    _controller.init();
    statReference = _controller.statReference;
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Center(
      child: Scaffold(
        appBar: CustomAppBar(
          centerTitle: true,
          enableColor: true,
          title: Text(
            locale.statisticsPageTitle,
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
                  statisticsHelp,
                ),
                child: const Icon(
                  Icons.question_mark,
                  size: 20,
                ),
              ),
            ),
            PopupMenuButton<StatisticMedium>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                CheckedPopupMenuItem<StatisticMedium>(
                  checked: statReference == StatisticMedium.mediumMonth
                      ? true
                      : false,
                  value: StatisticMedium.mediumMonth,
                  child: Text(locale.statisticsPageLastMonths),
                ),
                CheckedPopupMenuItem<StatisticMedium>(
                  checked:
                      statReference == StatisticMedium.medium12 ? true : false,
                  value: StatisticMedium.medium12,
                  child: Text(locale.statisticsPage12Month),
                ),
                CheckedPopupMenuItem<StatisticMedium>(
                  checked: statReference == StatisticMedium.categoryBudget
                      ? true
                      : false,
                  value: StatisticMedium.categoryBudget,
                  child: Text(locale.statisticsPageCategoryBudget),
                ),
              ],
              onSelected: (value) {
                _controller.setStatisticsReference(value);
                statReference = value;
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            const AppTopBorder(),
            StatisticCard(_controller),
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
                              color: colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            locale.statisticsPageValue,
                            style: AppTextStyles.textStyleSemiBold18.copyWith(
                              color: colorScheme.primary,
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

                          final statistics =
                              _controller.statisticsMap[strDate]!;

                          if (statistics.isEmpty) {
                            return Expanded(
                              child: noStatistics(locale, primary),
                            );
                          }

                          return Expanded(
                            child: ListView.builder(
                              itemCount: statistics.length,
                              itemBuilder: (context, index) =>
                                  ListTileStatistic(statistics[index]),
                            ),
                          );
                        }

                        // Statistics State Error
                        return Expanded(
                          child: noStatistics(locale, primary),
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
