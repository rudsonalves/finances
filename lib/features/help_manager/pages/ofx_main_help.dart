import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class OfxMainHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  OfxMainHelp(this._title, this._messages);

  static OfxMainHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpOfxTitle;
    final List<Object> messages = [
      locale.helpOfxMsg1,
      locale.helpOfxMsg2,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: Image.asset(
                'assets/images/ofx_file.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    ];
    return OfxMainHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
