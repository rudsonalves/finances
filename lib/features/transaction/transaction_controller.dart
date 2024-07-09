// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import 'package:flutter/material.dart';

import '../../common/constants/app_constants.dart';
import '../../common/current_models/current_account.dart';
import '../../common/extensions/money_masked_text_controller.dart';
import '../../common/models/account_db_model.dart';
import '../../common/models/extends_date.dart';
import '../../locator.dart';
import '../../manager/transaction_manager.dart';
import '../../manager/transfer_manager.dart';
import '../../repositories/account/abstract_account_repository.dart';
// import '../../repositories/transfer/abstract_transfer_repository.dart';
import '../home_page/home_page_controller.dart';
import './transaction_state.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../repositories/category/abstract_category_repository.dart';

/// Manages the state and logic for transaction operations in the app.
///
/// Utilizes repositories for transferring, categorizing, and accounting data,
/// and provides a reactive interface for UI components to interact with
/// transaction data.
class TransactionController extends ChangeNotifier {
  // /// Repository for handling transfer-related operations.
  // final _transferRepository = locator<AbstractTransferRepository>();

  /// Repository for accessing and managing categories.
  final _categoryRepository = locator<AbstractCategoryRepository>();

  /// Map of accounts available in the AccountRepository.
  final _accountsMap = locator<AbstractAccountRepository>().accountsMap;

  /// Controller for the transaction amount, initialized to 0.0.
  final _amount = getMoneyMaskedTextController(0.0);

  /// Controller for the transaction description text.
  final _description = TextEditingController();

  /// Controller for the transaction date text.
  final _date = TextEditingController();

  /// Controller for the transaction time text.
  final _time = TextEditingController();

  /// Controller for the transaction category name text.
  final _category = TextEditingController();

  /// Controller for the number of transaction installments.
  final _installments = TextEditingController();

  /// The current category ID selected for the transaction.
  int? _categoryId;

  /// Indicates whether the transaction is an income.
  bool _income = false;

  /// Indicates whether the transaction should be repeated.
  bool _repeat = false;

  /// The transaction currently being edited, if any.
  TransactionDbModel? _transaction;

  /// The account ID from which the transaction originates.
  int _originAccountId = locator<CurrentAccount>().accountId!;
  int? _destinyAccountId;

  /// The destination account ID for the transaction if it's a transfer.
  TransactionState _state = TransactionStateInitial();

  /// The current state of the transaction page, for UI control.

  // getters
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

  /// Updates the state of the transaction controller.
  ///
  /// This method sets the controller's current state to the new state provided
  /// and notifies all the listeners about the state change.
  ///
  /// [newState] is the new state to which the controller will be set. It must
  /// be an instance of [TransactionState].
  void _changeState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Initializes the transaction controller with an optional transaction.
  ///
  /// This method sets the controller's state to loading, initializes the
  /// category repository, and then processes the provided transaction if
  /// it is not null. The processing includes checking if the transaction
  /// is a transfer and updating the controller's properties with the
  /// transaction's details. Finally, the controller's state is set to
  /// success.
  ///
  /// [transaction] is an optional [TransactionDbModel] that, if provided,
  /// will be used to pre-populate the controller's data fields. This is
  /// useful for editing an existing transaction. If [transaction] is null,
  /// the controller initializes for a new transaction.
  ///
  /// Note: This method should be called when the controller is first created
  /// to set it up properly, regardless of whether a new transaction is being
  /// created or an existing one is being edited.
  Future<void> init(TransactionDbModel? transaction) async {
    _changeState(TransactionStateLoading());
    // Start CategoryRepository if necessary
    await _categoryRepository.init();

    // Check if transaction is a transfer
    if (transaction != null) {
      if (transaction.transTransferId != null) {
        // Get transfer
        final transfer =
            await TransferManager.getId(transaction.transTransferId!);
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
      _transaction = transaction;
    }

    _changeState(TransactionStateSuccess());
  }

  /// Releases the resources used by the controller.
  ///
  /// This method is called when the controller is no longer needed. It disposes
  /// of the TextEditingController instances to free up resources and prevent
  /// memory leaks. Always call `super.dispose()` at the end to ensure the
  /// parent class can also clean up its resources.
  ///
  /// It's important to dispose of TextEditingController instances to ensure
  /// they are properly cleaned up when the widget is removed from the widget
  /// tree. Failing to do so can lead to memory leaks and other resource
  /// management issues.
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

  /// Updates the destination account ID for the transaction.
  ///
  /// This method first changes the state to [TransactionStateLoading] to
  /// indicate that an update operation is in progress. It checks if the
  /// provided [id] is different from the current origin account ID to ensure
  /// that the destination and origin account IDs are not the same. If the [id]
  /// is the same as the origin account ID, it logs a message and does not
  /// update the destination account ID. Otherwise, it updates the destination
  /// account ID and changes the state to [TransactionStateSuccess] to indicate
  /// the operation was successful.
  ///
  /// [id] is the new ID for the destination account. It can be `null`, which
  /// indicates that the destination account is being cleared. If [id] is the
  /// same as the origin account ID, the update is not performed to avoid
  /// conflicts.
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

  /// Sets the origin account ID for the transaction.
  ///
  /// This method initiates by transitioning the state to
  /// [TransactionStateLoading] to reflect the beginning of an update operation.
  /// It then updates the origin account ID with the provided [id]. If the new
  /// origin account ID matches the currently set destination account ID, the
  /// destination account ID is cleared to ensure that the origin and
  /// destination accounts are not the same, preserving transaction integrity.
  /// Finally, the state is set to [TransactionStateSuccess] to indicate the
  /// completion of the operation.
  ///
  /// The asynchronous signature allows for future expansion where waiting for
  /// external operations (such as data validation or fetching additional
  /// information) might be necessary before fully committing the account ID
  /// change.
  ///
  /// [id] is the new ID to be set for the origin account. It must be a valid
  /// account ID. If [id] matches the current destination account ID, the latter
  /// is reset to `null` to avoid conflicts between the origin and destination
  /// accounts.
  void setOriginAccountId(int id) async {
    _changeState(TransactionStateLoading());
    // await Future.delayed(const Duration(milliseconds: 50));
    _originAccountId = id;

    if (_destinyAccountId == id) {
      _destinyAccountId = null;
    }
    _changeState(TransactionStateSuccess());
  }

  /// Sets the transaction's category based on the provided [category] model.
  ///
  /// Initiates by setting the state to [TransactionStateLoading] to indicate
  /// an operation is in progress. It then updates the transaction's category
  /// by invoking the `_setCategory` method with the provided [category] model.
  /// Upon successful update, the state is transitioned to
  /// [TransactionStateSuccess].
  ///
  /// [category] is an instance of [CategoryDbModel] representing the new
  /// category to be associated with the transaction.
  void setCategoryByModel(CategoryDbModel category) {
    _changeState(TransactionStateLoading());
    _setCategory(category);
    _changeState(TransactionStateSuccess());
  }

  /// Sets the transaction category based on the provided description.
  ///
  /// This method attempts to match the provided [description] with a category
  /// ID from the cache managed by [HomePageController]. If a match is found, it
  /// updates the transaction's category using the `_setCategory` method with
  /// the corresponding [CategoryDbModel]. The state transitions to
  /// [TransactionStateLoading] at the start and to [TransactionStateSuccess]
  /// upon successful category assignment. If the description does not match any
  /// category or an error occurs, the state is set to [TransactionStateError].
  ///
  /// [description] is a string representing the category's description. It is
  /// used to look up the category ID and then fetch the corresponding category
  /// model from the category repository.
  ///
  /// Catches and logs any errors encountered during the category lookup or
  /// update process.
  void setCategoryByDescription(String description) {
    try {
      _changeState(TransactionStateLoading());
      // await Future.delayed(const Duration(milliseconds: 50));
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

  /// Sets the transaction's category using a category ID.
  ///
  /// This method initiates the update process by changing the state to
  /// [TransactionStateLoading]. It then retrieves the category corresponding
  /// to the provided [id] from the category repository. If successful, the
  /// category is updated through the `_setCategory` method, and the state is
  /// set to [TransactionStateSuccess]. In case of any errors during the
  /// process, an error message is logged, and the state is updated to
  /// [TransactionStateError], indicating the failure of the operation.
  ///
  /// [id] is the unique identifier of the category to be associated with
  /// the transaction. It must correspond to a valid category ID within the
  /// category repository. If the category retrieval fails, the operation is
  /// considered unsuccessful, and appropriate error handling is performed.
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

  /// Sets the transaction's category using the given category name.
  ///
  /// It initiates by marking the process state as loading. If the
  /// [categoryName] is found within the category repository, the transaction's
  /// category is updated accordingly. The state transitions to success or error
  /// based on the operation outcome.
  ///
  /// - [categoryName] is the name used to find the corresponding category.
  /// If it is `null` or if no matching category is found, the method exits
  /// early without changing the state.
  ///
  /// Throws:
  /// - An error is logged, and the state is set to [TransactionStateError]
  /// if any exception occurs during the operation.
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

  /// Updates the current category details.
  ///
  /// This internal method is utilized to set the transaction's category
  /// based on the provided [category] object. It updates the category ID,
  /// category name, and the income flag to reflect the selected category's
  /// attributes.
  ///
  /// - [category] is an instance of [CategoryDbModel] representing the
  /// new category to be assigned to the transaction. This includes updating
  /// the category identifier, name, and its income status.
  void _setCategory(CategoryDbModel category) {
    _categoryId = category.categoryId;
    _category.text = category.categoryName;
    _income = category.categoryIsIncome;
  }

  /// Sets the income status for the current transaction.
  ///
  /// Marks the transaction process as loading, updates the transaction's income
  /// status to the specified [value], and then indicates success. This method
  /// is used to toggle whether the transaction is considered an income or an
  /// expense.
  ///
  /// - [value]: A boolean indicating the new income status. `true` signifies
  ///   the transaction is an income, while `false` indicates it is an expense.
  void setIncome(bool value) {
    _changeState(TransactionStateLoading());
    _income = value;
    _changeState(TransactionStateSuccess());
  }

  /// Toggles the income status of the current transaction.
  ///
  /// This method starts by setting the transaction process state to loading.
  /// It then inverses the current income status of the transaction, effectively
  /// switching between marking it as an income or an expense. Upon successful
  /// toggle, the state is updated to indicate success.
  ///
  /// This function is useful for quickly changing the transaction's financial
  /// nature without specifying the new state directly.
  void toogleIncome() {
    _changeState(TransactionStateLoading());
    _income = !_income;
    _changeState(TransactionStateSuccess());
  }

  /// Toggles the repeat status for the current transaction.
  ///
  /// Initiates the process by marking the state as loading. It then inverts
  /// the current repeat status, allowing the transaction to switch between
  /// being a one-time transaction and a recurring transaction. After toggling,
  /// the state is updated to success to reflect the change.
  ///
  /// This method provides a straightforward way to alter the repetition
  /// behavior of a transaction, enabling or disabling the repeat functionality
  /// as needed.
  void toogleRepeat() {
    _changeState(TransactionStateLoading());
    _repeat = !_repeat;
    _changeState(TransactionStateSuccess());
  }

  /// Adds a new category to the category repository.
  ///
  /// This asynchronous method encapsulates the process of adding a new category.
  /// It begins by marking the operational state as loading. The method then
  /// attempts to add the given [category] to the repository. If successful,
  /// the state transitions to success. In case of failure, catches any thrown
  /// errors and updates the state to error, reflecting the unsuccessful
  /// attempt.
  ///
  /// - [category]: An instance of [CategoryDbModel] representing the category
  ///   to be added to the repository.
  Future<void> addCategory(CategoryDbModel category) async {
    try {
      _changeState(TransactionStateLoading());
      await _categoryRepository.addCategory(category);
      _changeState(TransactionStateSuccess());
    } catch (err) {
      _changeState(TransactionStateError());
    }
  }

  /// Initiates the process of adding or updating a transaction based on the
  /// provided parameters and current state of the controller.
  ///
  /// This method calculates the transaction value based on the [income] flag,
  /// determining the sign of the amount. It then proceeds to create or update a
  /// transaction, potentially handling it as a transfer if a destination
  /// account is specified.
  /// Repetition logic is applied if [repeat] is true, creating multiple
  /// instances of the transaction for recurring transactions. The process
  /// involves several conditional checks and operations, including fetching the
  /// destination account, creating a new transaction model, and invoking the
  /// appropriate repository methods for adding or updating transactions.
  /// Success or failure in adding or updating the transaction leads to
  /// navigation actions or error handling.
  ///
  /// Parameters:
  /// - [context]: The BuildContext for navigation and UI interactions.
  /// - [income]: A boolean indicating whether the transaction is an income.
  /// - [repeat]: A boolean flag to indicate if the transaction should be
  ///             repeated according to the number of installments specified.
  ///
  /// The method leverages several controller attributes to construct the
  /// transaction model and determine the correct course of action for adding or
  /// updating the transaction in the repository. It concludes with navigation
  /// actions based on the operation's outcome.
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
      destinyAccount = _accountsMap[_destinyAccountId!]!;
    }

    // Create transaction
    final TransactionDbModel transaction = TransactionDbModel(
      transId: _transaction?.transId,
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
        navigator.pop(true);
      } else {
        await TransferManager.update(
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
            await TransactionManager.addNew(newTrans);
          }
        } else {
          await TransactionManager.addNew(transaction);
        }
        navigator.pop(true);
      } else {
        await TransactionManager.updateTransaction(transaction);
        navigator.pop(true);
      }
    }
  }
}
