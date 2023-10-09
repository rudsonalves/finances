import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class StatisticsCardHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  StatisticsCardHelp(this._title, this._messages);

  static StatisticsCardHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpStatisticsCardTitle;
    final List<Object> messages = [
      locale.helpStatisticsCard0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/statistics_card_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpStatisticsCard1,
      locale.helpStatisticsCard2,
      locale.helpStatisticsCard3,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/statistics_card_menu_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      ' ➃ Gráfico de movimentação das Receitas, Despesas e Categorias',
    ];

    return StatisticsCardHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
