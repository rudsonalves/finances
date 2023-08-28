import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';

import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../locator.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/functions/base_dismissible_container.dart';

class DismissibleAccountCard extends StatelessWidget {
  final AccountDbModel account;
  final double balance;
  final void Function(AccountDbModel)? editCallBack;
  final Future<bool> Function(AccountDbModel)? deleteCallBack;

  const DismissibleAccountCard({
    super.key,
    required this.account,
    required this.balance,
    this.editCallBack,
    this.deleteCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final money = locator.get<MoneyMaskedText>();

    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 8,
      ),
      child: Dismissible(
        key: UniqueKey(),
        background: baseDismissibleContainer(
          context,
          alignment: Alignment.centerLeft,
          color: customColors.lightgreenContainer!,
          icon: Icons.edit,
          label: locale.transactionListTileEdit,
          enable: editCallBack != null,
        ),
        secondaryBackground: baseDismissibleContainer(
          context,
          alignment: Alignment.centerRight,
          color: colorScheme.errorContainer,
          icon: Icons.delete,
          label: locale.transactionListTileDelete,
          enable: deleteCallBack != null,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text(
              account.accountName,
            ),
            subtitle: Text(
              account.accountDescription ?? '',
            ),
            leading: account.accountIcon.iconWidget(),
            trailing: Text(
              money.text(
                balance,
              ),
              style: AppTextStyles.textStyleSemiBold18.copyWith(
                color:
                    balance < -0.005 ? colorScheme.error : colorScheme.primary,
              ),
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          // Edit
          if (direction == DismissDirection.startToEnd) {
            if (editCallBack != null) {
              editCallBack!(account);
            }
            return false;
          }
          // Delete
          if (direction == DismissDirection.endToStart) {
            if (deleteCallBack != null) {
              return await deleteCallBack!(account);
            }
            return false;
          }
          return false;
        },
      ),
    );
  }
}
