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

import '../../../common/constants/themes/colors/app_colors.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/models/extends_date.dart';
import '../../../locator.dart';
import '../../../manager/transaction_manager.dart';
import '../../../manager/transfer_manager.dart';
import '../../statistics/statistic_controller.dart';
import '../../transaction/transaction_dialog.dart';
import '../home_page_controller.dart';
import '../balance_card/balance_card_controller.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/models/transaction_db_model.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/functions/function_alert_dialog.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../repositories/category/abstract_category_repository.dart';
import '../../../common/functions/base_dismissible_container.dart';

class TransactionDismissibleTile extends StatefulWidget {
  final double textScale;
  final TransactionDbModel transaction;

  const TransactionDismissibleTile({
    super.key,
    required this.textScale,
    required this.transaction,
  });

  @override
  State<TransactionDismissibleTile> createState() =>
      _TransactionDismissibleTileState();
}

class _TransactionDismissibleTileState
    extends State<TransactionDismissibleTile> {
  final _homePageController = locator<HomePageController>();
  final _balanceCardController = locator<BalanceCardController>();

  Widget rowTransaction(String title, String content) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: AppTextStyles.textStyleBold14,
        ),
        Text(
          content,
          style: AppTextStyles.textStyle14,
        ),
      ],
    );
  }

  Future<bool?> deleteTransactionDialog(
    BuildContext context,
    TransactionDbModel transaction,
  ) {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final money = locator<MoneyMaskedText>();

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale.transactionListTileDeleteTransaction),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                transaction.transDescription,
                maxLines: 3,
                style: AppTextStyles.textStyle16,
              ),
              const SizedBox(height: 4),
              rowTransaction(
                  locale.transactionListTileCategory,
                  locator
                      .get<AbstractCategoryRepository>()
                      .getCategoryId(transaction.transCategoryId)
                      .categoryName),
              rowTransaction(
                locale.transactionListTileValue,
                money.text(transaction.transValue),
              ),
              rowTransaction(
                locale.transactionListTileDate,
                transaction.transDate.toString(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(locale.transactionListTileDelete),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(locale.transactionListTileCancel),
          ),
        ],
      ),
    );
  }

  void onTabCheck() async {
    if (_balanceCardController.transStatusCheck) {
      await widget.transaction.toggleTransStatus();
      setState(() {});
    }
  }

  void onTabFuture() async {
    if (_balanceCardController.transStatusCheck) {
      final AppLocalizations locale = AppLocalizations.of(context)!;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            locale.transactionCheckDlgTitle,
            textAlign: TextAlign.center,
          ),
          content: Text(locale.transactionCheckDlgMsg),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(locale.genericClose),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> dismissActions(
    BuildContext context, {
    required TransactionDbModel transaction,
    required DismissDirection direction,
    required BalanceCardController controller,
  }) async {
    // return if transaction.transStatus is transactionChecked. Checked
    // transactions can not be edited or deleted.
    if (transaction.transStatus == TransStatus.transactionChecked) {
      return false;
    }
    if (direction == DismissDirection.startToEnd) {
      // Edit
      return await editDismiss(
        context,
        transaction: transaction,
        controller: controller,
      );
    } else if (direction == DismissDirection.endToStart) {
      // Delete
      return await deleteDismiss(
        context,
        transaction: transaction,
        controller: controller,
      );
    }
    return false;
  }

  Future<bool> editDismiss(
    BuildContext context, {
    required TransactionDbModel transaction,
    required BalanceCardController controller,
  }) async {
    int? accountDestinyId;
    if (transaction.transTransferId != null) {
      final transfer =
          await TransferManager.getId(transaction.transTransferId!);
      accountDestinyId =
          transfer!.transferAccount0 == transaction.transAccountId
              ? transfer.transferAccount1
              : transfer.transferAccount0;
    }

    if (!context.mounted) return false;
    await TransactionDialog.showTransactionDialog(
      context,
      addTransaction: false,
      transaction: transaction,
      accountDestinyId: accountDestinyId,
    );

    locator<StatisticsController>().recalculate();
    _homePageController.getTransactions();
    controller.getBalance();
    return false;
  }

  Future<bool> deleteDismiss(
    BuildContext context, {
    required TransactionDbModel transaction,
    required BalanceCardController controller,
  }) async {
    final locale = AppLocalizations.of(context)!;

    bool? action = await deleteTransactionDialog(context, transaction);

    if (action ?? false) {
      try {
        if (transaction.transTransferId == null) {
          await TransactionManager.remove(transaction);
        } else {
          await TransferManager.remove(transaction);
        }
        locator<StatisticsController>().recalculate();
        _homePageController.getTransactions();
        controller.getBalance();
        return true;
      } catch (err) {
        if (!context.mounted) return false;
        functionAlertDialog(
          context,
          title: locale.transactionListTileSorry,
          content: err.toString(),
        );
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final money = locator<MoneyMaskedText>();
    final balanceCardController = locator<BalanceCardController>();
    final transaction = widget.transaction;

    double value = transaction.transValue;
    bool minus = value.isNegative;
    value = value.abs();

    final CategoryDbModel category =
        locator<AbstractCategoryRepository>().getCategoryId(
      transaction.transCategoryId,
    );
    final locale = AppLocalizations.of(context)!;

    bool isFutureTransaction =
        transaction.transDate.onlyDate > ExtendedDate.now();

    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 8,
        left: 8,
        right: 8,
      ),
      child: Dismissible(
        key: UniqueKey(),
        background: baseDismissibleContainer(
          context,
          alignment: Alignment.centerLeft,
          color: customColors.lightgreenContainer!,
          icon: Icons.edit,
          label: locale.transactionListTileEdit,
          enable: transaction.transStatus != TransStatus.transactionChecked,
        ),
        secondaryBackground: baseDismissibleContainer(
          context,
          alignment: Alignment.centerRight,
          color: colorScheme.errorContainer,
          icon: Icons.delete,
          label: locale.transactionListTileDelete,
          enable: transaction.transStatus != TransStatus.transactionChecked,
        ),
        child: Card(
          elevation: transaction.ischecked ? 0 : 1,
          color: isFutureTransaction ? AppColors.futureTransactionsCard : null,
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: category.categoryIcon.iconWidget(
              size: 28,
              color: isFutureTransaction
                  ? colorScheme.outline.withAlpha(123)
                  : null,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 2,
                  transaction.transDescription,
                  style: isFutureTransaction
                      ? AppTextStyles.textStyle16.copyWith(
                          color: isFutureTransaction
                              ? colorScheme.outline.withAlpha(123)
                              : colorScheme.outline,
                        )
                      : AppTextStyles.textStyle16,
                ),
                Text(
                  transaction.transDate.toString(),
                  style: AppTextStyles.textStyle11.copyWith(
                    color: isFutureTransaction
                        ? colorScheme.outline.withAlpha(123)
                        : colorScheme.outline,
                  ),
                ),
              ],
            ),
            trailing: Text(
              money.text(transaction.transValue),
              style: AppTextStyles.textStyleSemiBold18.copyWith(
                  color: minus
                      ? isFutureTransaction
                          ? customColors.minusred!.withAlpha(123)
                          : customColors.minusred
                      : isFutureTransaction
                          ? customColors.lowgreen!.withAlpha(123)
                          : customColors.lowgreen,
                  fontWeight: FontWeight.w700),
            ),
            onTap: isFutureTransaction ? onTabFuture : onTabCheck,
          ),
        ),
        confirmDismiss: (direction) async => await dismissActions(
          context,
          transaction: transaction,
          direction: direction,
          controller: balanceCardController,
        ),
      ),
    );
  }
}
