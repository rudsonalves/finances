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
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/current_models/current_user.dart';
import '../../../common/models/ofx_account_model.dart';
import '../../../common/models/ofx_relationship_model.dart';
import '../../../locator.dart';
import 'account_popup_menu.dart';
import 'ofx_info_button.dart';
import 'ofx_information.dart';
import 'ofx_stop_categories.dart';
import 'simple_edit_dialog.dart';

class OfxFileDialog extends StatefulWidget {
  final OfxAccountModel ofxAccount;
  final OfxRelationshipModel ofxRelation;
  final bool autoTransaction;
  final void Function(bool) callback;

  const OfxFileDialog({
    super.key,
    required this.ofxAccount,
    required this.ofxRelation,
    required this.autoTransaction,
    required this.callback,
  });

  static Future<bool> ofxFileImportDialog(
    BuildContext context, {
    required OfxAccountModel ofxAccount,
    required OfxRelationshipModel ofxRelation,
    required bool autoTransaction,
    required void Function(bool) callback,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: OfxFileDialog(
                  ofxAccount: ofxAccount,
                  ofxRelation: ofxRelation,
                  autoTransaction: autoTransaction,
                  callback: callback,
                ),
              ),
            );
          },
        ) ??
        false;
  }

  @override
  State<OfxFileDialog> createState() => _OfxFileDialogState();
}

class _OfxFileDialogState extends State<OfxFileDialog> {
  final _autoTransactions = ValueNotifier<bool>(false);
  int? newAccountId;

  @override
  void initState() {
    super.initState();
    _autoTransactions.value = widget.autoTransaction;
  }

  void toogleAutoTransaction(bool? value) {
    _autoTransactions.value = !_autoTransactions.value;
    widget.callback(_autoTransactions.value);
  }

  Future<void> _selectCategories() async {
    final currentUser = locator<CurrentUser>();
    final userOfxStopCategories =
        await OfxStopCategories.showOfxStopCategoriesDialog(context);
    currentUser.userOfxStopCategories = userOfxStopCategories;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(12),
      title: Text(
        locale.ofxFileDlgTitle,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bank Account
          OfxInformation(
            title: locale.ofxFileDlgBankAccount,
            value: widget.ofxAccount.bankAccountId,
          ),
          // # of transactions
          OfxInformation(
            title: locale.ofxFileDlgTransactions,
            value: widget.ofxAccount.nTrans.toString(),
          ),
          // Start Date
          OfxInformation(
            title: locale.ofxFileDlgStartDate,
            value: DateFormat.yMd().format(widget.ofxAccount.startDate),
          ),
          // End Date
          OfxInformation(
            title: locale.ofxFileDlgEndDate,
            value: DateFormat.yMd().format(widget.ofxAccount.endDate),
          ),
          // Bank Name
          OfxInfoButton(
            title: locale.ofxFileDlgBank,
            value: widget.ofxAccount.bankName ?? '***',
            callBack: () async {
              String value = await simpleEditDialog(
                context,
                title: locale.ofxFileDlgBankName,
                labelText: widget.ofxAccount.bankName ?? '***',
                actionButtonText: locale.ofxFileDlgApply,
                cancelButtonText: locale.genericCancel,
              );
              if (value != widget.ofxAccount.bankName) {
                setState(
                  () {
                    widget.ofxAccount.bankName = value;
                    widget.ofxRelation.bankName = value;
                  },
                );
              }
            },
          ),
          const Divider(),
          // Associated Account
          Text(
            locale.ofxFileDlgAssociatedAccount,
            style: AppTextStyles.textStyleBold14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccountPopupMenu(
                accountId: widget.ofxRelation.accountId,
                callBack: (accountId) {
                  setState(() {
                    widget.ofxRelation.accountId = accountId;
                    widget.ofxAccount.accountId = accountId;
                  });
                },
              ),
            ],
          ),
          const Divider(),
          ListenableBuilder(
            listenable: _autoTransactions,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  checkboxSemanticLabel: locale.ofxFileDlgAutomatically,
                  value: _autoTransactions.value,
                  onChanged: toogleAutoTransaction,
                  title: Text(locale.ofxFileDlgAutoTransactions),
                ),
                if (_autoTransactions.value)
                  Center(
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: _selectCategories,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 24,
                          ),
                          child: Text(
                            locale.ofxStopCategoryButton,
                            style: AppTextStyles.textStyleSemiBold16
                                .copyWith(color: primary),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ButtonBar(
          children: [
            FilledButton(
              onPressed: widget.ofxRelation.accountId != null
                  ? () => Navigator.pop(context, true)
                  : null,
              child: Text(locale.genericAdd),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(locale.genericCancel),
            ),
          ],
        ),
      ],
    );
  }
}
