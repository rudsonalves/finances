import 'dart:developer';

import 'package:finances/common/models/extends_date.dart';
import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants.dart';
import 'database_manager.dart';

/// Handles transaction-related operations in the database.
///
/// This class implements the `TransactionStorer` interface, facilitating
/// CRUD operations on transaction data using a database manager.
abstract class TransactionStorer {
  /// Inserts a new transaction into the database.
  ///
  /// This asynchronous method takes a map representation of a transaction and
  /// attempts to insert it into the transactions table. It utilizes the
  /// ConflictAlgorithm.abort to prevent duplicate entries based on primary key
  /// constraints. If the insertion is successful, the method returns the ID of
  /// the newly inserted transaction. In case of failure, it logs the error and
  /// throws an exception with the error message.
  ///
  /// Parameters:
  /// - [transactionMap]: A map containing the key-value pairs representing the
  ///   transaction's attributes to be inserted.
  ///
  /// Returns:
  /// - The integer ID of the newly inserted transaction.
  ///
  /// Throws:
  /// - An Exception with a descriptive error message if the insertion fails.
  Future<int> insertTransaction(Map<String, dynamic> transactionMap);

  /// Updates an existing transaction in the database.
  ///
  /// This method updates a transaction specified by the transaction ID in the map
  /// parameter [transMap]. It first retrieves the database instance and then
  /// performs the update operation using the provided transaction map. The `where`
  /// clause ensures only the record with the matching transaction ID is updated.
  /// If successful, the method returns the count of records affected by the update
  /// operation, typically one. In case of failure, it logs the error and throws
  /// an exception with a descriptive error message.
  ///
  /// Parameters:
  /// - [transMap]: A map containing the key-value pairs of the transaction's
  ///   attributes to be updated, including the transaction ID.
  ///
  /// Returns:
  /// - The number of records affected by the update operation.
  ///
  /// Throws:
  /// - An Exception with a descriptive error message if the update operation fails.
  Future<int> updateTransaction(Map<String, dynamic> transMap);

  /// Updates the status of a specified transaction in the database.
  ///
  /// Attempts to update the status of the transaction identified by [id]
  /// to the new status provided in [newStatus]. It fetches the database
  /// instance and executes the update operation. If the operation is
  /// successful, returns the count of records affected (typically one).
  /// In case of an exception, logs the error and throws a descriptive
  /// exception.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the transaction to update.
  /// - [newStatus]: The new status value for the transaction.
  ///
  /// Returns:
  /// - The number of records affected by the update.
  ///
  /// Throws:
  /// - An Exception if the update operation fails.
  Future<int> updateTransactionStatus({
    required int id,
    required int newStatus,
  });

  /// Deletes a transaction from the database by its ID.
  ///
  /// Connects to the database and attempts to delete the transaction
  /// identified by the given [id]. On successful deletion, returns the
  /// count of records affected (should be one if the transaction existed).
  /// Encounters with errors during the deletion process are logged and
  /// rethrown as exceptions with a descriptive message.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the transaction to delete.
  ///
  /// Returns:
  /// - The number of records affected by the delete operation.
  ///
  /// Throws:
  /// - An Exception if the delete operation encounters an error.
  Future<int> deleteTransactionId(int id);

  /// Queries the database for a transaction by its unique identifier.
  ///
  /// Retrieves the transaction details from the database corresponding
  /// to the provided [id]. If the transaction is found, returns a map
  /// containing the transaction's attributes. Returns `null` if no
  /// transaction with the specified [id] exists in the database.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the transaction to retrieve.
  ///
  /// Returns:
  /// - A map of the transaction's attributes if found, otherwise `null`.
  ///
  /// Throws:
  /// - An Exception with a descriptive error message if the query fails.
  Future<Map<String, Object?>?> queryTransactionAtId(int id);

  /// Retrieves transactions associated with a specific balance ID.
  ///
  /// Performs a database query to fetch transactions linked to the given
  /// [balanceId]. The transactions are ordered by their date in descending
  /// order. If the query is successful, a list of maps detailing the
  /// transactions is returned. Each map contains the transaction attributes.
  ///
  /// Parameters:
  /// - [balanceId]: The ID of the balance for which transactions are queried.
  ///
  /// Returns:
  /// - A list of maps, where each map represents a transaction's attributes.
  ///
  /// Throws:
  /// - An Exception with a descriptive error message if the query operation fails.
  Future<List<Map<String, dynamic>>> queryTransactionForBalanceId(int id);

  /// Calculates the total income for an account within a specified date range.
  ///
  /// Queries the database to sum up the income transactions for [accountId]
  /// between [startDate] and [endDate]. It executes a raw SQL query defined by
  /// `getIncomeBetweenDatesSQL` with the provided parameters. The method returns
  /// the total sum of income transactions as a double. If no income transactions
  /// are found within the specified range, the method returns 0.0.
  ///
  /// Parameters:
  /// - [startDate]: The start of the date range, represented as an integer
  ///   timestamp.
  /// - [endDate]: The end of the date range, also as an integer timestamp.
  /// - [accountId]: The ID of the account for which to calculate total income.
  ///
  /// Returns:
  /// - The total sum of income transactions as a double.
  ///
  /// Throws:
  /// - An Exception with a descriptive error message if the query operation fails.
  Future<double> getIncomeBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  });

  /// Calculates the total expenses for an account within a specified date range.
  ///
  /// Executes a database query to sum up the expense transactions for the specified
  /// [accountId] between [startDate] and [endDate]. Utilizes the raw SQL query defined
  /// by `getExpenseBetweenDatesSQL` with the input parameters to perform this operation.
  /// Returns the aggregated sum of expenses as a double. If no expense transactions
  /// are found within the given range, returns 0.0.
  ///
  /// Parameters:
  /// - [startDate]: The beginning of the date range, given as an integer timestamp.
  /// - [endDate]: The end of the date range, also as an integer timestamp.
  /// - [accountId]: The ID of the account whose expenses are being calculated.
  ///
  /// Returns:
  /// - The total sum of expenses transactions as a double.
  ///
  /// Throws:
  /// - An Exception with a descriptive error message if the query fails.
  Future<double> getExpenseBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  });

  /// Fetches a specified number of transactions for an account starting from a given date.
  ///
  /// This method queries the database for transactions associated with [accountId],
  /// starting before [startDate]. The transactions are retrieved in descending order
  /// by date, up to the [maxTransactions] limit. It returns a list of transaction maps,
  /// each representing a transaction's data.
  ///
  /// Parameters:
  /// - [startDate]: The starting point (exclusive) to fetch transactions from, represented
  ///   as an ExtendedDate.
  /// - [accountId]: The ID of the account whose transactions are to be fetched.
  /// - [maxTransactions]: The maximum number of transactions to retrieve.
  ///
  /// Returns:
  /// - A list of maps, where each map details a transaction's attributes.
  ///
  /// Throws:
  /// - An Exception with a descriptive error message if the query operation fails.
  Future<List<Map<String, dynamic>>> queryNTransactionsFromDate({
    required final ExtendedDate startDate,
    required final int accountId,
    required final int maxTransactions,
  });
}

class TransactionStore implements TransactionStorer {
  final _databaseManager = locator<DatabaseManager>();

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
      final message = 'TransactionStore.insertTransaction: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransactionStore.updateTransaction: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> updateTransactionStatus({
    required int id,
    required int newStatus,
  }) async {
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
      final message = 'TransactionStore.updateTransactionStatus: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransactionStore.deleteTransactionId: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransactionStore.queryTransactionAtId: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransactionStore.queryTransactionForBalanceId: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransactionStore.queryNTransactionsFromDate: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransactionStore.getIncomeBetweenDates: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransactionStore.getExpenseBetweenDates: $err';
      log(message);
      throw Exception(message);
    }
  }
}
