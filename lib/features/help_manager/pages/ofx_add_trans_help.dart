import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class OfxAddTransHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  OfxAddTransHelp(this._title, this._messages);

  static OfxAddTransHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpOfxAddTitle;
    final List<Object> messages = [
      locale.helpOfxAddMsg1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/ofx_04.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpOfxAddMsg2,
      locale.helpOfxAddMsg3,
    ];
    return OfxAddTransHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
