import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../locator.dart';
import 'account_state.dart';
import '../../common/models/account_db_model.dart';
import '../../repositories/account/account_repository.dart';
import '../../store/managers/account_manager.dart';

class AccountController extends ChangeNotifier {
  final accountRepository = locator<AccountRepository>();

  final List<double> _balances = [];

  List<AccountDbModel> get accounts => accountRepository.accountsList;

  List<double> get balances => _balances;

  double get totalBalance =>
      _balances.fold(0, (previousValue, element) => previousValue + element);

  AccountState _state = AccountStateInitial();

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
      for (AccountDbModel account in accountRepository.accountsList) {
        final balance = await AccountManager.getAccountTodayBalance(account);
        _balances.add(balance.balanceClose);
      }
      // await Future.delayed(const Duration(microseconds: 50));
      _changeState(AccountStateSuccess());
      return;
    } catch (err) {
      log('Error: AccountController Error: $err');
      _changeState(AccountStateError());
      return;
    }
  }
}
