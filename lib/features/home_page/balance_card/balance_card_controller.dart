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

import '../../../common/current_models/current_balance.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/models/account_db_model.dart';
import '../../../locator.dart';
import '../../../repositories/account/abstract_account_repository.dart';
import '../home_page_controller.dart';
import './balance_cart_state.dart';
import '../../../common/models/card_balance_model.dart';
import '../../../repositories/transaction/abstract_transaction_repository.dart';

enum FutureTrans {
  hide,
  week,
  month,
  year,
}

class BalanceCardController extends ChangeNotifier {
  BalanceCardController();

  final transactionRepository = locator<AbstractTransactionRepository>();
  final accountRepository = locator<AbstractAccountRepository>();
  ExtendedDate _balanceDate = ExtendedDate.nowDate();
  bool _transStatusCheck = false;
  FutureTrans _futureTransactions = FutureTrans.week;
  BalanceCardState _state = BalanceCardStateInitial();
  bool _isRedrawSheduled = false;

  bool get transStatusCheck => _transStatusCheck;

  FutureTrans get futureTransactions => _futureTransactions;

  BalanceCardState get state => _state;

  ExtendedDate get balanceDate => _balanceDate;

  List<AccountDbModel> get accountsList => accountRepository.accountsList;

  Map<int, AccountDbModel> get accountsMap => accountRepository.accountsMap;

  bool _redraw = false;
  bool get redraw => _redraw;

  void setRedraw() {
    _redraw = true;
  }

  void makeRedraw() {
    if (_redraw) {
      _redraw = false;
      getBalance();
    }
  }

  void requestRedraw() {
    if (!_isRedrawSheduled) {
      _isRedrawSheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _isRedrawSheduled = false;
        notifyListeners();
      });
    }
  }

  final CardBalanceModel _cardBalance = CardBalanceModel(
    incomes: 0.0,
    expanses: 0.0,
  );

  CardBalanceModel get balance => _cardBalance;

  void changeState(BalanceCardState newState) {
    _state = newState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> getBalance() async {
    changeState(BalanceCardStateLoading());
    try {
      await transactionRepository.getCardBalance(
        cardBalance: _cardBalance,
        date: _balanceDate,
      );
      await locator<CurrentBalance>().start();
      changeState(BalanceCardStateSuccess());
    } catch (err) {
      changeState(BalanceCardStateError());
    }
  }

  void setBalanceDate(ExtendedDate date) {
    _balanceDate = date;
    getBalance();
  }

  Future<void> toggleTransStatusCheck() async {
    changeState(BalanceCardStateLoading());
    _transStatusCheck = !_transStatusCheck;
    await Future.delayed(const Duration(milliseconds: 50));
    changeState(BalanceCardStateSuccess());
  }

  Future<void> changeFutureTransactions(FutureTrans newFutureTrans) async {
    changeState(BalanceCardStateLoading());
    _futureTransactions = newFutureTrans;
    await Future.delayed(const Duration(milliseconds: 50));
    changeState(BalanceCardStateSuccess());
    locator<HomePageController>().getTransactions();
  }

  bool isFutureTrans(FutureTrans futureTrans) {
    return _futureTransactions == futureTrans;
  }

  void previousMonth() {
    final newDate = _balanceDate.previousMonth();
    setBalanceDate(newDate);
  }

  void nextMonth() {
    final newDate = _balanceDate.nextMonth();
    setBalanceDate(newDate);
  }
}
