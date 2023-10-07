import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class CategoriesHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  CategoriesHelp(this._title, this._messages);

  static CategoriesHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpCategoriesTitle;
    final List<Object> messages = [
      locale.helpCategories0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/categories_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpCategories1,
      locale.helpCategories2,
      locale.helpCategories3,
      locale.helpCategories4,
    ];

    return CategoriesHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
