import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class StatisticsMenuHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  StatisticsMenuHelp(this._title, this._messages);

  static StatisticsMenuHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpStatisticsMenuTitle;
    final List<Object> messages = [
      locale.helpStatisticsMenu0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/statistics_menu_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpStatisticsMenu1(locale.statisticsPageStatisticalRef),
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/statistics_menu1_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpStatisticsMenu2,
      locale.helpStatisticsMenu3,
    ];

    return StatisticsMenuHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
