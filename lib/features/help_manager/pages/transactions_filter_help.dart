import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class TransactionsFilterHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  TransactionsFilterHelp(this._title, this._messages);

  static TransactionsFilterHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsFilterTitle;
    final List<Object> messages = [
      locale.helpTransactionsFilter0,
      [
        Icon(Icons.filter_alt_outlined, color: color),
        locale.helpTransactionsFilter1,
      ],
      locale.helpTransactionsFilter2,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_filter_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsFilter3,
      locale.helpTransactionsFilter4,
    ];
    return TransactionsFilterHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
