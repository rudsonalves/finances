import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class OfxImportFileHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  OfxImportFileHelp(this._title, this._messages);

  static OfxImportFileHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpOfxImportTitle;
    final List<Object> messages = [
      locale.helpOfxImportMsg1,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/ofx_03.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpOfxImportMsg2,
    ];
    return OfxImportFileHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
