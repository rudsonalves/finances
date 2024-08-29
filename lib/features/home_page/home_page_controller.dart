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

import 'package:flutter/material.dart';

import '../../common/current_models/current_account.dart';
import '../../common/current_models/current_user.dart';
import '../../common/models/account_db_model.dart';
import '../../locator.dart';
import '../../repositories/transaction/abstract_transaction_repository.dart';
import './home_page_state.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/transaction_db_model.dart';
import '../../repositories/category/abstract_category_repository.dart';
import 'balance_card/balance_card_controller.dart';

class HomePageController extends ChangeNotifier {
  // controller state
  HomePageState _state = HomePageStateInitial();
  // last date from controller getTransactions
  late ExtendedDate _lastDate;
  // true if have more transactions in database
  bool _haveMoreTransactions = true;
  // a redraw flag
  bool _redraw = false;
  // list of transactions in display
  final List<TransactionDbModel> _transactions = [];
  // maximum number of transactions to be popped from the database
  int maxTransactions = 35;
  // instace of TransactionRepository
  final _transactionsRepository = locator<AbstractTransactionRepository>();
  // instance of CurrentAccount
  final _currentAccount = locator<CurrentAccount>();

  String _filterText = '';
  bool _filterIsDescription = true;
  int _filterCategoryId = 0;
  final isFiltred$ = ValueNotifier<bool>(false);

  String get filterText => _filterText;
  bool get filterIsDescription => _filterIsDescription;
  int get filterCategoryId => _filterCategoryId;
  bool get isFiltred => isFiltred$.value;

  // Default constructor
  HomePageController();

  // true if have more transactions in database
  bool get haveMoreTransactions => _haveMoreTransactions;

  HomePageState get state => _state;

  Map<String, int> get cacheDescriptions {
    Map<String, int> descMap = {};

    for (final transaction in _transactions) {
      descMap[transaction.transDescription] = transaction.transCategoryId;
    }

    return descMap;
  }

  @override
  void dispose() {
    isFiltred$.dispose();
    super.dispose();
  }

  List<TransactionDbModel> get transactions => _transactions;

  bool get redraw => _redraw;

  void setRedraw() {
    _redraw = true;
  }

  void makeRedraw() {
    if (_redraw) {
      _redraw = false;
      getTransactions();
    }
  }

  void _changeState(HomePageState newState) {
    _state = newState;
    notifyListeners();
  }

  void init() {
    // set state as HomePageStateSuccess
    _state = HomePageStateSuccess();

    // start maxTransactions
    final userMaxTransactions = locator<CurrentUser>().userMaxTransactions;
    maxTransactions = userMaxTransactions < 25 ? 25 : userMaxTransactions;

    // start _lastDate
    _lastDate = _initialLastDate();

    // get transactions
    getTransactions();
  }

  ExtendedDate _initialLastDate() {
    // Start a _lastDate with a date after today. This is necessary because
    // getTransactions returns transactions < _lastDate and not <=
    final date = ExtendedDate.nowDate().add(const Duration(days: 1));
    final futureTransactions =
        locator<BalanceCardController>().futureTransactions;
    switch (futureTransactions) {
      case FutureTrans.hide:
        return date;
      case FutureTrans.week:
        return date.nextWeek();
      case FutureTrans.month:
        return date.nextMonth();
      case FutureTrans.year:
        return date.nextYear();
    }
  }

  Future<void> getTransactions([bool next = false]) async {
    _changeState(HomePageStateLoading());
    try {
      if (!next) {
        _transactions.clear();
        _lastDate = _initialLastDate();
      }

      await locator<AbstractCategoryRepository>().init();
      final accountId = _currentAccount.accountId!;

      // get the next maxTransactions transactions before _lastdate
      final newTrans = await _transactionsRepository.getNFromDate(
        startDate: _lastDate,
        accountId: accountId,
        maxTransactions: maxTransactions,
      );

      if (newTrans.isNotEmpty) {
        _transactions.addAll(newTrans);
        _lastDate = newTrans.last.transDate;
      } else {
        _lastDate = _initialLastDate();
      }

      _haveMoreTransactions = newTrans.length == maxTransactions;

      _changeState(HomePageStateSuccess());
    } catch (err) {
      log('HomePageController.getTransactions: $err');
      _changeState(HomePageStateError());
    }
  }

  Future<void> changeCurrentAccount(AccountDbModel account) async {
    locator<CurrentAccount>().changeCurrenteAccount(account);
    locator<BalanceCardController>().getBalance();
    getTransactions();
  }

  Future<void> setFilterValues({
    required String text,
    required bool isDescription,
  }) async {
    _filterText = text;
    _filterIsDescription = isDescription;
    _filterCategoryId = !isDescription
        ? locator.get<AbstractCategoryRepository>().getIdByName(_filterText)
        : 0;
    isFiltred$.value = true;
    getTransactions();
  }

  Future<void> cleanFilterValues() async {
    _filterText = '';
    _filterIsDescription = false;
    _filterCategoryId = 0;
    isFiltred$.value = false;
    getTransactions();
  }

  List<TransactionDbModel> filterTransactions() {
    List<TransactionDbModel> transactions = [];

    if (filterText.isNotEmpty) {
      for (final trans in _transactions) {
        if (filterIsDescription) {
          if (trans.transDescription
              .toLowerCase()
              .contains(filterText.toLowerCase())) {
            transactions.add(trans);
          }
        } else {
          if (trans.transCategoryId == filterCategoryId) {
            transactions.add(trans);
          }
        }
      }
    } else {
      transactions = _transactions;
    }
    return transactions;
  }
}
