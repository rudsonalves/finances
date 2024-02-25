import 'dart:developer';

import 'package:finances/common/models/extends_date.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';
import 'database_manager.dart';

abstract class TransactionStorer {
  Future<int> insertTransaction(Map<String, dynamic> transactionMap);
  Future<int> updateTransaction(Map<String, dynamic> transMap);
  Future<int> updateTransactionStatus(int id, int newStatus);
  Future<int> deleteTransactionId(int id);
  Future<Map<String, Object?>?> queryTransactionAtId(int id);
  Future<List<Map<String, dynamic>>> queryTransactionForBalanceId(int id);
  Future<double> getIncomeBetweenDates(
      {required int startDate, required int endDate, required int accountId});
  Future<double> getExpenseBetweenDates(
      {required int startDate, required int endDate, required int accountId});
  Future<List<Map<String, dynamic>>> queryNTransactionsFromDate({
    required final ExtendedDate startDate,
    required final int accountId,
    required final int maxTransactions,
  });
}

/// Manages database operations for transaction-related data.
///
/// Provides methods to insert, query, update, and delete transaction records
/// in the database, utilizing the DatabaseManager for interactions with the database.
class TransactionStore implements TransactionStorer {
  final _databaseManager = DatabaseManager();

  /// Inserts a new transaction record into the database.
  ///
  /// Parameters:
  ///   - transactionMap: A map containing the transaction data to be inserted.
  ///
  /// Returns the row ID of the newly inserted transaction, or -1 if an error occurs.
  @override
  Future<int> insertTransaction(Map<String, dynamic> transactionMap) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.insert(
        transactionsTable,
        transactionMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Updates an existing transaction record in the database.
  ///
  /// Parameters:
  ///   - transMap: A map containing the updated transaction data, including the
  ///     transaction's unique ID.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateTransaction(Map<String, dynamic> transMap) async {
    final database = await _databaseManager.database;

    try {
      int id = transMap[transId];
      int result = await database.update(
        transactionsTable,
        transMap,
        where: '$transId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Updates the status of an existing transaction in the database.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction to be updated.
  ///   - newStatus: The new status value for the transaction.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateTransactionStatus(int id, int newStatus) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.update(
        transactionsTable,
        {transStatus: newStatus},
        where: '$transId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Deletes a transaction record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction to be deleted.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> deleteTransactionId(int id) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.delete(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Queries a transaction record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction to be queried.
  ///
  /// Returns a map representing the transaction's data if found, or null if not found.
  @override
  Future<Map<String, Object?>?> queryTransactionAtId(int id) async {
    final database = await _databaseManager.database;

    try {
      final List<Map<String, Object?>> result = await database.query(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;

      return result.first;
    } catch (err) {
      log('Error: $err');
      return {};
    }
  }

  /// Executes a raw SQL query to retrieve transactions associated with a specific
  /// balance ID.
  ///
  /// Parameters:
  ///   - id: The balance ID related to the transactions to be queried.
  ///
  /// Returns a list of maps, each representing a transaction's data.
  @override
  Future<List<Map<String, dynamic>>> queryTransactionForBalanceId(
      int balanceId) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, dynamic>> result = await database.query(
        transactionsTable,
        where: '$transBalanceId = ?',
        whereArgs: [balanceId],
        orderBy: '$transDate DESC',
      );

      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  /// Retrieves a list of transactions for a specific account up to a specified
  /// start date, limited to a maximum number of transactions.
  ///
  /// This method queries the database for transactions associated with the
  /// provided account ID that occurred on or before the provided start date.
  /// The transactions are returned in descending order by date, allowing for
  /// the retrieval of the most recent transactions first. The number of
  /// transactions returned is capped at the specified maximum number to
  /// prevent excessive data loading.
  ///
  /// Parameters:
  ///   - startDate: An `ExtendedDate` instance representing the upper bound of
  ///                the date range for the query. Only transactions on or before
  ///                this date will be considered.
  ///   - accountId: The unique identifier of the account for which transactions
  ///                are to be retrieved.
  ///   - maxTransactions: The maximum number of transactions to retrieve. This
  ///                      limits the result set to the most recent transactions
  ///                      up to the specified number for the given account.
  ///
  /// Returns:
  ///   A list of maps, each representing a transaction's data for the specified
  ///   account, limited to the number specified by `maxTransactions`. If an error
  ///   occurs during the query, an empty list is returned.
  ///
  /// Throws:
  ///   Logs an error message and returns an empty list if there is an issue
  ///   executing the query.
  ///
  /// Note:
  ///   This method is particularly useful for generating reports or summaries
  ///   of recent transactions for a specific account up to a certain date,
  ///   facilitating financial analysis and record-keeping for individual accounts.
  @override
  Future<List<Map<String, dynamic>>> queryNTransactionsFromDate({
    required final ExtendedDate startDate,
    required final int accountId,
    required final int maxTransactions,
  }) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, dynamic>> result = await database.query(
        transactionsTable,
        where: '$transDate < ? AND $transAccountId = ?',
        whereArgs: [startDate.millisecondsSinceEpoch, accountId],
        orderBy: '$transDate DESC',
        limit: maxTransactions,
      );

      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  /// Retrieves the sum of income transactions within a specified date range for
  /// a given account.
  ///
  /// Parameters:
  ///   - startDate: The start of the date range as an integer.
  ///   - endDate: The end of the date range as an integer.
  ///   - accountId: The account ID for which to sum income transactions.
  ///
  /// Returns the sum of income transactions as a double, or 0.0 if an error occurs.
  @override
  Future<double> getIncomeBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  }) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, Object?>> result = await database.rawQuery(
        getIncomeBetweenDatesSQL,
        [startDate, endDate, accountId],
      );
      double totalEntries = (result.first['totalIncomes'] ?? 0.0) as double;
      return totalEntries;
    } catch (err) {
      log('Error: $err');
      return 0.0;
    }
  }

  /// Retrieves the sum of expense transactions within a specified date range
  /// for a given account.
  ///
  /// Parameters:
  ///   - startDate: The start of the date range as an integer.
  ///   - endDate: The end of the date range as an integer.
  ///   - accountId: The account ID for which to sum expense transactions.
  ///
  /// Returns the sum of expense transactions as a double, or 0.0 if an error occurs.
  @override
  Future<double> getExpenseBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  }) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, Object?>> result = await database.rawQuery(
        getExpenseBetweenDatesSQL,
        [startDate, endDate, accountId],
      );
      double totalEntries = (result.first['totalExpenses'] ?? 0.0) as double;
      return totalEntries;
    } catch (err) {
      log('Error: $err');
      return 0.0;
    }
  }
}
