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

class TransactionsCardHelp implements PageModel {
  final String _title;

  final List<Object> _messages;

  TransactionsCardHelp(this._title, this._messages);

  static TransactionsCardHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpTransactionsCardTitle;
    final List<Object> messages = [
      locale.helpTransactionsCard0,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: Image.asset(
                'assets/images/transaction_card_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpTransactionsCard1,
      locale.helpTransactionsCard2,
      locale.helpTransactionsCard3,
      locale.helpTransactionsCard4,
      locale.helpTransactionsCard5,
      locale.helpTransactionsCard6,
    ];

    return TransactionsCardHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
