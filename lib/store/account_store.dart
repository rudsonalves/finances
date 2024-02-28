import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants.dart';
import 'database_manager.dart';

abstract class AccountStorer {
  Future<int> insertAccount(Map<String, dynamic> accountMap);
  Future<List<Map<String, dynamic>>> queryUserAccounts(String userId);
  Future<void> deleteAccountId(int id);
  Future<void> updateAccount(Map<String, dynamic> accountMap);
  Future<void> deleteTransactionsByAccountId(int id);
  Future<void> deleteBalancesByAccountId(int id);
}

/// Manages database operations for account-related data.
///
/// This class provides methods to insert, query, update, and delete accounts
/// and their associated data (like transactions and balances) in the database.
class AccountStore implements AccountStorer {
  final _databaseManager = locator<DatabaseManager>();

  /// Inserts a new account record into the database.
  ///
  /// Parameters:
  ///   - accountMap: A map containing the account data to be inserted.
  ///
  /// Returns the row ID of the newly inserted account, or -1 if an error occurs.
  @override
  Future<int> insertAccount(Map<String, dynamic> accountMap) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.insert(
        accountTable,
        accountMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Queries all accounts associated with a specific user ID.
  ///
  /// Parameters:
  ///   - userId: The ID of the user whose accounts are to be queried.
  ///
  /// Returns a list of maps, each representing an account's data.
  @override
  Future<List<Map<String, dynamic>>> queryUserAccounts(String userId) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, dynamic>> result = await database.query(
        accountTable,
        where: '$accountUserId = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  /// Deletes an account by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the account to be deleted.
  @override
  Future<void> deleteAccountId(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        accountTable,
        where: '$accountId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /// Updates an existing account's data in the database.
  ///
  /// Parameters:
  ///   - accountMap: A map containing the updated data for the account.
  @override
  Future<void> updateAccount(Map<String, dynamic> accountMap) async {
    final database = await _databaseManager.database;

    try {
      int id = accountMap[accountId];
      await database.update(
        accountTable,
        accountMap,
        where: '$accountId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /// Deletes all transactions associated with a specific account ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the account whose transactions are to be deleted.
  @override
  Future<void> deleteTransactionsByAccountId(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        transactionsTable,
        where: '$transAccountId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /// Deletes all balances associated with a specific account ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the account whose balances are to be deleted.
  @override
  Future<void> deleteBalancesByAccountId(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        balanceTable,
        where: '$balanceAccountId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }
}
