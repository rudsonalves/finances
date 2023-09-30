import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class TransactionsAddHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  TransactionsAddHelp(this._title, this._messages);

  static TransactionsAddHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsAddTitle;
    final List<Object> messages = [
      locale.helpTransactionsAdd0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_add_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsAdd1,
      locale.helpTransactionsAdd2,
      locale.helpTransactionsAdd3,
      locale.helpTransactionsAdd4,
      locale.helpTransactionsAdd5,
      locale.helpTransactionsAdd6,
    ];

    return TransactionsAddHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
