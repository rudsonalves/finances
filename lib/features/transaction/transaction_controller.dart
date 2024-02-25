import 'package:flutter/material.dart';

import '../../common/current_models/current_account.dart';
import '../../common/models/account_db_model.dart';
import '../../locator.dart';
import '../../repositories/transaction/abstract_transaction_repository.dart';
import '../../repositories/transfer/abstract_transfer_repository.dart';
import './transaction_state.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../repositories/category/abstract_category_repository.dart';

class TransactionController extends ChangeNotifier {
  final _transactionRepository = locator<AbstractTransactionRepository>();
  final _transferRepository = locator<AbstractTransferRepository>();
  final _categoryRepository = locator<AbstractCategoryRepository>();
  int _currentAccountId = locator<CurrentAccount>().accountId!;
  int? _destinyAccountId;

  int? get destAccountId => _destinyAccountId;

  void setDestAccountId(int? id) => _destinyAccountId = id;
  void setOriginAccount(int id) => _currentAccountId = id;

  TransactionState _state = TransactionStateInitial();

  TransactionState get state => _state;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoriesNames =>
      _categoryRepository.categoriesMap.keys.toList();

  void _changeState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  // set accountId(int id) => _originAccountId = id;

  Future<void> init() async {
    _changeState(TransactionStateLoading());
    await _categoryRepository.init();
    _destinyAccountId = null;

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

  Future<void> addTransactions({
    required TransactionDbModel transaction,
    AccountDbModel? account,
  }) async {
    await _transactionRepository.addNewTransaction(transaction);
  }

  Future<void> updateTransactions({
    required TransactionDbModel transaction,
    AccountDbModel? account,
  }) async {
    await _transactionRepository.updateTransaction(transaction);
  }

  Future<void> getTransferAccountName({
    required TransactionDbModel transaction,
  }) async {
    _changeState(TransactionStateLoading());
    try {
      int? transferId = transaction.transTransferId;
      if (transferId == null) return;

      final transfer = await _transferRepository.getTransferById(transferId);

      _destinyAccountId = transfer!.transferAccountId0 == _currentAccountId
          ? transfer.transferAccountId1
          : transfer.transferAccountId0;

      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
  }
}
