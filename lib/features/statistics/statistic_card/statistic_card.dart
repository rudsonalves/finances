import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/functions/card_imcome_function.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/widgets/custom_circular_progress_indicator.dart';
import '../../../locator.dart';
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
  ExtendedDate currentDate = ExtendedDate.now();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    final money = locator.get<MoneyMaskedText>();
    final locale = AppLocalizations.of(context)!;

    return Positioned(
      left: 8,
      right: 8,
      top: 0,
      child: Card(
        color: primary,
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
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

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: onPrimary,
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
                            color: onPrimary,
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: onPrimary,
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
                        Text(
                          locale.statisticCardBalance,
                          style: AppTextStyles.textStyleBold22.copyWith(
                            color: onPrimary,
                          ),
                        ),
                        Text(
                          money.text(balance),
                          style: AppTextStyles.textStyleBold22.copyWith(
                            color: balance < -0.005
                                ? customColors.sourceMinusred
                                : colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        incomeExpanseShowValue(
                          context,
                          text: locale.statisticCardIncomes,
                          value: widget.controller.incomes[strDate]!,
                          icon: Icons.arrow_upward,
                        ),
                        const Spacer(),
                        incomeExpanseShowValue(
                          context,
                          text: locale.statisticCardExpenses,
                          value: -widget.controller.expanses[strDate]!,
                          icon: Icons.arrow_downward,
                        ),
                      ],
                    ),
                  ],
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
