// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

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
