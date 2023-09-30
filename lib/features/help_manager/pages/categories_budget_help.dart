import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class CategoriesBudgetHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  CategoriesBudgetHelp(this._title, this._messages);

  static CategoriesBudgetHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpCategoriesBudgetTitle;
    final List<Object> messages = [
      locale.helpCategoriesBudget0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/categories_budget_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpCategoriesBudget1,
      locale.helpCategoriesBudget2,
      locale.helpCategoriesBudget3,
      locale.helpCategoriesBudget4,
      locale.helpCategoriesBudget5,
      locale.helpCategoriesBudget6,
    ];

    return CategoriesBudgetHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
