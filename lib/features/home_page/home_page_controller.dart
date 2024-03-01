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
  // cached descriptions for search
  final Map<String, int> _cacheDescriptions = {};
  // controller state
  HomePageState _state = HomePageStateInitial();
  // last date from controller getTransactions
  late ExtendedDate _lastDate;
  // true if have more transactions in database
  bool _haveMoreTransactions = true;
  // FIXME: redraw key. **Adjust the code so that key is no longer needed**
  bool _redraw = false;
  // list of transactions in display
  final List<TransactionDbModel> _transactions = [];
  // maximum number of transactions to be popped from the database
  int maxTransactions = 35;
  // instace of TransactionRepository
  final _transactionsRepository = locator<AbstractTransactionRepository>();
  // instance of CurrentAccount
  final _currentAccount = locator<CurrentAccount>();

  // Default constructor
  HomePageController();

  // true if have more transactions in database
  bool get haveMoreTransactions => _haveMoreTransactions;

  HomePageState get state => _state;

  Map<String, int> get cacheDescriptions => _cacheDescriptions;

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
    log(_state.toString());
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
      final newTrans = await _transactionsRepository.getNTransactionsFromDate(
        startDate: ExtendedDate.now(), //_lastDate,
        accountId: accountId,
        maxTransactions: maxTransactions,
      );

      // for (final trans in newTrans) {
      //   log(' > ${trans.transDescription}');
      // }

      // add newTrans in the _transactions list, update _lastDate and
      // _cacheDescriptions
      /* FIXME: Rethink how to thrat this cache of descriptions. I believe
                it would be more sensible to create the cache only when 
                searching the descrition is required 
      */
      if (newTrans.isNotEmpty) {
        _transactions.addAll(newTrans);
        _lastDate = newTrans.last.transDate;
        _updateCacheDescriptions();
      } else {
        _initialLastDate();
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

  void _updateCacheDescriptions() {
    _cacheDescriptions.clear();
    for (final trans in _transactions) {
      _cacheDescriptions[trans.transDescription] = trans.transCategoryId;
    }
  }
}
