import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../common/constants/themes/app_text_styles.dart';
import '../../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../../common/current_models/current_account.dart';
import '../balance_card.dart';

class MainCardPopupAccount extends StatelessWidget {
  const MainCardPopupAccount({
    super.key,
    required this.account,
    required this.widget,
  });

  final CurrentAccount account;
  final BalanceCard widget;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return PopupMenuButton<int>(
      tooltip: locale.cardBalanceMenuTip,
      child: Row(
        children: [
          account.accountIcon.iconWidget(
            size: 20,
            color: customColors.sourceLightyellow,
          ),
          const SizedBox(width: 6),
          Text(
            account.accountName,
            maxLines: 1,
            style: AppTextStyles.textStyleSemiBold16.copyWith(
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
        final account = widget.controller.accountsMap[accountId]!;
        widget.balanceCallBack(account);
      },
      itemBuilder: (BuildContext context) {
        return widget.controller.accountsList.map((account) {
          return PopupMenuItem(
            value: account.accountId,
            child: Row(
              children: [
                account.accountIcon.iconWidget(size: 16),
                const SizedBox(width: 8),
                Text(account.accountName),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
