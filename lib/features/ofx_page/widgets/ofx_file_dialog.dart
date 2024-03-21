import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/models/ofx_account_model.dart';
import '../../../common/models/ofx_relationship_model.dart';
import 'account_popup_menu.dart';
import 'ofx_info_button.dart';
import 'ofx_information.dart';
import 'simple_edit_dialog.dart';

Future<bool> ofxFileImportDialog(
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

class OfxFileDialog extends StatefulWidget {
  final OfxAccountModel ofxAccount;
  final OfxRelationshipModel ofxRelation;
  final bool autoTransaction;
  final void Function(bool) callback;

  const OfxFileDialog({
    Key? key,
    required this.ofxAccount,
    required this.ofxRelation,
    required this.autoTransaction,
    required this.callback,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(12),
      title: const Text(
        'Ofx file Import',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OfxInformation(
            title: 'Bank Account',
            value: widget.ofxAccount.bankAccountId,
          ),
          OfxInformation(
            title: 'Transactions',
            value: widget.ofxAccount.nTrans.toString(),
          ),
          OfxInformation(
            title: 'Start date',
            value: DateFormat.yMd().format(widget.ofxAccount.startDate),
          ),
          OfxInformation(
            title: 'End date',
            value: DateFormat.yMd().format(widget.ofxAccount.endDate),
          ),
          OfxInfoButton(
              title: 'Bank',
              value: widget.ofxAccount.bankName ?? '***',
              callBack: () async {
                String value = await simpleEditDialog(
                  context,
                  title: 'Bank Name',
                  labelText: widget.ofxAccount.bankName ?? '***',
                  actionButtonText: 'Apply',
                  cancelButtonText: 'Cancel',
                );
                if (value != widget.ofxAccount.bankName) {
                  setState(() {
                    widget.ofxAccount.bankName = value;
                    widget.ofxRelation.bankName = value;
                  });
                }
              }),
          OfxInformation(
            title: 'Bank id',
            value: widget.ofxAccount.bankAccountId,
          ),
          const Divider(),
          const Text(
            'Associated Account',
            style: AppTextStyles.textStyleBold14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccountPopupMenu(
                accountId: widget.ofxRelation.accountId,
                callBack: (accountId) {
                  widget.ofxRelation.accountId = accountId;
                  widget.ofxAccount.accountId = accountId;
                },
              ),
            ],
          ),
          const Divider(),
          ListenableBuilder(
            listenable: _autoTransactions,
            builder: (context, _) => CheckboxListTile(
              checkboxSemanticLabel:
                  'Automatically create transactions from templates',
              value: _autoTransactions.value,
              onChanged: toogleAutoTransaction,
              title: const Text('Auto-transactions'),
            ),
          ),
        ],
      ),
      actions: [
        ButtonBar(
          children: [
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Close'),
            ),
          ],
        )
      ],
    );
  }
}
