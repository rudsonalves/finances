import 'package:finances/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/current_models/current_account.dart';
import '../../../common/current_models/current_balance.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/functions/card_income_function.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/widgets/custom_circular_progress_indicator.dart';
import '../../../locator.dart';
import './balance_card_controller.dart';
import './balance_cart_state.dart';
import 'widget/card_popup_menu.dart';
import 'widget/main_card_popup_account.dart';

class BalanceCard extends StatefulWidget {
  final double textScale;
  final void Function(AccountDbModel account) balanceCallBack;
  final BalanceCardController controller;
  final MoneyMaskedText? money;
  final CurrentBalance? currentBalance;
  final CurrentAccount? currentAccount;

  const BalanceCard({
    super.key,
    required this.textScale,
    required this.balanceCallBack,
    required this.controller,
    this.money,
    this.currentBalance,
    this.currentAccount,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  late final MoneyMaskedText _money;
  late final CurrentBalance _currentBalance;
  late final CurrentAccount _currentAccount;

  bool _balanceHidden = false;

  @override
  void initState() {
    super.initState();

    _money = widget.money ?? locator<MoneyMaskedText>();
    _currentBalance = widget.currentBalance ?? locator<CurrentBalance>();
    _currentAccount = widget.currentAccount ?? locator<CurrentAccount>();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final locale = AppLocalizations.of(context)!;
    final formattedDate = DateFormat('MMMM y', locale.localeName);

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
                          flex: 8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MainCardPopupAccount(
                                account: _currentAccount,
                                widget: widget,
                              ),
                              Row(
                                children: [
                                  Text(
                                    _balanceHidden
                                        ? '••••••'
                                        : _money
                                            .text(_currentBalance.balanceClose),
                                    textAlign: TextAlign.left,
                                    style:
                                        AppTextStyles.textStyleBold20.copyWith(
                                      color: _balanceHidden
                                          ? colorScheme.onPrimary
                                          : _currentBalance.balanceClose <
                                                  -0.005
                                              ? customColors.sourceMinusred
                                              : colorScheme.onPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: locale.balanceCardBalance,
                                    onPressed: _toggleBalanceVisibility,
                                    icon: Icon(
                                      _balanceHidden
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        CardPopupMenu(
                          controller: widget.controller,
                          colorScheme: colorScheme,
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
                              onTap: widget.controller.previousMonth,
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
                              onTap: widget.controller.nextMonth,
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
                          money: _money,
                        ),
                        const Spacer(),
                        incomeExpanseShowValue(
                          context,
                          text: locale.balanceCardExpenses,
                          value: -widget.controller.balance.expanses,
                          icon: Icons.arrow_downward,
                          money: _money,
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

  void _toggleBalanceVisibility() {
    setState(() {
      _balanceHidden = !_balanceHidden;
    });
  }
}
