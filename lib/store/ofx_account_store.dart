import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants.dart';
import 'database_manager.dart';

/// Handles storage operations for OFX accounts in a database.
///
/// This class provides methods to insert, update, query, and delete OFX account
/// information in a local database. It uses the `DatabaseManager` to establish
/// and manage the database connection and operations. The class is designed to
/// support financial data management applications that require storing and
/// managing OFX account data.
abstract class OfxAccountStorer {
  /// Inserts an OFX account record into the database.
  ///
  /// This method adds a new OFX account record to the `ofxAccountTable` using
  /// the provided map of account details. It handles potential conflicts by
  /// aborting the insert operation.
  ///
  /// Parameters:
  /// - `ofxAccountMap`: A map containing the key-value pairs of OFX account
  ///   data to be inserted into the database.
  ///
  /// Returns:
  /// - The row ID of the newly inserted OFX account, if successful.
  ///
  /// Throws:
  /// - An exception if the insert operation fails due to a conflict or any
  ///   other database error.
  ///
  /// Note:
  /// The method utilizes a `conflictAlgorithm` of `ConflictAlgorithm.abort`,
  /// meaning that if a conflict occurs (such as a duplicate entry for a unique
  /// column), the operation will be aborted, and an exception will be thrown.
  /// Handle exceptions accordingly to ensure the integrity of your
  /// application's data flow.
  Future<int> insert(Map<String, dynamic> ofxAccountMap);

  /// Updates an existing OFX account record in the database.
  ///
  /// This method updates the details of an OFX account in the
  /// `ofxTransactionsTable` based on the provided map of account details. The
  /// account to be updated is identified by the `id` included in the
  /// `ofxAccountMap`.
  ///
  /// Parameters:
  /// - `ofxAccountMap`: A map containing the key-value pairs of OFX account
  ///   data to be updated. Must include an `id` key corresponding to the ID
  ///   of the account to update.
  ///
  /// Returns:
  /// - The number of rows affected by the update operation. Typically, this
  ///   will be `1` if the update was successful or `0` if no account was found
  ///   with the specified ID.
  ///
  /// Throws:
  /// - An exception if the update operation fails due to a database error.
  ///
  /// Note:
  /// The method expects the `ofxAccountMap` to include an `id` key to identify
  /// the account to be updated. Ensure the map keys correspond to the column
  /// names of the `ofxTransactionsTable`. The method returns the number of rows
  /// affected by the update, which can be used to verify the success of the
  /// operation.
  Future<int> update(Map<String, dynamic> ofxAccountMap);

  /// Queries an OFX account by its bank ID.
  ///
  /// This method retrieves an OFX account from the `ofxTransactionsTable` based
  /// on a given bank ID. It's useful for fetching account information when the
  /// bank ID is known but the account ID isn't.
  ///
  /// Parameters:
  /// - `bankId`: The bank ID associated with the OFX account to be retrieved.
  ///
  /// Returns:
  /// - A map containing the key-value pairs of the queried OFX account's data
  ///   if the account is found.
  /// - `null` if no account matches the given bank ID.
  ///
  /// Throws:
  /// - An exception if the query operation fails due to a database error or if
  ///   no account is found for the given bank ID.
  ///
  /// Note:
  /// Ensure the bank ID is correctly specified to match an existing account in
  /// the database. The method only returns the first matching account; in cases
  /// where multiple accounts may share the same bank ID, additional logic may
  /// be required to handle such scenarios.
  Future<Map<String, dynamic>?> queryBankAccountIdStartDate(
    String bankId,
    int startDate,
  );

  /// Queries a list of all OFX accounts from the database, optionally limited
  /// by a specified count.
  ///
  /// This method retrieves a list of OFX accounts ordered by the start date,
  /// allowing an optional limit to specify the maximum number of records to
  /// return. If no limit is provided, a default of 50 records is used. This
  /// method is useful for obtaining a quick snapshot of OFX accounts without
  /// needing to retrieve the entire dataset, which could be large.
  ///
  /// Parameters:
  /// - `limit`: An optional integer specifying the maximum number of records to
  ///   return. If null, defaults to 50.
  ///
  /// Returns:
  /// - A list of maps, each representing an OFX account's data.
  ///
  /// Throws:
  /// - An exception if the query fails due to an error in accessing the
  ///   database.
  ///
  /// Usage:
  /// This method can be called to display an overview of OFX accounts, such as
  /// in a user interface where only a limited number of items are shown at a
  /// time.
  ///
  /// Example:
  /// ```dart
  /// List<Map<String, dynamic>?> ofxAccounts = await repository.queryAll(20);
  /// ```

  Future<List<Map<String, dynamic>?>> queryAll(int? limit);

  /// Deletes an OFX account by its ID.
  ///
  /// This method removes an OFX account from the `ofxTransactionsTable` based
  /// on its unique ID. It's utilized when an account needs to be removed from
  /// the database, whether for cleanup or because the account is no longer
  /// valid.
  ///
  /// Parameters:
  /// - `id`: The unique identifier of the OFX account to be deleted.
  ///
  /// Returns:
  /// - The number of rows affected by the operation. Typically, this is `1` for
  ///   a successful deletion or `0` if no account was found with the provided
  ///   ID.
  ///
  /// Throws:
  /// - An exception if the delete operation fails due to a database error.
  ///
  /// Note:
  /// Before attempting to delete an account, ensure that the account ID is
  /// correct and that deleting the account won't adversely affect related data
  /// or operations within your application.
  Future<int> deleteId(int id);
}

class OfxAccountStore implements OfxAccountStorer {
  final _databaseManager = locator<DatabaseManager>();

  @override
  Future<int> insert(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;
      int result = await database.insert(
        ofxACCTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'OfxTransactionStore.insertOfxTransaction: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> update(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;
      int id = map[ofxACCId];
      int result = await database.update(
        ofxACCTable,
        map,
        where: '$ofxACCId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      final message = 'OfxTransactionStore.updateOfxTransaction: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>?> queryBankAccountIdStartDate(
    String bankAccountId,
    int startDate,
  ) async {
    try {
      final database = await _databaseManager.database;
      List<Map<String, dynamic>> result = await database.query(
        ofxACCTable,
        where: '$ofxACCStartDate = ? AND $ofxACCBankAccountId = ?',
        whereArgs: [startDate, bankAccountId],
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (err) {
      final message = 'OfxTransactionStore.queryOfxAccountBankId: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> queryAll(int? limit) async {
    try {
      final databese = await _databaseManager.database;
      final result = await databese.query(
        ofxACCTable,
        orderBy: '$ofxACCStartDate DESC',
        limit: limit ?? 50,
      );
      return result;
    } catch (err) {
      final message = 'OfxTransactionStore.queryAll: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> deleteId(int id) async {
    try {
      final database = await _databaseManager.database;
      int result = await database.delete(
        ofxACCTable,
        where: '$ofxACCId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      final message = 'OfxTransactionStore.deleteOfxAccountId: $err';
      log(message);
      throw Exception(message);
    }
  }
}
