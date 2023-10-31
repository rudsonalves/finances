import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/current_models/current_user.dart';
import '../../common/widgets/markdown_rich_text.dart';
import '../../locator.dart';
import '../../repositories/account/account_repository.dart';
import '../../services/database/database_helper.dart';
import '../help_manager/main_manager.dart';
import '../home_page/balance_card/balance_card_controller.dart';
import 'account_state.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import 'account_controller.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/models/account_db_model.dart';
import 'widgets/add_account_page.dart';
import 'widgets/dismissible_account_card.dart';
import '../../common/extensions/money_masked_text.dart';
import '../../common/constants/themes/app_text_styles.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _controller = locator.get<AccountController>();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  Future<void> addAccount([AccountDbModel? account]) async {
    await showDialog(
      context: context,
      builder: (context) => AddAccountPage(
        editAccount: account,
      ),
    );
    _controller.getAllBalances();
    locator.get<BalanceCardController>().requestRedraw();
  }

  Future<bool> deleteAccount(AccountDbModel account) async {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    int numberOfTrans =
        await locator.get<DatabaseHelper>().countTransactionsForAccountId(
              account.accountId!,
            );

    if (numberOfTrans > 0) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(locale.colorButtonBlockedDeletion),
          content: MarkdownRichText.richText(
            locale.colorButtonAccountHas(account.accountName, numberOfTrans),
            normalStyle: AppTextStyles.textStyle14,
            boldStyle: AppTextStyles.textStyleBold14,
            color: colorScheme.onSecondaryContainer,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(locale.genericClose),
            ),
          ],
        ),
      );
      return false;
    }

    if (!context.mounted) return false;
    bool delete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              locale.accountPageRemoveAccount,
              textAlign: TextAlign.center,
            ),
            content: Text(
              locale.accountPageMsg(account.accountName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(locale.accountPageDelete),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(locale.accountPageCancel),
              ),
            ],
          ),
        ) ??
        false;

    if (delete) {
      await locator.get<AccountRepository>().deleteAccount(account);
      locator.get<BalanceCardController>().requestRedraw();
    }
    _controller.getAllBalances();
    return delete;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final money = locator.get<MoneyMaskedText>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: Text(
          locale.accountPageTitle,
          style: AppTextStyles.textStyleSemiBold18,
        ),
        actions: [
          IconButton(
            onPressed: () => managerTutorial(context, accountsHelp),
            icon: const Icon(
              Icons.question_mark,
              size: 20,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppTopBorder(),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.onSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              margin: const EdgeInsets.only(
                left: 0,
                right: 0,
                bottom: 0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    // Account State Loading
                    if (_controller.state is AccountStateLoading) {
                      return const CustomCircularProgressIndicator();
                    }

                    // Account State Success
                    if (_controller.state is AccountStateSuccess) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            locale.balanceCardBalance,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.textStyleSemiBold18.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            money.text(_controller.totalBalance),
                            textAlign: TextAlign.left,
                            style: AppTextStyles.textStyleBold28.copyWith(
                              color: _controller.totalBalance >= 0
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 16),
                            child: Text(
                              locale.accountPageAccounts,
                              style: AppTextStyles.textStyleBold16.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _controller.accounts.length,
                              itemBuilder: (context, index) {
                                AccountDbModel account =
                                    _controller.accounts[index];
                                double balance = _controller.balances[index];

                                int currentUserAccountId = locator
                                    .get<CurrentUser>()
                                    .userMainAccountId!;

                                if (account.accountId ==
                                    currentUserAccountId) {}
                                return DismissibleAccountCard(
                                  account: account,
                                  balance: balance,
                                  editCallBack: addAccount,
                                  deleteCallBack:
                                      account.accountId == currentUserAccountId
                                          ? null
                                          : deleteAccount,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    // Account State Error
                    return Text(locale.transPageError);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
