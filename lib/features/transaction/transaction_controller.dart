import 'package:flutter/material.dart';

import '../../common/current_models/current_account.dart';
import '../../common/models/account_db_model.dart';
import '../../locator.dart';
import '../../repositories/transfer_repository/abstract_transfer_repository.dart';
import './transaction_state.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../repositories/category/abstract_category_repository.dart';
import '../../store/managers/transactions_manager.dart';

class TransactionController extends ChangeNotifier {
  final _categoryRepository = locator<AbstractCategoryRepository>();
  int _originAccountId = locator<CurrentAccount>().accountId!;
  int? _destinationAccountId;

  int? get destAccountId => _destinationAccountId;

  void setDestAccountId(int? id) => _destinationAccountId = id;
  void setOriginAccount(int id) => _originAccountId = id;

  TransactionState _state = TransactionStateInitial();

  TransactionState get state => _state;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoriesNames =>
      _categoryRepository.categoriesMap.keys.toList();

  void _changeState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  set accountId(int id) => _originAccountId = id;

  Future<void> init() async {
    _changeState(TransactionStateLoading());
    await _categoryRepository.init();
    _destinationAccountId = null;

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
    await TransactionsManager.addTransaction(
      transaction: transaction,
      account: account,
    );
  }

  Future<void> updateTransactions({
    required TransactionDbModel transaction,
    AccountDbModel? account,
  }) async {
    await TransactionsManager.updateTransaction(
      transaction: transaction,
      account: account,
    );
  }

  Future<void> getTransferAccountName({
    required TransactionDbModel transaction,
    int? originAccountId,
  }) async {
    _changeState(TransactionStateLoading());
    try {
      if (originAccountId != null) {
        setOriginAccount(originAccountId);
      }
      int? transferId = transaction.transTransferId;
      if (transferId == null) return;

      final transfer =
          await locator<AbstractTransferRepository>().getTransferId(transferId);

      _destinationAccountId = transfer!.transferAccount0 == _originAccountId
          ? transfer.transferAccount1
          : transfer.transferAccount0;

      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
  }
}
