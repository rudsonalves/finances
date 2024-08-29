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

import 'dart:developer';

import 'package:finances/common/models/extends_date.dart';
import 'package:flutter/foundation.dart';

import '../../locator.dart';
import '../../manager/balance_manager.dart';
import 'account_state.dart';
import '../../common/models/account_db_model.dart';
import '../../repositories/account/abstract_account_repository.dart';

class AccountController extends ChangeNotifier {
  final _accountRepository = locator<AbstractAccountRepository>();
  final List<double> _balances = [];
  AccountState _state = AccountStateInitial();

  List<AccountDbModel> get accounts => _accountRepository.accountsList;

  List<double> get balances => _balances;

  double get totalBalance =>
      _balances.fold(0, (previousValue, element) => previousValue + element);

  AccountState get state => _state;

  void _changeState(AccountState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    getAllBalances();
  }

  Future<void> getAllBalances() async {
    _changeState(AccountStateLoading());
    try {
      _balances.clear();
      for (AccountDbModel account in _accountRepository.accountsList) {
        final balance = await BalanceManager.getClosedBalanceToDate(
          date: ExtendedDate.nowDate(),
          accountId: account.accountId!,
        );
        _balances.add(balance?.balanceClose ?? 0.0);
      }
      await Future.delayed(const Duration(microseconds: 50));
      _changeState(AccountStateSuccess());
      return;
    } catch (err) {
      log('Error: AccountController Error: $err');
      _changeState(AccountStateError());
      return;
    }
  }
}
