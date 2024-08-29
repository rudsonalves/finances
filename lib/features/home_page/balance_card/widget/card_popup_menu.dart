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

import '../balance_card_controller.dart';

class CardPopupMenu extends StatelessWidget {
  const CardPopupMenu({
    super.key,
    required this.controller,
    required this.colorScheme,
  });

  final BalanceCardController controller;
  final ColorScheme colorScheme;

  IconData futureTransIcon() {
    switch (controller.futureTransactions) {
      case FutureTrans.hide:
        return Icons.event_busy;
      case FutureTrans.week:
        return Icons.date_range;
      case FutureTrans.month:
        return Icons.calendar_month;
      case FutureTrans.year:
        return Icons.event_available;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'transactionStatus',
          child: ListTile(
            leading: Icon(
              controller.transStatusCheck ? Icons.lock_open : Icons.lock,
              color: colorScheme.primary,
              size: 22,
            ),
            title: Text(
              controller.transStatusCheck
                  ? locale.balanceCardLockTrans
                  : locale.balanceCardUnLockTrans,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'futureTransactions',
          child: PopupMenuButton<FutureTrans>(
            elevation: 10,
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: controller.isFutureTrans(FutureTrans.hide),
                value: FutureTrans.hide,
                child: ListTile(
                  leading: const Icon(Icons.event_busy),
                  title: Text(locale.cardBalanceMenuHide),
                ),
              ),
              CheckedPopupMenuItem(
                checked: controller.isFutureTrans(FutureTrans.week),
                value: FutureTrans.week,
                child: ListTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(locale.cardBalanceMenuWeek),
                ),
              ),
              CheckedPopupMenuItem(
                checked: controller.isFutureTrans(FutureTrans.month),
                value: FutureTrans.month,
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(locale.cardBalanceMenuMonth),
                ),
              ),
              CheckedPopupMenuItem(
                checked: controller.isFutureTrans(FutureTrans.year),
                value: FutureTrans.year,
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text(locale.cardBalanceMenuYear),
                ),
              ),
            ],
            child: ListTile(
              leading: Icon(
                Icons.event,
                color: colorScheme.primary,
              ),
              title: Text(locale.cardBalanceMenuShow),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            onSelected: (value) {
              Navigator.of(context).pop();
              controller.changeFutureTransactions(value);
            },
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'transactionStatus') {
          controller.toggleTransStatusCheck();
        }
      },
      child: Row(
        children: [
          Icon(
            controller.transStatusCheck ? Icons.lock_open : Icons.lock,
            color: colorScheme.onPrimary,
            size: 22,
          ),
          Icon(
            futureTransIcon(),
            color: colorScheme.onPrimary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
