import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class BudgetSetHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  BudgetSetHelp(this._title, this._messages);

  static BudgetSetHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpBudgetSetTitle;
    final List<Object> messages = [
      locale.helpBudgetSet0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/set_budget_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpBudgetSet1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/set_budget2_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpBudgetSet2,
    ];

    return BudgetSetHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
