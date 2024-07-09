// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../locator.dart';
import '../constants/constants.dart';
import '../database/database_manager.dart';

/// Manages database operations for transfer-related data.
///
/// Facilitates the insertion, querying, updating, and deletion of transfer records
/// in the database, using the DatabaseManager for database interactions.
abstract class TransferStorer {
  /// Inserts a new transfer record into the database.
  ///
  /// This method attempts to insert a new transfer defined by [transferMap] into
  /// the `transfersTable`. The operation uses `ConflictAlgorithm.abort` to cancel
  /// the insertion if a conflict occurs, ensuring data integrity.
  ///
  /// Parameters:
  ///   - transferMap: A map containing the data for the new transfer to be inserted.
  ///
  /// Returns the row ID of the newly inserted transfer if successful, otherwise
  /// throws an exception with a detailed error message.
  ///
  /// Throws:
  ///   - Exception: If the insertion fails, an exception is thrown with the error
  ///     message detailing the cause of the failure.
  Future<int> insertTransfer(Map<String, dynamic> transferMap);

  /// Deletes a transfer record from the database by its ID.
  ///
  /// This method attempts to delete a transfer record from the `transfersTable`
  /// based on the provided [id]. It constructs a deletion query that targets
  /// the record with a matching `transferId`.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transfer to be deleted.
  ///
  /// Returns the number of rows affected by the operation. If the deletion is
  /// successful, this number should be 1, indicating that one record was deleted.
  /// If no rows are affected, the transfer was not found, and 0 is returned.
  ///
  /// Throws:
  ///   - Exception: If the deletion fails, an exception is thrown with the error
  ///     message detailing the cause of the failure.
  Future<int> deleteTransferId(int id);

  /// Queries the database for a transfer record by its ID.
  ///
  /// This method fetches a transfer record from the `transfersTable` using the
  /// provided [id] as the search criterion. It constructs a query that targets
  /// the record with a matching `transferId`.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transfer to be queried.
  ///
  /// Returns a map representing the transfer record if found, otherwise null.
  /// The map contains key-value pairs corresponding to the transfer's column
  /// names and their values in the database.
  ///
  /// Throws:
  ///   - Exception: If the query operation fails, an exception is thrown with
  ///     an error message detailing the cause of the failure.
  Future<Map<String, Object?>?> queryTranferId(int id);

  /// Updates an existing transfer record in the database.
  ///
  /// This method updates a transfer record in the `transfersTable` using data
  /// provided in [transferMap]. The record to be updated is identified by the
  /// `transferId` key in the map.
  ///
  /// Parameters:
  ///   - transferMap: A map containing the updated data for the transfer. Must
  ///     include `transferId` to specify which record to update.
  ///
  /// Returns the number of rows affected by the operation. Typically, this will
  /// be 1 if the update is successful, indicating that one record was updated.
  /// A return value of 0 indicates that no record was found with the provided
  /// `transferId`.
  ///
  /// Throws:
  ///   - Exception: If the update operation fails, an exception is thrown with
  ///     an error message detailing the cause of the failure. This ensures that
  ///     any failure in the update process is clearly communicated to the caller.
  Future<int> updateTransfer(Map<String, dynamic> transferMap);

  /// Sets the transfer IDs and account IDs to null for a specified transfer record.
  ///
  /// This method is used to disassociate a transfer record in the `transfersTable`
  /// from its related transactions and accounts by setting `transferTransId0`,
  /// `transferTransId1`, `transferAccount0`, and `transferAccount1` fields to null.
  /// This operation targets the record identified by the provided [id].
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transfer to be updated.
  ///
  /// Returns the number of rows affected by the operation. Typically, this will
  /// be 1 if the update is successful, indicating that one record was updated.
  /// A return value of 0 indicates that no record was found with the provided
  /// `transferId`.
  ///
  /// Throws:
  ///   - Exception: If the update operation fails, an exception is thrown with
  ///     an error message detailing the cause of the failure. This ensures that
  ///     any failure in the process of disassociating the transfer is clearly
  ///     communicated to the caller.
  Future<int> setNullTransferId(int id);
}

class TransferStore implements TransferStorer {
  final _databaseManager = locator<DatabaseManager>();

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
      final message = 'TransferStore.insertTransfer: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransferStore.deleteTransferId: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransferStore.queryTranferId: $err';
      log(message);
      throw Exception(message);
    }
  }

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
      final message = 'TransferStore.updateTransfer: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> setNullTransferId(int id) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.update(
        transfersTable,
        {
          transferTransId0: null,
          transferTransId1: null,
          transferAccount0: null,
          transferAccount1: null,
        },
        where: '$transferId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      final message = 'TransferStore.setNullTransferId: $err';
      log(message);
      throw Exception(message);
    }
  }
}
