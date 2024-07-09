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

import 'package:finances/store/constants/constants.dart';
import 'package:sqflite/sqflite.dart';

import '../../locator.dart';
import '../database/database_manager.dart';

/// Manages the storage of OFX transactions in a SQLite database.
///
/// `OfxTransactionStorer` provides functionality to insert, update, query,
/// and delete OFX transactions from the `ofxTransactionsTable`. These
/// transactions represent financial activities fetched from an OFX (Open
/// Financial Exchange) file or service.
abstract class OfxTransTemplateStorer {
  /// Inserts a new OFX transaction into the database.
  ///
  /// This method takes a map of OFX transaction data and inserts it into
  /// the `ofxTransactionsTable`. If the insertion is successful, it returns
  /// the newly created transaction ID. If there's a conflict or error during
  /// insertion, it logs the error and throws an exception.
  ///
  /// Parameters:
  /// - `map`: A map containing the key-value pairs of OFX
  ///   transaction data to be inserted.
  ///
  /// Returns:
  /// - The ID of the newly inserted OFX transaction.
  ///
  /// Throws:
  /// - An exception if the insertion fails due to a conflict or database error.
  ///
  /// Usage:
  /// Use this method to store new OFX transactions into the database. Ensure
  /// that the map contains all required fields and that it conforms to the
  /// schema of `ofxTransactionsTable`.
  Future<int> insert(Map<String, dynamic> map);

  /// Updates an existing OFX transaction in the database.
  ///
  /// This method takes a map of updated OFX transaction data and applies
  /// the updates to an existing transaction identified by the transaction ID
  /// present in the map. It returns the count of transactions updated, which
  /// should be 1 if the update was successful. If there's an error during
  /// the update, it logs the error and throws an exception.
  ///
  /// Parameters:
  /// - `map`: A map containing the key-value pairs of OFX
  ///   transaction data to be updated. Must include the transaction ID.
  ///
  /// Returns:
  /// - The count of OFX transactions updated in the database.
  ///
  /// Throws:
  /// - An exception if the update fails due to a database error.
  ///
  /// Usage:
  /// Use this method to update existing OFX transactions in the database.
  /// Ensure that the map contains the transaction ID and all fields that
  /// need to be updated. This method does not support partial updates; all
  /// fields must be provided in the map.
  Future<int> update(Map<String, dynamic> map);

  /// Queries an OFX transaction by its memo and account ID.
  ///
  /// This method searches for an OFX transaction that matches the given memo
  /// and account ID. It returns the first matching transaction as a map of
  /// key-value pairs if found. If no matching transaction is found or an error
  /// occurs during the query, it logs the error and throws an exception.
  ///
  /// Parameters:
  /// - `memo`: The memo text of the OFX transaction to search for.
  /// - `accountId`: The account ID associated with the transaction.
  ///
  /// Returns:
  /// - A map containing the key-value pairs of the found OFX transaction, or
  ///   null if no matching transaction is found.
  ///
  /// Throws:
  /// - An exception if the query fails due to a database error.
  ///
  /// Usage:
  /// Use this method to find an OFX transaction by its memo and the associated
  /// account ID. This can be useful for retrieving specific transactions based
  /// on their descriptions or notes.
  Future<Map<String, dynamic>?> queryMemo(String memo, int accountId);

  /// Deletes an OFX transaction from the database by its ID.
  ///
  /// This method removes an OFX transaction from the database using the
  /// provided transaction ID. It returns the count of transactions deleted,
  /// which should be 1 if the deletion was successful. In case of an error
  /// during deletion, it logs the error and throws an exception.
  ///
  /// Parameters:
  /// - `id`: The unique identifier of the OFX transaction to be deleted.
  ///
  /// Returns:
  /// - The count of OFX transactions deleted from the database.
  ///
  /// Throws:
  /// - An exception if the deletion fails due to a database error.
  ///
  /// Usage:
  /// Use this method to delete an OFX transaction from the database based on
  /// its ID. This is useful when you need to remove outdated or incorrect
  /// transaction data.
  Future<int> deleteId(int id);
}

class OfxTransTemplateStore implements OfxTransTemplateStorer {
  final _databaseManager = locator<DatabaseManager>();

  @override
  Future<int> insert(Map<String, dynamic> ofxTransactionMap) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.insert(
        ofxTransTemplateTable,
        ofxTransactionMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'OfxTransactionStore.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> update(Map<String, dynamic> ofxTransactionMap) async {
    final database = await _databaseManager.database;

    try {
      int id = ofxTransactionMap[ofxTransId];
      int result = await database.update(
        ofxTransTemplateTable,
        ofxTransactionMap,
        where: '$ofxTransId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      final message = 'OfxTransactionStore.update: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>?> queryMemo(
    String memo,
    int accountId,
  ) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, dynamic>> result = await database.query(
        ofxTransTemplateTable,
        where: '$ofxTransMemo = ? AND $ofxTransAccountId = ?',
        whereArgs: [memo, accountId],
      );

      if (result.isEmpty) return null;
      return result.first;
    } catch (err) {
      final message = 'OfxTransactionStore.queryMemo: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> deleteId(int id) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.delete(
        ofxTransTemplateTable,
        where: '$ofxTransId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      final message = 'OfxTransactionStore.deleteId: $err';
      log(message);
      throw Exception(message);
    }
  }
}
