import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class TransactionsEditHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  TransactionsEditHelp(this._title, this._messages);

  static TransactionsEditHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsEditTitle;
    final List<Object> messages = [
      locale.helpTransactionsEdit0,
      locale.helpTransactionsEdit1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_edit_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsEdit2,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_delete_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsEdit3,
      locale.helpTransactionsEdit4,
    ];

    return TransactionsEditHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
