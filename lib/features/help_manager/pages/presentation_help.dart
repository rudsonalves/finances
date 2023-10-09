import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';
import '../../../common/constants/themes/icons/fontello_icons.dart';

class PresentationHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  PresentationHelp(this._title, this._messages);

  static PresentationHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpPresentationTitle;
    final List<Object> messages = [
      locale.helpPresentation0,
      [
        Icon(Icons.home, color: color),
        locale.helpPresentation1,
      ],
      [
        Icon(Icons.account_balance, color: color),
        locale.helpPresentation2,
      ],
      [
        Icon(FontelloIcons.budgetOutlined, color: color),
        locale.helpPresentation3,
      ],
      [
        Icon(Icons.assessment, color: color),
        locale.helpPresentation4,
      ],
      locale.helpPresentation5,
      // locale.helpPresentation6,
    ];
    return PresentationHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
