import 'package:flutter/material.dart';

import '../../../common/current_models/current_balance.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/models/account_db_model.dart';
import '../../../locator.dart';
import '../../../repositories/account/account_repository.dart';
import './balance_cart_state.dart';
import '../../../common/models/card_balance_model.dart';
import '../../../repositories/transaction/transaction_repository.dart';

class BalanceCardController extends ChangeNotifier {
  final transactionRepository = locator.get<TransactionRepository>();
  final accountRepository = locator.get<AccountRepository>();
  ExtendedDate _balanceDate = ExtendedDate(1980, 1, 1);

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
}
