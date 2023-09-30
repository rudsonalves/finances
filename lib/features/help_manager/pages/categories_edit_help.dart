import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class CategoriesEditHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  CategoriesEditHelp(this._title, this._messages);

  static CategoriesEditHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpCategoriesEditTitle;
    final List<Object> messages = [
      locale.helpCategoriesEdit0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/categories_edit_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpCategoriesEdit1,
      locale.helpCategoriesEdit2,
      locale.helpCategoriesEdit3,
      locale.helpCategoriesEdit4,
      locale.helpCategoriesEdit5,
    ];

    return CategoriesEditHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
