import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class TransactionsCardHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  TransactionsCardHelp(this._title, this._messages);

  static TransactionsCardHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsCardTitle;
    final List<Object> messages = [
      locale.helpTransactionsCard0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: Image.asset(
                'assets/images/transaction_card_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsCard1,
      locale.helpTransactionsCard2,
      locale.helpTransactionsCard3,
      locale.helpTransactionsCard4,
      locale.helpTransactionsCard5,
      locale.helpTransactionsCard6,
    ];

    return TransactionsCardHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
