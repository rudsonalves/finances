import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'constants.dart';
import 'database_manager.dart';

abstract class CountStorer {
  Future<int> countTransactionForCategoryId(int id);
  Future<int> countTransactionsForAccountId(int id);
}

/// Manages count queries related to transactions within the database.
///
/// Utilizes the DatabaseManager to execute queries that count transactions
/// based on specific criteria, such as category or account ID.
class CountStore implements CountStorer {
  final _databaseManager = DatabaseManager();

  /// Counts the number of transactions associated with a specific category ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the category for which to count transactions.
  ///
  /// Returns the count of transactions for the specified category ID, or -1 if
  /// an error occurs.
  @override
  Future<int> countTransactionForCategoryId(int id) async {
    final database = await _databaseManager.database;

    try {
      int count = Sqflite.firstIntValue(await database.rawQuery(
            'SELECT COUNT(*) FROM $transactionsTable WHERE $transCategoryId = ?',
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Counts the number of transactions associated with a specific account ID.
  ///
  /// This method performs a nested query to count all transactions linked to
  /// an account ID through the balance and transaction day tables. It's
  /// designed to account for the relational structure where transactions are
  /// linked to accounts indirectly.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the account for which to count transactions.
  ///
  /// Returns the count of transactions for the specified account ID, or -1 if
  /// an error occurs.
  @override
  Future<int> countTransactionsForAccountId(int id) async {
    final database = await _databaseManager.database;

    try {
      int count = Sqflite.firstIntValue(await database.rawQuery(
            'SELECT COUNT(*) FROM $transactionsTable '
            ' WHERE $transId IN ('
            '  SELECT $transDayTransId FROM $transDayTable '
            '   WHERE $transDayBalanceId IN ('
            '    SELECT $balanceId FROM $balanceTable '
            '     WHERE $balanceAccountId IN ('
            '      SELECT $accountId FROM $accountTable WHERE $accountId = ?)'
            '  )'
            ')',
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }
}
