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
  /// Inserts a transaction into the database.
  ///
  /// Parameters:
  /// - `transactionMap`: A map of the transaction data to insert.
  /// Returns:
  /// - The ID of the inserted transaction, or -1 in case of failure.
  Future<int> insertTransaction(Map<String, dynamic> transactionMap);

  /// Updates a transaction in the database.
  ///
  /// Parameters:
  /// - `transMap`: A map of the updated transaction data.
  /// Returns:
  /// - The number of rows affected, or -1 in case of failure.
  Future<int> updateTransaction(Map<String, dynamic> transMap);

  /// Updates the status of a transaction.
  ///
  /// Parameters:
  /// - `id`: The ID of the transaction to update.
  /// - `newStatus`: The new status value.
  /// Returns:
  /// - The number of rows affected, or -1 in case of failure.
  Future<int> updateTransactionStatus({
    required int id,
    required int newStatus,
  });

  /// Deletes a transaction by its ID.
  ///
  /// Parameters:
  /// - `id`: The ID of the transaction to delete.
  /// Returns:
  /// - The number of rows affected, or -1 in case of failure.
  Future<int> deleteTransactionId(int id);

  /// Queries a transaction by its ID.
  ///
  /// Parameters:
  /// - `id`: The ID of the transaction to query.
  /// Returns:
  /// - A map of the transaction data, or null if not found.
  Future<Map<String, Object?>?> queryTransactionAtId(int id);

  /// Queries transactions for a specific balance ID.
  ///
  /// Parameters:
  /// - `balanceId`: The balance ID associated with the transactions.
  /// Returns:
  /// - A list of maps of the transaction data.
  Future<List<Map<String, dynamic>>> queryTransactionForBalanceId(int id);

  /// Queries a set number of transactions from a start date.
  ///
  /// Parameters:
  /// - `startDate`: The start date for the query.
  /// - `accountId`: The account ID associated with the transactions.
  /// - `maxTransactions`: The maximum number of transactions to return.
  /// Returns:
  /// - A list of maps of the transaction data.
  Future<double> getIncomeBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  });

  /// Gets the total income between two dates for an account.
  ///
  /// Parameters:
  /// - `startDate`: The start date of the period.
  /// - `endDate`: The end date of the period.
  /// - `accountId`: The account ID for which to calculate income.
  /// Returns:
  /// - The total income as a double.
  Future<double> getExpenseBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  });

  /// Gets the total expenses between two dates for an account.
  ///
  /// Parameters:
  /// - `startDate`: The start date of the period.
  /// - `endDate`: The end date of the period.
  /// - `accountId`: The account ID for which to calculate expenses.
  /// Returns:
  /// - The total expenses as a double.
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
      log('Error: $err');
      return -1;
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
      log('Error: $err');
      return -1;
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
      log('Error: $err');
      return -1;
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
      log('Error: $err');
      return -1;
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
      log('Error: $err');
      return {};
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
      log('Error: $err');
      return [];
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
      log('Error: $err');
      return [];
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
      log('Error: $err');
      return 0.0;
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
      log('Error: $err');
      return 0.0;
    }
  }
}
