import 'dart:developer';

import 'package:flutter/material.dart';

import '../../common/constants/app_constants.dart';
import '../../common/current_models/current_account.dart';
import '../../common/extensions/money_masked_text_controller.dart';
import '../../common/models/account_db_model.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/transaction_db_model.dart';
import '../../locator.dart';
import '../../manager/transaction_manager.dart';
import '../../manager/transfer_manager.dart';
import '../../repositories/account/abstract_account_repository.dart';
import '../../repositories/category/abstract_category_repository.dart';
import '../home_page/home_page_controller.dart';
import './transaction_state.dart';

class TransactionController extends ChangeNotifier {
  final _categoryRepository = locator<AbstractCategoryRepository>();
  final _accountsMap = locator<AbstractAccountRepository>().accountsMap;
  final _amount = getMoneyMaskedTextController(0.0);
  final _description = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _category = TextEditingController();
  final _installments = TextEditingController();

  int? _categoryId;
  bool _income = false;
  bool _repeat = false;
  TransactionDbModel? _transaction;
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
  int? get categoryId => _categoryId;
  bool get isTransfer => _categoryId == TRANSFER_CATEGORY_ID;

  bool get income => _income;
  bool get repeat => _repeat;

  AccountDbModel get originAccount => _accountsMap[_originAccountId]!;
  AccountDbModel? get destinyAccount => _accountsMap[_destinyAccountId];

  Map<int, AccountDbModel> get accountsMap => _accountsMap;

  TransactionState get state => _state;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoriesNames =>
      _categoryRepository.categoriesMap.keys.toList();

  void _changeState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init(TransactionDbModel? transaction) async {
    _changeState(TransactionStateLoading());

    try {
      await _categoryRepository.init();

      if (transaction != null) {
        if (!_accountsMap.containsKey(transaction.transAccountId)) {
          throw StateError(
            'Account ${transaction.transAccountId} not found.',
          );
        }

        _originAccountId = transaction.transAccountId;

        if (transaction.transTransferId != null) {
          final transfer =
              await TransferManager.getId(transaction.transTransferId!);

          if (transfer == null) {
            throw StateError(
              'Transfer ${transaction.transTransferId} not found.',
            );
          }

          _destinyAccountId = transfer.transferTransId0 == transaction.transId
              ? transfer.transferAccount1
              : transfer.transferAccount0;
        }

        _amount.text = transaction.transValue.toStringAsFixed(2);
        _description.text = transaction.transDescription;
        _date.text = transaction.transDate.toIso8601String();

        final CategoryDbModel category =
            _categoryRepository.getCategoryId(transaction.transCategoryId);
        _setCategory(category);

        _transaction = transaction;
      }

      _changeState(TransactionStateSuccess());
    } catch (err) {
      log('TransactionController.init: $err');
      _changeState(TransactionStateError());
    }
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

  void setDestinyAccountId(int? id) {
    _changeState(TransactionStateLoading());

    if (id == _originAccountId) {
      log('Destiny account id must be different of origin account id');
      _changeState(TransactionStateSuccess());
      return;
    }
    _destinyAccountId = id;
    _changeState(TransactionStateSuccess());
  }

  void setOriginAccountId(int id) async {
    _changeState(TransactionStateLoading());

    _originAccountId = id;

    if (_destinyAccountId == id) {
      _destinyAccountId = null;
    }
    _changeState(TransactionStateSuccess());
  }

  void setCategoryByModel(CategoryDbModel category) {
    _changeState(TransactionStateLoading());
    _setCategory(category);
    _changeState(TransactionStateSuccess());
  }

  void setCategoryByDescription(String description) {
    try {
      _changeState(TransactionStateLoading());

      int? categoryId =
          locator<HomePageController>().cacheDescriptions[description];
      if (categoryId != null) {
        final category = _categoryRepository.getCategoryId(categoryId);
        _setCategory(category);
      }
      _changeState(TransactionStateSuccess());
    } catch (err) {
      log('TransactionController.setCategoryByDescription $err');
      _changeState(TransactionStateError());
    }
  }

  void setCategoryById(int id) {
    try {
      _changeState(TransactionStateLoading());
      final category = _categoryRepository.getCategoryId(id);
      _setCategory(category);
      _changeState(TransactionStateSuccess());
    } catch (err) {
      log('TransactionController.setCategoryById: $err');
      _changeState(TransactionStateError());
    }
  }

  void setCategoryByName(String? categoryName) {
    if (categoryName == null) return;
    try {
      _changeState(TransactionStateLoading());
      final category = _categoryRepository.categoriesMap[categoryName];
      _setCategory(category!);
      _changeState(TransactionStateSuccess());
    } catch (err) {
      log('setCategoryByName.setCategoryById: $err');
      _changeState(TransactionStateError());
    }
  }

  void _setCategory(CategoryDbModel category) {
    _categoryId = category.categoryId;
    _category.text = category.categoryName;
    _income = category.categoryIsIncome;
  }

  void setIncome(bool value) {
    _changeState(TransactionStateLoading());
    _income = value;
    _changeState(TransactionStateSuccess());
  }

  void toogleIncome() {
    _changeState(TransactionStateLoading());
    _income = !_income;
    _changeState(TransactionStateSuccess());
  }

  void toogleRepeat() {
    _changeState(TransactionStateLoading());
    _repeat = !_repeat;
    _changeState(TransactionStateSuccess());
  }

  Future<void> addCategory(CategoryDbModel category) async {
    try {
      _changeState(TransactionStateLoading());
      await _categoryRepository.addCategory(category);
      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
  }

  Future<void> addTransactionsAction(
    BuildContext context, {
    required bool income,
    required bool repeat,
  }) async {
    _changeState(TransactionStateLoading());

    try {
      double value = _amount.numberValue;
      value = income ? value.abs() : -value.abs();

      AccountDbModel? destinyAccount;

      if (_destinyAccountId != null) {
        destinyAccount = _accountsMap[_destinyAccountId!]!;
      }

      final TransactionDbModel transaction = TransactionDbModel(
        transId: _transaction?.transId,
        transAccountId: _originAccountId,
        transDescription: _description.text,
        transCategoryId: _categoryRepository.getIdByName(_category.text),
        transValue: value,
        transStatus: TransStatus.transactionNotChecked,
        transTransferId: _transaction?.transTransferId,
        transDate: ExtendedDate.parse(_date.text),
      );

      int? numberOfRepetitions;
      if (repeat) {
        final String installmentsText =
            _installments.text.replaceAll('x ', '').trim();

        numberOfRepetitions = int.tryParse(installmentsText);

        if (numberOfRepetitions == null || numberOfRepetitions <= 0) {
          throw FormatException(
            'The number of installments must be greater than zero.',
          );
        }
      }

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
              await TransferManager.add(
                transOrigin: newTrans,
                accountDestinyId: destinyAccount.accountId!,
              );
            }
          } else {
            await TransferManager.add(
              transOrigin: transaction,
              accountDestinyId: destinyAccount.accountId!,
            );
          }
        } else {
          await TransferManager.update(
            newTransaction: transaction,
            accountDestinyId: destinyAccount.accountId!,
          );
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
              await TransactionManager.addNew(newTrans);
            }
          } else {
            await TransactionManager.addNew(transaction);
          }
        } else {
          await TransactionManager.updateTransaction(transaction);
        }
      }

      _changeState(TransactionStateSuccess());

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (err) {
      log('TransactionController.addTransactionsAction: $err');
      _changeState(TransactionStateError());
    }
  }
}
