import 'package:flutter/material.dart';

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

  HomePageState _state = HomePageStateInitial();

  HomePageState get state => _state;

  ExtendedDate? _lastDate;

  ExtendedDate? get lastDate => _lastDate;

  List<TransactionDbModel> _transactions = [];

  final Map<String, int> _cacheDescriptions = {};

  Map<String, int> get cacheDescriptions => _cacheDescriptions;

  List<TransactionDbModel> get transactions => _transactions;

  int maxTransactions = 30;

  void _changeState(HomePageState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> getTransactions() async {
    _changeState(HomePageStateLoading());
    try {
      await locator.get<CategoryRepository>().init();
      _transactions = await TransactionsManager.getNTransFromDate(
        maxItens: maxTransactions,
      );
      await _updateLastDate();
      _changeState(HomePageStateSuccess());
    } catch (err) {
      _changeState(HomePageStateError());
    }
  }

  Future<void> changeCurrentAccount(AccountDbModel account) async {
    locator.get<CurrentAccount>().changeCurrenteAccount(account);
    locator.get<BalanceCardController>().getBalance();
    getTransactions();
  }

  Future<void> _updateLastDate() async {
    _lastDate = _transactions.last.transDate.onlyDate;
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
