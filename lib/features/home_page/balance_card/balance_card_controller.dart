import 'package:finances/features/home_page/home_page_controller.dart';
import 'package:flutter/material.dart';

import '../../../common/current_models/current_balance.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/models/account_db_model.dart';
import '../../../locator.dart';
import '../../../repositories/account/account_repository.dart';
import './balance_cart_state.dart';
import '../../../common/models/card_balance_model.dart';
import '../../../repositories/transaction/transaction_repository.dart';

enum FutureTrans {
  hide,
  week,
  month,
  year,
}

class BalanceCardController extends ChangeNotifier {
  final transactionRepository = locator.get<TransactionRepository>();
  final accountRepository = locator.get<AccountRepository>();
  ExtendedDate _balanceDate = ExtendedDate.nowDate();
  bool _transStatusCheck = false;

  bool get transStatusCheck => _transStatusCheck;

  FutureTrans _futureTransactions = FutureTrans.week;

  FutureTrans get futureTransactions => _futureTransactions;

  BalanceCardController();

  BalanceCardState _state = BalanceCardStateInitial();

  BalanceCardState get state => _state;

  ExtendedDate get balanceDate => _balanceDate;

  List<AccountDbModel> get accountsList => accountRepository.accountsList;

  Map<int, AccountDbModel> get accountsMap => accountRepository.accountsMap;

  bool _isRedrawSheduled = false;

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
      await locator.get<CurrentBalance>().start();
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
    Future.delayed(const Duration(milliseconds: 50));
    changeState(BalanceCardStateSuccess());
  }

  Future<void> changeFutureTransactions(FutureTrans newFutureTrans) async {
    changeState(BalanceCardStateLoading());
    _futureTransactions = newFutureTrans;
    Future.delayed(const Duration(milliseconds: 50));
    changeState(BalanceCardStateSuccess());
    locator.get<HomePageController>().getTransactions();
  }

  bool isFutureTrans(FutureTrans futureTrans) {
    return _futureTransactions == futureTrans;
  }
}
