// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/functions/card_income_function.dart';
import '../../../locator.dart';
import './balance_cart_state.dart';
import './balance_card_controller.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/current_models/current_account.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/current_models/current_balance.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/widgets/custom_circular_progress_indicator.dart';
import 'widget/card_popup_menu.dart';
import 'widget/main_card_popup_account.dart';

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
  MoneyMaskedText money = locator<MoneyMaskedText>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final locale = AppLocalizations.of(context)!;
    final currentBalance = locator<CurrentBalance>();
    final currentAccount = locator<CurrentAccount>();
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
                                account: currentAccount,
                                widget: widget,
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
