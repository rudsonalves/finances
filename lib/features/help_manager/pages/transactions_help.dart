import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class TransactionsHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  TransactionsHelp(this._title, this._messages);

  static TransactionsHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsTitle;
    final List<Object> messages = [
      locale.helpTransactions0,
      locale.helpTransactions1,
      locale.helpTransactions2,
      locale.helpTransactions3,
      locale.helpTransactions4,
      locale.helpTransactions5,
      locale.helpTransactions6,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    ];

    return TransactionsHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
