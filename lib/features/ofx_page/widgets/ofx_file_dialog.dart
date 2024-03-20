import 'package:finances/common/constants/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/models/ofx_account_model.dart';
import '../../../common/models/ofx_relationship_model.dart';
import 'account_popup_menu.dart';
import 'ofx_info_button.dart';
import 'ofx_information.dart';
import 'simple_edit_dialog.dart';

class OfxFileDialog extends StatefulWidget {
  final OfxAccountModel ofxAccount;
  final OfxRelationshipModel ofxRelation;

  const OfxFileDialog({
    Key? key,
    required this.ofxAccount,
    required this.ofxRelation,
  }) : super(key: key);

  @override
  State<OfxFileDialog> createState() => _OfxFileDialogState();
}

class _OfxFileDialogState extends State<OfxFileDialog> {
  int? newAccountId;

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
