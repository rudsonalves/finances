import 'package:finances/common/current_models/current_user.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../common/current_models/current_account.dart';
import '../../common/models/account_db_model.dart';
import '../../locator.dart';
import './home_page_state.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/transaction_db_model.dart';
import '../../repositories/balance/balance_repository.dart';
import '../../repositories/category/category_repository.dart';
import '../../services/database/managers/transactions_manager.dart';
import 'balance_card/balance_card_controller.dart';

class HomePageController extends ChangeNotifier {
  HomePageController();
  final logger = Logger();

  HomePageState _state = HomePageStateInitial();

  HomePageState get state => _state;

  ExtendedDate? _lastDate;

  ExtendedDate? get lastDate => _lastDate;

  List<TransactionDbModel> _transactions = [];

  final Map<String, int> _cacheDescriptions = {};

  Map<String, int> get cacheDescriptions => _cacheDescriptions;

  List<TransactionDbModel> get transactions => _transactions;

  int maxTransactions = 35;

  bool _redraw = false;

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
    _state = HomePageStateSuccess();
    maxTransactions = locator<CurrentUser>().userMaxTransactions;
    if (maxTransactions < 25) maxTransactions = 25;
    getTransactions();
  }

  ExtendedDate getInitialDate() {
    final date = ExtendedDate.now();
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

  Future<void> getTransactions() async {
    _changeState(HomePageStateLoading());
    try {
      await locator<CategoryRepository>().init();

      final date = getInitialDate();

      _transactions = await TransactionsManager.getNTransFromDate(
        maxItens: maxTransactions,
        date: date,
      );
      if (_transactions.isNotEmpty) {
        await _updateLastDate();
      } else {
        await _updateLastDate(ExtendedDate.nowDate());
      }

      _changeState(HomePageStateSuccess());
    } catch (err) {
      logger.e(err);
      _changeState(HomePageStateError());
    }
  }

  Future<void> changeCurrentAccount(AccountDbModel account) async {
    locator<CurrentAccount>().changeCurrenteAccount(account);
    locator<BalanceCardController>().getBalance();
    getTransactions();
  }

  Future<void> _updateLastDate([ExtendedDate? date]) async {
    if (date != null) {
      _lastDate = date.onlyDate;
    } else {
      _lastDate = _transactions.last.transDate.onlyDate;
    }
    final balance = await locator
        .get<BalanceRepository>()
        .getBalanceInDate(date: _lastDate!);
    if (balance!.balancePreviousId == null) {
      _lastDate = null;
    }

    _cacheDescriptions.clear();
    for (final trans in _transactions) {
      _cacheDescriptions[trans.transDescription] = trans.transCategoryId;
    }
  }

  Future<void> getNextTransactions([int? more]) async {
    if (_lastDate == null) return;
    List<TransactionDbModel> newsTransactions;
    more ??= maxTransactions;
    newsTransactions = await TransactionsManager.getNTransFromDate(
      maxItens: more,
      date: _lastDate!.previusDay(),
    );
    if (newsTransactions.isEmpty) {
      _lastDate == null;
    }
    _transactions.addAll(newsTransactions);
    await _updateLastDate();
    notifyListeners();
  }
}
