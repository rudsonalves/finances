import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class OfxAutoTransHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  OfxAutoTransHelp(this._title, this._messages);

  static OfxAutoTransHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpOfxAutoTransTitle;
    final List<Object> messages = [
      locale.helpOfxAutoTransMsg1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/ofx_05.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpOfxAutoTransMsg2,
      locale.helpOfxAutoTransMsg3,
      locale.helpOfxAutoTransMsg4,
    ];
    return OfxAutoTransHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
