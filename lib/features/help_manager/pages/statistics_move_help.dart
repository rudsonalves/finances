import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class StatisticsMoveHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  StatisticsMoveHelp(this._title, this._messages);

  static StatisticsMoveHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpStatisticsMoveTitle;
    final List<Object> messages = [
      locale.helpStatisticsMove0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/statistics_more_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    ];

    return StatisticsMoveHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
