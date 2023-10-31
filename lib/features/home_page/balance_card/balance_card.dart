import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/functions/card_income_function.dart';
import '../../../locator.dart';
import './balance_cart_state.dart';
import './balance_card_controller.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/current_models/current_account.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/current_models/current_balance.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/widgets/custom_circular_progress_indicator.dart';

class BalanceCard extends StatefulWidget {
  final double textScale;
  final void Function(AccountDbModel account) balanceCallBack;
  final BalanceCardController controller;

  const BalanceCard({
    super.key,
    required this.textScale,
    required this.balanceCallBack,
    required this.controller,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  MoneyMaskedText money = locator.get<MoneyMaskedText>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final locale = AppLocalizations.of(context)!;
    final currentBalance = locator.get<CurrentBalance>();
    final currentAccount = locator.get<CurrentAccount>();
    final formattedDate = DateFormat('MMMM y', locale.localeName);

    IconData futureTransIcon() {
      switch (widget.controller.futureTransactions) {
        case FutureTrans.hide:
          return Icons.event_busy;
        case FutureTrans.week:
          return Icons.date_range;
        case FutureTrans.month:
          return Icons.calendar_month;
        case FutureTrans.year:
          return Icons.event_available;
      }
    }

    return Positioned(
      left: 24,
      right: 24,
      top: 10,
      child: Card(
        elevation: 5,
        color: colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              // State Loading...
              if (widget.controller.state is BalanceCardStateLoading) {
                return CustomCircularProgressIndicator(
                  color: colorScheme.onPrimary,
                );
              }

              // State Success...
              if (widget.controller.state is BalanceCardStateSuccess) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              PopupMenuButton<int>(
                                tooltip: locale.cardBalanceMenuTip,
                                child: Row(
                                  children: [
                                    currentAccount.accountIcon.iconWidget(
                                      size: 20,
                                      color: customColors.sourceLightyellow,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      currentAccount.accountName,
                                      maxLines: 1,
                                      style: AppTextStyles.textStyleSemiBold16
                                          .copyWith(
                                        color: customColors.sourceLightyellow,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: customColors.sourceLightyellow,
                                    ),
                                  ],
                                ),
                                onSelected: (accountId) {
                                  final account =
                                      widget.controller.accountsMap[accountId]!;
                                  widget.balanceCallBack(account);
                                },
                                itemBuilder: (BuildContext context) {
                                  return widget.controller.accountsList
                                      .map((account) {
                                    return PopupMenuItem(
                                      value: account.accountId,
                                      child: Row(
                                        children: [
                                          account.accountIcon
                                              .iconWidget(size: 16),
                                          const SizedBox(width: 8),
                                          Text(account.accountName),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                              Row(
                                children: [
                                  Text(
                                    money.text(currentBalance.balanceClose),
                                    textAlign: TextAlign.left,
                                    style:
                                        AppTextStyles.textStyleBold20.copyWith(
                                      color:
                                          currentBalance.balanceClose < -0.005
                                              ? customColors.sourceMinusred
                                              : colorScheme.onPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'transactionStatus',
                              child: ListTile(
                                leading: Icon(
                                  widget.controller.transStatusCheck
                                      ? Icons.lock_open
                                      : Icons.lock,
                                  color: colorScheme.primary,
                                  size: 22,
                                ),
                                title: Text(
                                  widget.controller.transStatusCheck
                                      ? locale.balanceCardLockTrans
                                      : locale.balanceCardUnLockTrans,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'futureTransactions',
                              child: PopupMenuButton<FutureTrans>(
                                elevation: 10,
                                itemBuilder: (context) => [
                                  CheckedPopupMenuItem(
                                    checked: widget.controller
                                        .isFutureTrans(FutureTrans.hide),
                                    value: FutureTrans.hide,
                                    child: ListTile(
                                      leading: const Icon(Icons.event_busy),
                                      title: Text(locale.cardBalanceMenuHide),
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    checked: widget.controller
                                        .isFutureTrans(FutureTrans.week),
                                    value: FutureTrans.week,
                                    child: ListTile(
                                      leading: const Icon(Icons.date_range),
                                      title: Text(locale.cardBalanceMenuWeek),
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    checked: widget.controller
                                        .isFutureTrans(FutureTrans.month),
                                    value: FutureTrans.month,
                                    child: ListTile(
                                      leading: const Icon(Icons.calendar_month),
                                      title: Text(locale.cardBalanceMenuMonth),
                                    ),
                                  ),
                                  CheckedPopupMenuItem(
                                    checked: widget.controller
                                        .isFutureTrans(FutureTrans.year),
                                    value: FutureTrans.year,
                                    child: ListTile(
                                      leading:
                                          const Icon(Icons.event_available),
                                      title: Text(locale.cardBalanceMenuYear),
                                    ),
                                  ),
                                ],
                                child: ListTile(
                                  leading: Icon(
                                    Icons.event,
                                    color: colorScheme.primary,
                                  ),
                                  title: Text(locale.cardBalanceMenuShow),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                ),
                                onSelected: (value) {
                                  Navigator.of(context).pop();
                                  widget.controller
                                      .changeFutureTransactions(value);
                                },
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'transactionStatus') {
                              widget.controller.toggleTransStatusCheck();
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                widget.controller.transStatusCheck
                                    ? Icons.lock_open
                                    : Icons.lock,
                                color: colorScheme.onPrimary,
                                size: 22,
                              ),
                              Icon(
                                futureTransIcon(),
                                color: colorScheme.onPrimary,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: locale.statisticCardPreviusMonth,
                            child: InkWell(
                              onTap: () {
                                ExtendedDate date =
                                    widget.controller.balanceDate;
                                final newDate = date.previousMonth();
                                widget.controller.setBalanceDate(newDate);
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: colorScheme.onPrimary,
                                size: 18,
                              ),
                              // ),
                            ),
                          ),
                        ),
                        Text(
                          formattedDate.format(widget.controller.balanceDate),
                          style: AppTextStyles.textStyleBold14.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: locale.statisticCardNextMonth,
                            child: InkWell(
                              onTap: () {
                                ExtendedDate date =
                                    widget.controller.balanceDate;
                                final newDate = date.nextMonth();
                                widget.controller.setBalanceDate(newDate);
                              },
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: colorScheme.onPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        incomeExpanseShowValue(
                          context,
                          text: locale.balanceCardIncomes,
                          value: widget.controller.balance.incomes,
                          icon: Icons.arrow_upward,
                        ),
                        const Spacer(),
                        incomeExpanseShowValue(
                          context,
                          text: locale.balanceCardExpenses,
                          value: -widget.controller.balance.expanses,
                          icon: Icons.arrow_downward,
                        ),
                      ],
                    ),
                  ],
                );
              }

              // State Error...
              return Center(
                child: Text(
                  locale.balanceCardError,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textStyle16.apply(
                    color: colorScheme.onPrimary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
