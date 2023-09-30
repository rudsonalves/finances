import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class IconsSelectionsHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  IconsSelectionsHelp(this._title, this._messages);

  static IconsSelectionsHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpIconsSelectionsTitle;
    final List<Object> messages = [
      locale.helpIconsSelections0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/icons_selections_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpIconsSelections1,
      locale.helpIconsSelections2,
      locale.helpIconsSelections3,
      locale.helpIconsSelections4,
    ];

    return IconsSelectionsHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
