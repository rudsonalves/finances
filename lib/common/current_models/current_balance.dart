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

import '../../locator.dart';
import '../../manager/balance_manager.dart';
import '../models/extends_date.dart';
import 'current_account.dart';
import '../models/balance_db_model.dart';
import '../../repositories/balance/abstract_balance_repository.dart';

class CurrentBalance extends BalanceDbModel {
  CurrentBalance();

  final balanceRepository = locator<AbstractBalanceRepository>();
  final currentAccount = locator<CurrentAccount>();

  Future<void> start() async {
    final balance = await BalanceManager.getClosedBalanceToDate(
      date: ExtendedDate.nowDate(),
      accountId: currentAccount.accountId!,
    );

    setFromBalanceDbModel(balance);
  }

  // replace currentBalance by a passed balance
  void setFromBalanceDbModel(BalanceDbModel? balance) {
    balanceId = balance?.balanceId;
    balanceAccountId = balance?.balanceAccountId;
    balanceDate = balance?.balanceDate;
    balanceOpen = balance?.balanceOpen ?? 0.0;
    balanceClose = balance?.balanceClose ?? 0.0;
  }

  factory CurrentBalance.fromAccountDbModel(BalanceDbModel balance) {
    final newBalance = CurrentBalance();
    newBalance.setFromBalanceDbModel(balance);

    return newBalance;
  }

  // update currentBalance
  Future<void> update() async {
    await balanceRepository.update(this);
  }
}
