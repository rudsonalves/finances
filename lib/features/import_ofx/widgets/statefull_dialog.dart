import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/models/ofx_account_model.dart';
import 'simple_edit_dialog.dart';
import 'ofx_info_button.dart';
import 'ofx_information.dart';

class StateFullDialog extends StatefulWidget {
  final OfxAccountModel ofxAccount;
  const StateFullDialog({
    super.key,
    required this.ofxAccount,
  });

  @override
  State<StateFullDialog> createState() => _StateFullDialogState();
}

class _StateFullDialogState extends State<StateFullDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(12),
      title: const Text('Loading Ofx file'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OfxInformation(
            title: 'Account',
            value: widget.ofxAccount.accountId,
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
                  widget.ofxAccount.bankName = value;
                  setState(() {
                    log(value);
                  });
                }
              }),
          OfxInformation(
            title: 'Bank id',
            value: widget.ofxAccount.bankId,
          ),
          const SizedBox(height: 12),
          ButtonBar(
            children: [
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Add'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Close'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
