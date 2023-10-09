import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class TransactionsFutureHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  TransactionsFutureHelp(this._title, this._messages);

  static TransactionsFutureHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsFutureTitle;
    final List<Object> messages = [
      locale.helpTransactionsFuture0,
      locale.helpTransactionsFuture1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_future_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsFuture2,
      locale.helpTransactionsFuture3,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_future2_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    ];

    return TransactionsFutureHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
