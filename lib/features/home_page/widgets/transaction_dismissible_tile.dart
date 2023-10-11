import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/colors/app_colors.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/models/extends_date.dart';
import '../../../locator.dart';
import '../../../services/database/managers/transfers_manager.dart';
import '../../statistics/statistic_controller.dart';
import '../home_page_controller.dart';
import '../balance_card/balance_card_controller.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/constants/routes/app_route.dart';
import '../../../common/models/transaction_db_model.dart';
import '../../../common/extensions/money_masked_text.dart';
import '../../../common/functions/function_alert_dialog.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../repositories/category/category_repository.dart';
import '../../../common/functions/base_dismissible_container.dart';
import '../../../services/database/managers/transactions_manager.dart';

class TransactionDismissibleTile extends StatefulWidget {
  final double textScale;
  final TransactionDbModel transaction;
  final void Function()? onTap;

  const TransactionDismissibleTile({
    super.key,
    required this.textScale,
    required this.transaction,
    this.onTap,
  });

  @override
  State<TransactionDismissibleTile> createState() =>
      _TransactionDismissibleTileState();
}

class _TransactionDismissibleTileState
    extends State<TransactionDismissibleTile> {
  final homePageController = locator.get<HomePageController>();

  final balanceCardController = locator.get<BalanceCardController>();

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
    final money = locator.get<MoneyMaskedText>();

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
                      .get<CategoryRepository>()
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
    if (balanceCardController.transStatusCheck) {
      await widget.transaction.toggleTransStatus();
      setState(() {});
    }
  }

  void onTabFuture() async {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final money = locator.get<MoneyMaskedText>();
    final balanceCardController = locator.get<BalanceCardController>();
    final transaction = widget.transaction;

    double value = transaction.transValue;
    bool minus = value.isNegative;
    value = value.abs();

    final CategoryDbModel category =
        locator.get<CategoryRepository>().getCategoryId(
              transaction.transCategoryId,
            );
    final AppLocalizations locale = AppLocalizations.of(context)!;

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
        confirmDismiss: (direction) async {
          // return if transaction.transStatus is transactionChecked
          if (transaction.transStatus == TransStatus.transactionChecked) {
            return false;
          }
          if (direction == DismissDirection.startToEnd) {
            // Edit
            await Navigator.pushNamed(
              context,
              AppRoute.transaction.name,
              arguments: {
                'addTransaction': false,
                'transaction': transaction,
              },
            );
            locator.get<StatisticsController>().requestRecalculate();
            homePageController.getTransactions();
            balanceCardController.getBalance();
            return false;
          }
          if (direction == DismissDirection.endToStart) {
            // Delete
            bool? action = await deleteTransactionDialog(context, transaction);

            if (action ?? false) {
              try {
                if (transaction.transTransferId == null) {
                  await TransactionsManager.removeTransaction(transaction);
                } else {
                  await TransfersManager.removeTransfer(transaction);
                }
                locator.get<StatisticsController>().requestRecalculate();
                homePageController.getTransactions();
                balanceCardController.getBalance();
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
          return false;
        },
      ),
    );
  }
}
