import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class AccountsDeleteHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  AccountsDeleteHelp(this._title, this._messages);

  static AccountsDeleteHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpAccountsDeleteTitle;
    final List<Object> messages = [
      locale.helpAccountsDelete0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/accounts_delete_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpAccountsDelete1,
    ];

    return AccountsDeleteHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
