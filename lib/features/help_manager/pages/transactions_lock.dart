import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class TransactionsLockHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  TransactionsLockHelp(this._title, this._messages);

  static TransactionsLockHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsLockTitle;
    final List<Object> messages = [
      locale.helpTransactionsLock0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_card_menu_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsLock1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_lock2_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsLock2,
    ];

    return TransactionsLockHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
