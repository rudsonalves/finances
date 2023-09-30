import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class AccountsEditHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  AccountsEditHelp(this._title, this._messages);

  static AccountsEditHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpAccountsEditTitle;
    final List<Object> messages = [
      locale.helpAccountsEdit0,
      locale.helpAccountsEdit1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/accounts_edit_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpAccountsEdit2,
      locale.helpAccountsEdit3,
      locale.helpAccountsEdit4,
      locale.helpAccountsEdit5,
    ];

    return AccountsEditHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
