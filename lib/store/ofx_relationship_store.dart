import 'dart:developer';

import 'package:finances/store/constants.dart';
import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'database_manager.dart';

/// Abstract class defining the interface for storing and managing OFX
/// relationship data in a database.
///
/// This interface specifies methods for inserting, updating, querying by
/// bank ID, and deleting OFX relationship records, such as accounts
/// or transactions, associated with a specific bank ID.
///
/// Methods:
/// - `insert`: Adds a new OFX relationship record to the database.
/// - `update`: Updates an existing OFX relationship record in the database.
/// - `queryBankId`: Retrieves an OFX relationship record by its associated bank
///   ID.
/// - `deleteId`: Removes an OFX relationship record from the database by its
///   ID.
///
/// These methods are designed to be implemented by concrete classes that
/// handle specific types of OFX relationships, such as accounts or
/// transactions, providing a uniform interface for operations on OFX data.
///
/// Usage:
/// Implement this interface in classes that manage OFX relationship data,
/// such as account or transaction storers. This allows for consistent
/// access and manipulation of OFX data across different parts of an
/// application.
abstract class OfxRalationshipStorer {
  /// Inserts a new OFX relationship into the database.
  ///
  /// This method adds a new OFX relationship to the database using the provided
  /// map of values. It returns the ID of the newly inserted relationship. In
  /// case of a conflict, the insertion will be aborted. If an error occurs
  /// during insertion, it logs the error and throws an exception.
  ///
  /// Parameters:
  /// - `map`: A map containing the key-value pairs for the OFX relationship
  ///   attributes to be inserted into the database.
  ///
  /// Returns:
  /// - The ID of the newly inserted OFX relationship in the database.
  ///
  /// Throws:
  /// - An exception if the insertion fails due to a database error.
  ///
  /// Usage:
  /// Use this method to add a new OFX relationship to the database. This can be
  /// useful for tracking relationships between various OFX entities, such as
  /// accounts and transactions.
  Future<int> insert(Map<String, dynamic> map);

  /// Updates an existing OFX relationship in the database.
  ///
  /// This method updates the attributes of an OFX relationship identified by
  /// the `ofxRelId` in the provided map. It returns the number of rows affected
  /// by the update. If an error occurs during the update process, it logs the
  /// error and throws an exception.
  ///
  /// Parameters:
  /// - `map`: A map containing the key-value pairs of the OFX relationship
  ///   attributes to be updated. Must include `ofxRelId` to specify which
  ///   relationship to update.
  ///
  /// Returns:
  /// - The number of rows affected by the update.
  ///
  /// Throws:
  /// - An exception if the update fails due to a database error.
  ///
  /// Usage:
  /// Use this method to update the details of an existing OFX relationship in
  /// the database. This can help maintain accurate and up-to-date relationship
  /// information between different OFX entities.
  Future<int> update(Map<String, dynamic> map);

  /// Queries the database for an OFX relationship by bank ID.
  ///
  /// This method searches the database for an OFX relationship using the given
  /// bank ID. It returns a map containing the OFX relationship attributes if
  /// found. If no relationship is found or an error occurs, it logs the error
  /// and throws an exception.
  ///
  /// Parameters:
  /// - `bankId`: The bank ID used to query the OFX relationship.
  ///
  /// Returns:
  /// - A map of the OFX relationship attributes if a relationship with the
  ///   specified bank ID is found. Returns null if no relationship is found.
  ///
  /// Throws:
  /// - An exception if querying fails due to a database error.
  ///
  /// Usage:
  /// Use this method to retrieve an OFX relationship by its associated bank ID.
  /// This can be useful when needing to reference specific relationships based
  /// on banking information.
  Future<Map<String, dynamic>?> queryBankId(String bankId);

  /// Deletes an OFX relationship by ID from the database.
  ///
  /// This method attempts to delete an OFX relationship specified by its ID.
  /// It returns the number of rows affected (should be 1 if deletion is
  /// successful). In case of failure or if the specified ID does not exist, it
  /// logs the error and throws an exception.
  ///
  /// Parameters:
  /// - `id`: The ID of the OFX relationship to be deleted.
  ///
  /// Returns:
  /// - The number of rows affected by the delete operation. Ideally, this
  ///   should be 1, indicating that the deletion was successful.
  ///
  /// Throws:
  /// - An exception if the deletion fails due to a database error or if the
  ///   specified ID does not exist.
  ///
  /// Usage:
  /// Use this method to remove an OFX relationship from the database, typically
  /// when the relationship is no longer needed or valid. Ensure that the ID
  /// provided is correct to avoid unintentional deletions.
  Future<int> deleteId(int id);
}

class OfxRalationshipStore implements OfxRalationshipStorer {
  final _databaseManager = locator<DatabaseManager>();

  @override
  Future<int> insert(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;
      int result = await database.insert(
        ofxRelationshipTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'OfxRalationshipStore.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> update(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;
      int id = map[ofxRelId];
      int result = await database.update(
        ofxRelationshipTable,
        map,
        where: '$ofxRelId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      final message = 'OfxRalationshipStore.update: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>?> queryBankId(String bankId) async {
    try {
      final database = await _databaseManager.database;
      List<Map<String, dynamic>> result = await database.query(
        ofxRelationshipTable,
        where: '$ofxRelBankId = ?',
        whereArgs: [bankId],
      );
      return result.first;
    } catch (err) {
      final message = 'OfxRalationshipStore.queryBankId: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> deleteId(int id) async {
    try {
      final database = await _databaseManager.database;
      final result = await database.delete(
        ofxRelationshipTable,
        where: '$ofxRelId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      final message = 'OfxRalationshipStore.deleteId: $err';
      log(message);
      throw Exception(message);
    }
  }
}
