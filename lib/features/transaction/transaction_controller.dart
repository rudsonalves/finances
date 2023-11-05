import 'package:flutter/material.dart';

import '../../common/current_models/current_account.dart';
import '../../locator.dart';
import '../../repositories/account/account_repository.dart';
import '../../repositories/transfer_repository/transfer_repository.dart';
import './transaction_state.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../repositories/category/category_repository.dart';
import '../../services/database/managers/transactions_manager.dart';

class TransactionController extends ChangeNotifier {
  final _categoryRepository = locator<CategoryRepository>();

  TransactionState _state = TransactionStateInitial();

  TransactionState get state => _state;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoriesNames =>
      _categoryRepository.categoriesMap.keys.toList();

  void _changeState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    _changeState(TransactionStateLoading());
    await _categoryRepository.init();

    _changeState(TransactionStateSuccess());
  }

  Future<void> addCategory(CategoryDbModel category) async {
    _changeState(TransactionStateLoading());
    try {
      await _categoryRepository.addCategory(category);
      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
  }

  Future<void> addTransactions(TransactionDbModel transaction) async {
    await TransactionsManager.addTransaction(transaction: transaction);
  }

  Future<void> updateTransactions(TransactionDbModel transaction) async {
    await TransactionsManager.updateTransaction(transaction: transaction);
  }

  Future<void> getTransferAccountName({
    required TransactionDbModel transaction,
    required TextEditingController accountController,
  }) async {
    _changeState(TransactionStateLoading());
    try {
      int? transferId = transaction.transTransferId;
      if (transferId == null) return;

      final transfer =
          await locator<TransferRepository>().getTransferId(transferId);

      int currentAccountId = locator<CurrentAccount>().accountId!;
      int accountId = transfer!.transferAccount0 == currentAccountId
          ? transfer.transferAccount1
          : transfer.transferAccount0;
      String accounName =
          locator<AccountRepository>().accountsMap[accountId]!.accountName;
      accountController.text = accounName;
      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
  }
}
