import 'dart:developer';

import 'package:finances/store/database_manager.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';

abstract class TransDayStorer {
  Future<int> insertTransDay(Map<String, dynamic> transDayMap);
  Future<int> deleteTransDay(int transId);
  Future<Map<String, Object?>?> queryTransDayId(int id);
}

/// Manages database operations for transaction-day relationships.
///
/// Provides methods to insert, query, and delete records in the transDayTable,
/// facilitating the association between transactions and the days on which they occur.
class TransDayStore implements TransDayStorer {
  final _databaseManager = DatabaseManager();

  /// Inserts a new transaction-day association record into the database.
  ///
  /// Parameters:
  ///   - transDayMap: A map containing the transaction-day data to be inserted.
  ///
  /// Returns the row ID of the newly inserted record, or -1 if an error occurs.
  ///
  /// This method enables tracking of transactions on specific days, aiding in
  /// temporal analysis and reporting.
  @override
  Future<int> insertTransDay(Map<String, dynamic> transDayMap) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.insert(
        transDayTable,
        transDayMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Deletes a transaction-day association record by its transaction ID.
  ///
  /// Parameters:
  ///   - transId: The unique identifier of the transaction associated with the
  ///     day to be deleted.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  ///
  /// This method is useful for cleaning up associations when a transaction is
  /// deleted or its date is changed.
  @override
  Future<int> deleteTransDay(int transId) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.delete(
        transDayTable,
        where: '$transDayTransId = ?',
        whereArgs: [transId],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Queries a transaction-day association record by its transaction ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction whose association is to
  ///     be queried.
  ///
  /// Returns a map representing the transaction-day association's data if found,
  /// or null if not found.
  ///
  /// This method facilitates retrieval of the day associated with a specific
  /// transaction, supporting detailed temporal queries and analysis.
  @override
  Future<Map<String, Object?>?> queryTransDayId(int id) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, Object?>> maps = await database.query(
        transDayTable,
        where: '$transDayTransId = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return maps[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }
}
