import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'constants.dart';
import 'database_manager.dart';

abstract class BalanceStorer {
  Future<int> insertBalance(Map<String, dynamic> balanceMap);
  Future<Map<String, dynamic>?> queryBalanceId(int id);
  Future<Map<String, dynamic>?> queryBalanceDate(
      {required int account, required int date});
  Future<void> updateBalance(Map<String, dynamic> balanceMap);
  Future<void> deleteBalance(int id);
}

/// Manages database operations for balance-related data.
///
/// This class provides methods to insert, query, update, and delete balance records
/// in the database. It uses the DatabaseManager to facilitate interactions with the database.
class BalanceStore implements BalanceStorer {
  final _databaseManager = DatabaseManager();

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
      int result = await database.insert(
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
      var result = await database.query(
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
  Future<Map<String, dynamic>?> queryBalanceDate({
    required int account,
    required int date,
  }) async {
    final database = await _databaseManager.database;

    try {
      var result = await database.query(
        balanceTable,
        where: '$balanceAccountId = ? AND $balanceDate = ?',
        whereArgs: [account, date],
      );
      if (result.isEmpty) return null;
      return result[0];
    } catch (err) {
      log('Error: $err');
      return null;
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
      int id = balanceMap[balanceId];
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
