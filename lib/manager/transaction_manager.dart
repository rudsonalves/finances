import '../common/models/extends_date.dart';
import '../common/models/transaction_db_model.dart';
import '../locator.dart';
import '../repositories/balance/abstract_balance_repository.dart';
import '../repositories/transaction/abstract_transaction_repository.dart';
import 'balance_manager.dart';

/// Manages transaction operations, including adding and removing transactions.
///
/// This class provides static methods to handle the creation and deletion of
/// transactions within the database. It ensures that balance records are
/// appropriately updated in response to transaction changes.
class TransactionManager {
  /// Private constructor to prevent instantiation.
  TransactionManager._();

  /// Adds a new transaction to the database and adjusts balances accordingly.
  ///
  /// This method creates or retrieves the balance for the transaction's date,
  /// assigns the balance ID to the transaction, inserts the transaction into
  /// the database, and updates subsequent balances to reflect the new
  /// transaction.
  ///
  /// Parameters:
  /// - `transaction`: The `TransactionDbModel` object representing the
  ///   transaction to add.
  ///
  /// The method adjusts the opening and closing balances of all subsequent
  /// balance records after the transaction date to account for the transaction
  /// value.
  static Future<void> addNewTransaction(TransactionDbModel transaction) async {
    // Get or create a balance in the transaction date
    final balance = await BalanceManager.returnBalanceInDate(
      date: transaction.transDate,
      accountId: transaction.transAccountId,
    );

    // Set the balance.balanceId to transBalanceId
    transaction.transBalanceId = balance.balanceId!;

    // insert a new transaction in database
    await locator<AbstractTransactionRepository>()
        .insertTransaction(transaction);

    // update subsequent balances
    await _addAdjustSubsequentBalances(
      date: transaction.transDate,
      value: transaction.transValue,
    );
  }

  /// Internally adjusts subsequent balances after adding a new transaction.
  ///
  /// This helper method updates the opening and closing balances of all balance
  /// records after the specified date to include the value of the added
  /// transaction.
  ///
  /// Parameters:
  /// - `date`: The `ExtendedDate` object representing the date of the
  ///   transaction.
  /// - `value`: The double value of the transaction to adjust the balances by.
  ///
  /// Note: This method is called internally by `addNewTransaction`.
  static Future<void> _addAdjustSubsequentBalances({
    required ExtendedDate date,
    required double value,
  }) async {
    final balanceRepository = locator<AbstractBalanceRepository>();

    // Get all balance before transaction date
    final balancesAfterDate = await balanceRepository.getAllBalanceAfterDate(
      date: date,
    );

    // Update all ballances after date
    // IMPORTANT: The current balance is updated by SQL trigger
    for (final balance in balancesAfterDate) {
      balance.balanceOpen -= value;
      balance.balanceClose -= value;
      balance.balanceTransCount++;

      await balanceRepository.updateBalance(balance);
    }
  }

  /// Removes a transaction from the database and adjusts balances accordingly.
  ///
  /// This method deletes the specified transaction from the database and
  /// updates subsequent balances to reflect the removal of the transaction.
  ///
  /// Parameters:
  /// - `transaction`: The `TransactionDbModel` object representing the
  ///   transaction to remove.
  ///
  /// The method adjusts the opening and closing balances of all subsequent
  /// balance records after the transaction date to account for the removal of
  /// the transaction value.
  static Future<void> removeTransaction(TransactionDbModel transaction) async {
    await removeTransactionByValues(
      id: transaction.transId!,
      date: transaction.transDate,
      value: transaction.transValue,
    );
  }

  /// Removes a transaction from the database, by your id, and adjusts balances
  /// accordingly.
  ///
  /// This method deletes the specified transaction from the database and
  /// updates subsequent balances to reflect the removal of the transaction.
  ///
  /// Parameters:
  /// - `transId`: The transaction id (`transId`).
  /// - `date`: The transaction date (`transDate`).
  /// - `value`: The transactino value (`transValue`).
  ///
  /// The method adjusts the opening and closing balances of all subsequent
  /// balance records after the transaction date to account for the removal of
  /// the transaction value.
  static Future<void> removeTransactionByValues({
    required int id,
    required ExtendedDate date,
    required double value,
  }) async {
    // Remove transaction by your id
    await locator<AbstractTransactionRepository>().deleteTransactionById(id);

    // Update balances
    await _subtractAdjustSubsequentBalances(
      date: date,
      value: value,
    );
  }

  /// Internally adjusts subsequent balances after removing a transaction.
  ///
  /// This helper method updates the opening and closing balances of all balance
  /// records after the specified date to exclude the value of the removed
  /// transaction.
  ///
  /// Parameters:
  /// - `date`: The `ExtendedDate` object representing the date of the
  ///   transaction.
  /// - `value`: The double value of the transaction to adjust the balances by.
  ///
  /// Note: This method is called internally by `removeTransaction`.
  static Future<void> _subtractAdjustSubsequentBalances({
    required ExtendedDate date,
    required double value,
  }) async {
    final balanceRepository = locator<AbstractBalanceRepository>();

    // Get all balance before transaction date
    final balancesAfterDate = await balanceRepository.getAllBalanceAfterDate(
      date: date,
    );

    // Update all ballances after date
    // IMPORTANT: The current balance is updated by SQL trigger
    for (final balance in balancesAfterDate) {
      balance.balanceOpen += value;
      balance.balanceClose += value;
      balance.balanceTransCount--;

      await balanceRepository.updateBalance(balance);
    }
  }

  /// Updates an existing transaction in the database.
  ///
  /// This static method updates a transaction by first removing the existing
  /// transaction record based on its ID and then adding a new transaction with
  /// the updated values. This approach ensures that all related balances and
  /// transaction counts are correctly adjusted to reflect the update.
  ///
  /// Parameters:
  /// - `transaction`: An instance of `TransactionDbModel` representing the updated
  ///   transaction information. The `transId` field is used to identify the transaction
  ///   to be updated.
  ///
  /// Returns:
  /// - A `Future<int>` that completes with the new transaction ID assigned after
  ///   re-inserting the updated transaction into the database. This ID is used
  ///   to replace the original transaction ID in the `TransactionDbModel` instance.
  ///
  /// Note:
  /// - The method performs a removal of the original transaction and an addition of
  ///   the updated transaction as separate operations. This is due to the method's
  ///   design to ensure accurate reflection of transaction updates in related balances.
  /// - The original transaction's ID (`transId`) is temporarily set to `null` to
  ///   facilitate the addition of the transaction as a new record.
  ///
  /// Example Usage:
  /// ```dart
  /// var updatedTransaction = TransactionDbModel(
  ///   transId: existingTransId,
  ///   transValue: newValue,
  ///   transDate: newDate,
  ///   // other fields...
  /// );
  /// var newTransId = await updateTransaction(updatedTransaction);
  /// print("Updated transaction has new ID: $newTransId");
  /// ```
  ///
  /// This method provides a way to handle transaction updates that require
  /// recalculating and adjusting balances and transaction counts in the system.
  static Future<int> updateTransaction(TransactionDbModel transaction) async {
    await removeTransactionByValues(
      id: transaction.transId!,
      value: transaction.transValue,
      date: transaction.transDate,
    );

    transaction.transId = null;
    await addNewTransaction(transaction);

    return transaction.transId!;
  }
}
