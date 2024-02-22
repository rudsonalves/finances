import 'dart:developer';

import '../../common/models/balance_db_model.dart';
import '../../locator.dart';
import '../../store/transaction_store.dart';
import '../balance/balance_repository.dart';
import 'abstract_transaction_repository.dart';
import '../../common/models/extends_date.dart';
import '../../common/current_models/current_account.dart';
import '../../common/models/card_balance_model.dart';
import '../../common/models/transaction_db_model.dart';

/// Manages transactions within the database, including creation, deletion, and updates.
///
/// `TransactionRepository` implements `AbstractTransactionRepository` and provides
/// comprehensive functionalities for handling financial transactions. It integrates
/// closely with `TransactionStore` for direct database operations and `BalanceRepository`
/// for balance management, ensuring accurate financial record-keeping.
///
/// Responsibilities:
/// - Adding new transactions and automatically updating balance records.
/// - Deleting transactions and adjusting subsequent balance records to maintain accuracy.
/// - Updating transaction details and statuses.
/// - Retrieving transactions for specific balances or by transaction IDs.
/// - Calculating income and expense summaries for specified periods.
///
/// Usage:
/// This class is central to financial applications that require robust management
/// of transactions, offering a high-level interface for transaction operations
/// while ensuring data integrity and consistency across related records.
class TransactionRepository implements AbstractTransactionRepository {
  final _store = TransactionStore();
  final _balanceRespository = BalanceRepository();
  final _currentUser = locator<CurrentAccount>();

  /// Adds a new transaction to the database and updates the corresponding balance.
  ///
  /// This method performs several steps to ensure the new transaction is correctly
  /// integrated into the financial records:
  /// 1. Finds or creates a balance record for the transaction's date.
  /// 2. Assigns the found or created balance's ID to the transaction.
  /// 3. Inserts the new transaction into the database.
  /// 4. Updates subsequent balance records to reflect the new transaction.
  ///
  /// Parameters:
  ///   - transaction: A `TransactionDbModel` instance representing the transaction
  ///                  to be added.
  ///
  /// Note:
  ///   This method is essential for maintaining accurate and up-to-date financial
  ///   records. It ensures that each transaction is accounted for in the correct
  ///   balance and that all related balances are adjusted accordingly.
  @override
  Future<void> addNewTransaction(TransactionDbModel transaction) async {
    // Get or create a balance in the transaction date
    final balanceId = await _findCreateBalanceInDate(transaction);

    // Set the balance.balanceId to transBalanceId
    transaction.transBalanceId = balanceId;

    // insert a new transaction in database
    await _insertTransaction(transaction);

    // update subsequent balances
    await _addAdjustSubsequentBalances(transaction);
  }

  /// Inserts a transaction into the database and updates its transaction ID.
  ///
  /// This method directly inserts the provided transaction into the database
  /// and updates the `transId` property of the `TransactionDbModel` instance
  /// with the ID returned from the database.
  ///
  /// Parameters:
  ///   - transaction: The `TransactionDbModel` instance to be inserted.
  ///
  /// Throws:
  ///   An exception if the insertion fails, indicated by a negative transaction ID.
  ///
  /// Note:
  ///   This is a lower-level operation that supports the addition of new transactions
  ///   by handling the database insertion and ID management. It is called by
  ///   higher-level methods that prepare transactions for insertion.
  Future<void> _insertTransaction(TransactionDbModel transaction) async {
    int transId = await _store.insertTransaction(transaction.toMap());
    // This exception is a program logical error
    if (transId < 0) {
      final message = 'BUG - insertTransaction: return id $transId!!!';
      log(message);
      return;
    }
    transaction.transId = transId;
  }

  /// Finds or creates a balance record for the specified transaction date.
  ///
  /// This method checks for an existing balance record on the transaction's date.
  /// If none is found, it creates a new balance record for that date and the
  /// specified account.
  ///
  /// Parameters:
  ///   - transaction: The `TransactionDbModel` instance containing the date
  ///                  and account ID for which the balance is sought.
  ///
  /// Returns:
  ///   The ID of the existing or newly created balance record.
  ///
  /// Throws:
  ///   An exception if the balance record could not be found or created, or if
  ///   the resulting balance ID is null, indicating a logical error in the program.
  ///
  /// Note:
  ///   This method ensures that there is always a corresponding balance record for
  ///   each transaction, facilitating accurate financial reporting and analysis.
  Future<int> _findCreateBalanceInDate(TransactionDbModel transaction) async {
    final onlyDate = transaction.transDate.onlyDate;

    // Get balance in the transaction date
    var balance = await _balanceRespository.getBalanceInDate(
      date: onlyDate,
      accountId: transaction.transAccountId,
    );

    // if there is not a balance in transaction.transDate, create one.
    if (balance == null) {
      balance = BalanceDbModel(
        balanceAccountId: transaction.transAccountId,
        balanceDate: onlyDate,
      );
      // add a new balance
      await _balanceRespository.addNewBalance(balance);
    }

    // At this point balanceId must be different from null
    if (balance.balanceId == null) {
      const message = 'BUG - insertTransaction: balanceId is null!!!';
      log(message);
      throw Exception(message);
    }

    return balance.balanceId!;
  }

  /// Updates subsequent balance records after inserting a new transaction.
  ///
  /// This method adjusts the opening and closing balances of all balance records
  /// dated after the transaction's date to account for the new transaction's value.
  /// The adjustments are based on the assumption that the transaction affects the
  /// financial state from its date onward.
  ///
  /// Parameters:
  ///   - transaction: The `TransactionDbModel` instance that was inserted, used
  ///                  to determine the adjustment value and the starting point
  ///                  for subsequent balance updates.
  ///
  /// Note:
  ///   The balance adjustments made by this method are crucial for maintaining
  ///   consistent and accurate financial records following the addition of new
  ///   transactions.
  Future<void> _addAdjustSubsequentBalances(
      TransactionDbModel transaction) async {
    final value = transaction.transValue;

    // Update all ballances after date
    final balancesAfterDate = await _balanceRespository.getAllBalanceAfterDate(
      date: transaction.transDate.onlyDate,
    );

    for (final balance in balancesAfterDate) {
      balance.balanceOpen -= value;
      balance.balanceClose -= value;

      await _balanceRespository.updateBalance(balance);
    }
  }

  /// Retrieves all transactions associated with a specific balance ID.
  ///
  /// This method fetches transactions from the database that are linked to the
  /// specified balance ID, facilitating access to all transactions impacting a
  /// particular balance record.
  ///
  /// Parameters:
  ///   - balanceId: The ID of the balance record for which transactions are sought.
  ///
  /// Returns:
  ///   A list of `TransactionDbModel` instances representing each transaction
  ///   associated with the given balance ID. The list may be empty if no
  ///   transactions are found.
  ///
  /// Note:
  ///   Utilizing this method supports detailed financial analysis and auditing
  ///   by providing a complete view of transactions for a specific balance.
  @override
  Future<List<TransactionDbModel>> getTransForBalanceId(int balanceId) async {
    var maps = await _store.rawQueryTransForBalanceId(balanceId);
    return maps
        .map((transMap) => TransactionDbModel.fromMap(transMap))
        .toList();
  }

  /// Fetches a single transaction by its ID.
  ///
  /// This method retrieves a transaction from the database using its unique
  /// identifier. It's used for accessing detailed information about a specific
  /// transaction, such as for editing or analysis purposes.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction to retrieve.
  ///
  /// Returns:
  ///   A `TransactionDbModel` instance representing the transaction with the
  ///   specified ID, or null if no such transaction exists.
  ///
  /// Note:
  ///   This method is essential for operations that require interaction with
  ///   individual transaction records.
  @override
  Future<TransactionDbModel?> getTransId(int id) async {
    Map<String, Object?>? transMap = await _store.queryTransactionAtId(id);

    if (transMap != null) return TransactionDbModel.fromMap(transMap);

    return null;
  }

  /// Updates an existing transaction in the database.
  ///
  /// This method performs an update by first deleting the existing transaction
  /// and then adding a new transaction with the updated details. It ensures that
  /// all balance adjustments are correctly applied following the transaction update.
  ///
  /// Parameters:
  ///   - transaction: A `TransactionDbModel` instance representing the updated
  ///                  transaction details.
  ///
  /// Note:
  ///   The transaction ID is reset to null before re-adding to simulate an update.
  ///   This approach guarantees that balance records are accurately adjusted to
  ///   reflect the transaction update. Care should be taken to preserve transaction
  ///   integrity and consistency.
  @override
  Future<void> updateTransaction(TransactionDbModel transaction) async {
    // Remove transaction and update balances
    await deleteTransaction(transaction);

    // Add new transaction and update balances
    transaction.transId = null;
    await addNewTransaction(transaction);
  }

  /// Deletes a transaction from the database and adjusts subsequent balance records.
  ///
  /// This method removes a specified transaction and updates the opening and closing
  /// balances of all subsequent balance records to reflect the deletion. It first
  /// validates the transaction to ensure it has both a transaction ID and a balance
  /// ID before proceeding with the deletion.
  ///
  /// Parameters:
  ///   - transaction: The `TransactionDbModel` instance to be deleted.
  ///
  /// Returns:
  ///   The number of transactions deleted. Returns -1 if the transaction fails
  ///   validation checks.
  ///
  /// Note:
  ///   This method also triggers adjustments to subsequent balances to maintain
  ///   accurate financial records.
  @override
  Future<int> deleteTransaction(TransactionDbModel transaction) async {
    if (!_validateTransactionForDeletion(transaction)) return -1;

    int deleted = await _store.deleteTransactionId(transaction.transId!);

    if (deleted > 0) {
      await _delAdjustSubsequentBalances(transaction);
    }

    return deleted;
  }

  /// Validates a transaction for deletion.
  ///
  /// This method checks if a given transaction has both a non-null transaction ID
  /// and a balance ID, which are necessary for deletion. It logs an error message
  /// if either ID is null.
  ///
  /// Parameters:
  ///   - transaction: The `TransactionDbModel` instance to validate.
  ///
  /// Returns:
  ///   `true` if the transaction passes validation checks, `false` otherwise.
  ///
  /// Note:
  ///   This validation step helps prevent logical errors in the deletion process.
  bool _validateTransactionForDeletion(TransactionDbModel transaction) {
    if (transaction.transId == null || transaction.transBalanceId == null) {
      const message = 'BUG - deleteTrans: transId or transBalanceId is null';
      log(message);
      return false;
    }
    return true;
  }

  /// Adjusts subsequent balance records after a transaction deletion.
  ///
  /// Following the deletion of a transaction, this method updates the opening and
  /// closing balances of all balance records dated after the transaction's date.
  /// The adjustments ensure that the financial records accurately reflect the removal
  /// of the transaction.
  ///
  /// Parameters:
  ///   - transaction: The `TransactionDbModel` instance that was deleted.
  ///
  /// Note:
  ///   The actual balance adjustments are informed by the transaction's value and
  ///   date, ensuring that all subsequent balances are correctly updated to remain
  ///   consistent with the current financial state.
  Future<void> _delAdjustSubsequentBalances(
    TransactionDbModel transaction,
  ) async {
    // Get only the date of transaction
    final onlyDate = transaction.transDate.onlyDate;
    final value = transaction.transValue;

    // Get all balances after date
    final balancesAfterDate = await _balanceRespository.getAllBalanceAfterDate(
      date: onlyDate,
    );

    // Update all ballances after date
    for (final balance in balancesAfterDate) {
      balance.balanceOpen += value;
      balance.balanceClose += value;

      await _balanceRespository.updateBalance(balance);
    }
  }

  /// Calculates the income and expense balances for a given card within a specified month.
  ///
  /// This method updates the provided `CardBalanceModel` instance with the total
  /// incomes and expenses accrued over a month. If no date is specified, it defaults
  /// to the current month. It retrieves the income and expense totals from the database
  /// for the current user's account within the specified date range.
  ///
  /// Parameters:
  ///   - cardBalance: The `CardBalanceModel` instance to be updated with the calculated
  ///                  balances.
  ///   - date: An optional `ExtendedDate` instance specifying the month for which the
  ///           balance is calculated. Defaults to the current month if not provided.
  ///
  /// Note:
  ///   This method is essential for financial tracking and reporting, allowing users
  ///   to monitor their spending and income over specific periods. The calculated
  ///   balances provide insights into financial health and budgeting efficacy.
  @override
  Future<void> getCardBalance({
    required CardBalanceModel cardBalance,
    ExtendedDate? date,
  }) async {
    int startDate;
    int endDate;

    (startDate, endDate) = ExtendedDate.getMillisecondsIntervalOfMonth(
      date ?? ExtendedDate.now(),
    );

    int accountId = _currentUser.accountId!;

    double incomes = await _store.getIncomeBetweenDates(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
    );

    double expanses = await _store.getExpenseBetweenDates(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
    );

    cardBalance.incomes = incomes;
    cardBalance.expanses = expanses;
  }

  /// Updates the status of a specific transaction in the database.
  ///
  /// This method changes the status of a transaction, identified by its unique
  /// ID, to the new status provided. It's used for marking transactions as
  /// completed, pending, or any other defined status within the `TransStatus` enum.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction to be updated.
  ///   - status: The new status from the `TransStatus` enum to apply to the
  ///             transaction.
  ///
  /// Returns:
  ///   The number of transactions updated, which is expected to be 1. If the
  ///   update does not successfully affect exactly one transaction, a log entry
  ///   is made.
  ///
  /// Note:
  ///   This method ensures that transaction records can be dynamically updated
  ///   to reflect their current status, aiding in accurate financial tracking
  ///   and management. The method logs any unexpected results to facilitate
  ///   troubleshooting and ensure data integrity.
  @override
  Future<int> updateTransStatus(
    int id,
    TransStatus status,
  ) async {
    final result = await _store.updateTransactionStatus(id, status.index);

    if (result != 1) {
      log('updateTransactionStatus return $result');
    }
    return result;
  }
}
