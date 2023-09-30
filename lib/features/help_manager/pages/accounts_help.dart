import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class AccountsHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  AccountsHelp(this._title, this._messages);

  static AccountsHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpAccountsTitle;
    final List<Object> messages = [
      locale.helpAccounts0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/accounts_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpAccounts1,
      locale.helpAccounts2,
      locale.helpAccounts3,
    ];

    return AccountsHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
