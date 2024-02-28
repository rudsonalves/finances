import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants.dart';
import 'database_manager.dart';

abstract class BalanceStorer {
  Future<int> insertBalance(Map<String, dynamic> balanceMap);
  Future<Map<String, dynamic>?> queryBalanceId(int id);
  Future<Map<String, dynamic>?> queryBalanceInDate(
      {required int account, required int date});
  // Future<Map<String, dynamic>?> queryBalanceBeforeDate(
  //     {required int account, required int date});
  Future<List<Map<String, dynamic>>> queryAllBalanceAfterDate(
      {required int account, required int date});
  Future<void> updateBalance(Map<String, dynamic> balanceMap);
  Future<void> deleteBalance(int id);
}

/// Manages database operations for balance-related data.
///
/// This class provides methods to insert, query, update, and delete balance records
/// in the database. It uses the DatabaseManager to facilitate interactions with the database.
class BalanceStore implements BalanceStorer {
  final _databaseManager = locator<DatabaseManager>();

  /// Inserts a new balance record into the database.
  ///
  /// Parameters:
  ///   - balanceMap: A map containing the balance data to be inserted.
  ///
  /// Returns the row ID of the newly inserted balance, or -1 if an error occurs.
  @override
  Future<int> insertBalance(Map<String, dynamic> balanceMap) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.insert(
        balanceTable,
        balanceMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Queries a balance record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the balance to be queried.
  ///
  /// Returns a map representing the balance's data if found, or null if not found.
  @override
  Future<Map<String, dynamic>?> queryBalanceId(int id) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return result[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }

  /// Queries a balance record by account ID and date.
  ///
  /// Parameters:
  ///   - account: The account ID associated with the balance.
  ///   - date: The date of the balance record.
  ///
  /// Returns a map representing the balance's data for the specified account and date,
  /// or null if no record is found.
  @override
  Future<Map<String, dynamic>?> queryBalanceInDate({
    required int account,
    required int date,
  }) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.query(
        balanceTable,
        where: '$balanceAccountId = ? AND $balanceDate <= ?',
        whereArgs: [account, date],
      );
      if (result.isEmpty) return null;
      return result[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }

  /// Queries the most recent balance record before a specified date for a
  /// given account ID.
  ///
  /// Parameters:
  ///   - account: The account ID associated with the balance.
  ///   - date: The date before which the balance record is sought.
  ///
  /// Returns a map representing the balance's data for the specified account
  /// immediately before the given date, or null if no record is found.
  // @override
  // Future<Map<String, dynamic>?> queryBalanceBeforeDate({
  //   required int account,
  //   required int date,
  // }) async {
  //   final database = await _databaseManager.database;

  //   try {
  //     final result = await database.query(
  //       balanceTable,
  //       where: '$balanceAccountId = ? AND $balanceDate < ?',
  //       whereArgs: [account, date],
  //       orderBy: '$balanceDate DESC',
  //     );
  //     if (result.isEmpty) return null;
  //     return result[0];
  //   } catch (err) {
  //     log('Error: $err');
  //     return null;
  //   }
  // }

  /// Queries the most recent balance record before a specified date for a given account.
  ///
  /// This method searches for the latest balance record for the specified account that
  /// is dated before the given date. It's useful for retrieving the last known balance
  /// state before a certain point in time.
  ///
  /// Parameters:
  ///   - account: The account ID for which the balance is being queried.
  ///   - date: The date before which the balance record is sought, represented as
  ///           an integer (e.g., milliseconds since epoch).
  ///
  /// Returns:
  ///   A map representing the most recent balance's data before the specified date,
  ///   or null if no such record exists. The map includes balance details such as
  ///   balance ID, account ID, balance date, opening balance, closing balance, etc.
  ///
  /// Throws:
  ///   An exception if there's an error during the database query, logging the error.
  ///
  /// Note:
  ///   This method is particularly useful for financial calculations that require
  ///   understanding the account balance before a specific transaction or event date.
  @override
  Future<List<Map<String, dynamic>>> queryAllBalanceAfterDate({
    required int account,
    required int date,
  }) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.query(
        balanceTable,
        where: '$balanceAccountId = ? AND $balanceDate > ?',
        whereArgs: [account, date],
        orderBy: '$balanceDate ASC',
        limit: 1,
      );
      if (result.isEmpty) return [];
      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  /// Updates an existing balance record in the database.
  ///
  /// Parameters:
  ///   - balanceMap: A map containing the updated balance data.
  ///
  /// Requires the balanceMap to include the balance's unique ID.
  @override
  Future<void> updateBalance(Map<String, dynamic> balanceMap) async {
    final database = await _databaseManager.database;

    try {
      final id = balanceMap[balanceId];
      await database.update(
        balanceTable,
        balanceMap,
        where: '$balanceId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /// Deletes a balance record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the balance to be deleted.
  @override
  Future<void> deleteBalance(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }
}
