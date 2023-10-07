import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class IntroductionHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  IntroductionHelp(this._title, this._messages);

  static IntroductionHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpIntroductionTitle;
    final List<Object> messages = [
      locale.helpIntroduction0,
      locale.helpIntroduction1,
      locale.helpIntroduction2,
    ];
    return IntroductionHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
