import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/functions/base_dismissible_container.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/models/ofx_account_model.dart';
import '../../../common/widgets/account_row.dart';
import '../../../common/widgets/markdown_rich_text.dart';
import '../../../locator.dart';
import '../ofx_page_controller.dart';

class DismissibleOfxAccount extends StatelessWidget {
  const DismissibleOfxAccount({
    super.key,
    required this.ofxAccount,
    required this.account,
  });

  final OfxAccountModel ofxAccount;
  final AccountDbModel? account;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final ofxPageController = locator<OfxPageController>();

    return Dismissible(
      key: UniqueKey(),
      background: baseDismissibleContainer(
        context,
        alignment: Alignment.centerLeft,
        color: customColors.lightgreenContainer!,
        icon: Icons.edit,
        label: locale.transactionListTileEdit,
        enable: false,
      ),
      secondaryBackground: baseDismissibleContainer(
        context,
        alignment: Alignment.centerRight,
        color: colorScheme.errorContainer,
        icon: Icons.delete,
        label: locale.transactionListTileDelete,
        enable: true,
      ),
      child: Card(
        child: ListTile(
          title: Text(
            ofxAccount.bankName!,
            style: AppTextStyles.textStyleBold16.copyWith(
              color: colorScheme.primary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownRichText.richText(
                locale.ofxDismissibleBankId(ofxAccount.bankAccountId),
                color: Colors.black,
              ),
              MarkdownRichText.richText(
                locale.ofxDismissibleDate(
                  ofxAccount.endDate.formatYMD(locale.localeName),
                  ofxAccount.startDate.formatYMD(locale.localeName),
                ),
                color: Colors.black,
              ),
              MarkdownRichText.richText(
                locale.ofxDismissibleNTransactions(ofxAccount.nTrans),
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    locale.ofxDismissibleAssociatedTo,
                    style: AppTextStyles.textStyleBold14,
                  ),
                  const SizedBox(width: 8),
                  AccountRow(
                    account: account!,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await ofxPageController.deleteOfxAccount(ofxAccount);
        }
        return false;
      },
    );
  }
}
