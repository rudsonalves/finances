import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class SettingsHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  SettingsHelp(this._title, this._messages);

  static SettingsHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpSettingsTitle;
    final List<Object> messages = [
      locale.helpSettings0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/settings_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpSettings1,
      locale.helpSettings2,
      locale.helpSettings3,
    ];
    return SettingsHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
