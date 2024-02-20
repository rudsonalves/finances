import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'constants.dart';
import 'database_manager.dart';

abstract class TransferStorer {
  Future<int> insertTransfer(Map<String, dynamic> transferMap);
  Future<int> deleteTransferId(int id);
  Future<Map<String, Object?>?> queryTranferId(int id);
  Future<int> updateTransfer(Map<String, dynamic> transferMap);
}

/// Manages database operations for transfer-related data.
///
/// Facilitates the insertion, querying, updating, and deletion of transfer records
/// in the database, using the DatabaseManager for database interactions.
class TransferStore implements TransferStorer {
  final _databaseManager = DatabaseManager();

  /// Inserts a new transfer record into the database.
  ///
  /// Parameters:
  ///   - transferMap: A map containing the transfer data to be inserted.
  ///
  /// Returns the row ID of the newly inserted transfer, or -1 if an error occurs.
  ///
  /// This method allows for the recording of transfers between accounts, capturing
  /// essential information like amounts, accounts involved, and transfer dates.
  @override
  Future<int> insertTransfer(Map<String, dynamic> transferMap) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.insert(
        transfersTable,
        transferMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Deletes a transfer record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transfer to be deleted.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  ///
  /// Useful for removing transfers that are no longer valid or were entered in
  /// error.
  @override
  Future<int> deleteTransferId(int id) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.delete(
        transfersTable,
        where: '$transferId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Queries a transfer record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transfer to be queried.
  ///
  /// Returns a map representing the transfer's data if found, or null if not found.
  ///
  /// This method enables the retrieval of specific transfer details for review
  /// or editing.
  @override
  Future<Map<String, Object?>?> queryTranferId(int id) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, Object?>> maps = await database.query(
        transfersTable,
        where: '$transferId = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return maps[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }

  /// Updates an existing transfer record in the database.
  ///
  /// Parameters:
  ///   - transferMap: A map containing the updated transfer data, including the
  ///     transfer's unique ID.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  ///
  /// Allows for the modification of transfer details, accommodating changes in
  /// transfer amounts, dates, or involved accounts.
  @override
  Future<int> updateTransfer(Map<String, dynamic> transferMap) async {
    final database = await _databaseManager.database;

    try {
      int id = transferMap[transferId];
      int result = await database.update(
        transfersTable,
        transferMap,
        where: '$transferId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }
}
