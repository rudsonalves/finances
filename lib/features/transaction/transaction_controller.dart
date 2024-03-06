import 'dart:developer';

import 'package:flutter/material.dart';

import '../../common/current_models/current_account.dart';
import '../../common/extensions/money_masked_text_controller.dart';
import '../../common/models/account_db_model.dart';
import '../../common/models/extends_date.dart';
import '../../locator.dart';
import '../../manager/transaction_manager.dart';
import '../../manager/transfer_manager.dart';
import '../../repositories/account/abstract_account_repository.dart';
import '../../repositories/transfer/abstract_transfer_repository.dart';
import './transaction_state.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../repositories/category/abstract_category_repository.dart';

class TransactionController extends ChangeNotifier {
  final _transferRepository = locator<AbstractTransferRepository>();
  final _categoryRepository = locator<AbstractCategoryRepository>();
  final _accountsMap = locator<AbstractAccountRepository>().accountsMap;

  final _amount = getMoneyMaskedTextController(0.0);
  final _description = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _category = TextEditingController();
  final _installments = TextEditingController();

  TransactionDbModel? _editedTransaction;

  int _originAccountId = locator<CurrentAccount>().accountId!;
  int? _destinyAccountId;
  TransactionState _state = TransactionStateInitial();

  MoneyMaskedTextController get amount => _amount;
  TextEditingController get description => _description;
  TextEditingController get date => _date;
  TextEditingController get time => _time;
  TextEditingController get category => _category;
  TextEditingController get installments => _installments;
  int get originAccountId => _originAccountId;
  int? get destinyAccountId => _destinyAccountId;

  AccountDbModel get originAccount => _accountsMap[_originAccountId]!;
  AccountDbModel? get destinyAccount => _accountsMap[_destinyAccountId];

  Map<int, AccountDbModel> get accountsMap => _accountsMap;

  AccountDbModel accountById(int id) {
    return _accountsMap[id]!;
  }

  void setDestinyAccountId(int? id) {
    if (id == _originAccountId) {
      log('Destiny account id must be different of origin account id');
      return;
    }
    _destinyAccountId = id;
  }

  // int? get destAccountId => _destinyAccountId;
  // void setDestAccountId(int? id) => _destinyAccountId = id;
  // void setOriginAccountId(int id) => _originAccountId = id;

  TransactionState get state => _state;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoriesNames =>
      _categoryRepository.categoriesMap.keys.toList();

  void _changeState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  // set accountId(int id) => _originAccountId = id;

  Future<void> init(TransactionDbModel? transaction) async {
    _changeState(TransactionStateLoading());
    // Start CategoryRepository if necessary
    await _categoryRepository.init();

    // Check if transaction is a transfer
    if (transaction != null) {
      if (transaction.transTransferId != null) {
        // Get transfer
        final transfer =
            await TransferManager.getTransferById(transaction.transTransferId!);
        // Get destiny account
        _destinyAccountId = transfer!.transferTransId0 == transaction.transId
            ? transfer.transferAccount1
            : transfer.transferAccount0;
      }
      // _amount.updateValue(transaction.transValue);
      _amount.text = transaction.transValue.toStringAsFixed(2);
      _description.text = transaction.transDescription;
      _date.text = transaction.transDate.toIso8601String();
      _category.text = _categoryRepository
          .getCategoryId(transaction.transCategoryId)
          .categoryName;
    }

    _editedTransaction = transaction;
    _changeState(TransactionStateSuccess());
  }

  @override
  void dispose() {
    _time.dispose();
    _amount.dispose();
    _description.dispose();
    _date.dispose();
    _category.dispose();
    _installments.dispose();
    super.dispose();
  }

  void setOriginAccountId(int id) async {
    try {
      _changeState(TransactionStateLoading());
      await Future.delayed(const Duration(milliseconds: 50));
      _originAccountId = id;
      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
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
  }) async {
    await TransactionManager.addNewTransaction(transaction);
  }

  Future<void> updateTransactions({
    required TransactionDbModel transaction,
    AccountDbModel? account,
  }) async {
    await TransactionManager.updateTransaction(transaction);
  }

  Future<void> getTransferAccountName({
    required TransactionDbModel transaction,
  }) async {
    _changeState(TransactionStateLoading());
    try {
      int? transferId = transaction.transTransferId;
      if (transferId == null) return;

      final transfer = await _transferRepository.getTransferById(transferId);

      _destinyAccountId = transfer!.transferAccount0 == _originAccountId
          ? transfer.transferAccount1
          : transfer.transferAccount0;

      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
  }

  void addTransactionsAction(
    BuildContext context, {
    required bool income,
    required bool repeat,
  }) async {
    double value = _amount.numberValue;
    value = income ? value.abs() : -value.abs();

    // get destination account
    AccountDbModel? destinyAccount;

    if (_destinyAccountId != null) {
      destinyAccount = accountById(_destinyAccountId!);
    }

    // Create transaction
    final TransactionDbModel transaction = TransactionDbModel(
      transId: _editedTransaction?.transId,
      transAccountId: _originAccountId,
      transDescription: _description.text,
      transCategoryId: _categoryRepository.getIdByName(_category.text),
      transValue: value,
      transStatus: TransStatus.transactionNotChecked,
      transTransferId: null,
      transDate: ExtendedDate.parse(_date.text),
    );

    int? numberOfRepetitions;
    if (repeat) {
      numberOfRepetitions = int.parse(
        _installments.text.replaceAll('x ', ''),
      );
    }

    final navigator = Navigator.of(context);
    // Check for Transfer
    if (destinyAccount != null) {
      if (transaction.transId == null) {
        if (repeat) {
          ExtendedDate date = transaction.transDate;
          for (int count = 1; count <= numberOfRepetitions!; count++) {
            String label = '($count/$numberOfRepetitions)';
            final newTrans = transaction.copy();
            if (count > 1) {
              date = date.nextMonth();
            }
            newTrans.transDescription = '${newTrans.transDescription} $label';
            newTrans.transDate = date;
            await TransferManager.addTranfer(
              transOrigin: newTrans,
              accountDestinyId: destinyAccount.accountId!,
            );
          }
        } else {
          await TransferManager.addTranfer(
            transOrigin: transaction,
            accountDestinyId: destinyAccount.accountId!,
          );
        }
        navigator.pop(true);
      } else {
        await TransferManager.updateTransfer(
          newTransaction: transaction,
          accountDestinyId: destinyAccount.accountId!,
        );

        navigator.pop(true);
      }
    } else {
      if (transaction.transId == null) {
        if (repeat) {
          ExtendedDate date = transaction.transDate;
          for (int count = 1; count <= numberOfRepetitions!; count++) {
            String label = '($count/$numberOfRepetitions)';
            final newTrans = transaction.copy();
            if (count > 1) {
              date = date.nextMonth();
            }
            newTrans.transDescription = '${newTrans.transDescription} $label';
            newTrans.transDate = date;
            await addTransactions(
              transaction: newTrans,
            );
          }
        } else {
          await addTransactions(
            transaction: transaction,
          );
        }
        navigator.pop(true);
      } else {
        await updateTransactions(
          transaction: transaction,
        );
        navigator.pop(true);
      }
    }
  }
}
