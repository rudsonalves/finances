import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class IconsColorHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  IconsColorHelp(this._title, this._messages);

  static IconsColorHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpIconsColorTitle;
    final List<Object> messages = [
      locale.helpIconsColor0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/icons_color_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpIconsColor1,
      locale.helpIconsColor2,
      locale.helpIconsColor3,
      locale.helpIconsColor4,
    ];

    return IconsColorHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
