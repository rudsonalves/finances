import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_model.dart';

class StatisticsHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  StatisticsHelp(this._title, this._messages);

  static StatisticsHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpStatisticsTitle;
    final List<Object> messages = [
      locale.helpStatistics0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/statistics_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpStatistics1,
      locale.helpStatistics2,
      locale.helpStatistics3,
      locale.helpStatistics4,
    ];

    return StatisticsHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
