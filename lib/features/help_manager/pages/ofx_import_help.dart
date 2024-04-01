import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class OfxImportHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  OfxImportHelp(this._title, this._messages);

  static OfxImportHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpOfxAcquisitionTitle;
    final List<Object> messages = [
      locale.helpOfxAcquisitionMsg1,
      locale.helpOfxAcquisitionMsg2,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/ofx_02.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    ];
    return OfxImportHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
