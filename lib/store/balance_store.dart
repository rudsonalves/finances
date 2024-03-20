import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants.dart';
import 'database_manager.dart';

/// Manages database operations for balance-related data.
///
/// This class provides methods to insert, query, update, and delete balance
/// records in the database. It uses the DatabaseManager to facilitate
/// interactions with the database.
abstract class BalanceStorer {
  /// Inserts a new balance record into the database.
  ///
  /// This method adds a new balance entry to the database based on the provided
  /// balance details. It uses the `balanceTable` to store the balance data and
  /// handles any conflicts by aborting the insert operation.
  ///
  /// Parameters:
  /// - `balanceMap`: A map containing the key-value pairs of balance data to be
  ///   inserted into the database. The keys should match the column names of
  ///   the balance table.
  ///
  /// Returns:
  /// - A `Future<int>` that completes with the ID of the newly inserted balance
  ///   record if the operation is successful. If an error occurs or the
  ///   operation is aborted due to a conflict, -1 is returned.
  ///
  /// Exceptions:
  /// - If an exception is caught during the insertion process, it logs the
  ///   error message and returns -1. This provides a simple way to handle
  ///   errors while informing the caller of the failure.
  ///
  /// Example Usage:
  /// ```dart
  /// var balanceData = {
  ///   "accountId": 1,
  ///   "date": DateTime.now().millisecondsSinceEpoch,
  ///   "open": 1000.0,
  ///   "close": 1500.0,
  /// };
  /// var balanceId = await insertBalance(balanceData);
  /// if (balanceId != -1) {
  ///   print("Balance inserted successfully with ID $balanceId");
  /// } else {
  ///   print("Failed to insert balance");
  /// }
  /// ```
  ///
  /// This method simplifies the process of adding balance records to the
  /// database, ensuring that data integrity is maintained through the use
  /// of conflict handling strategies.
  Future<int> insert(Map<String, dynamic> balanceMap);

  /// Queries the database for a specific balance record by its ID.
  ///
  /// This method retrieves a balance record from the database using its unique
  /// identifier. It performs a query on the `balanceTable` to find the balance
  /// entry that matches the provided ID.
  ///
  /// Parameters:
  /// - `id`: The integer ID of the balance record to retrieve.
  ///
  /// Returns:
  /// - A `Future<Map<String, dynamic>?>` that completes with the balance record
  ///   as a map if found. If no record is found, or if an error occurs during
  ///   the query, `null` is returned.
  ///
  /// Exceptions:
  /// - Catches and logs any errors that occur during the database query. If an
  ///   error is encountered, the method returns `null` to indicate that the
  ///   balance record could not be retrieved.
  ///
  /// Example Usage:
  /// ```dart
  /// var balanceId = 1;
  /// var balance = await queryBalanceId(balanceId);
  /// if (balance != null) {
  ///   print("Balance found: $balance");
  /// } else {
  ///   print("Balance with ID $balanceId not found or error occurred.");
  /// }
  /// ```
  ///
  /// This method is essential for retrieving balance details based on their ID,
  /// providing a straightforward way to access specific financial records
  /// within the application.
  Future<Map<String, dynamic>?> queryId(int id);

  /// Retrieves the most recent balance record for a given account up to a
  /// specified date.
  ///
  /// This method searches the `balanceTable` for the closest balance record
  /// for an account that precedes or matches a specific date. It is designed to
  /// provide the latest financial state of an account before or on the given
  /// date.
  ///
  /// Parameters:
  /// - `account`: The ID of the account for which the balance is queried.
  /// - `date`: The cutoff date (inclusive) for the balance query, represented
  ///           as an integer timestamp.
  ///
  /// Returns:
  /// - A `Future<Map<String, dynamic>?>` that completes with a map containing
  ///   the balance record if found. If no suitable record is found, or if an
  ///   error occurs during the query, `null` is returned.
  ///
  /// Exceptions:
  /// - If an error occurs during the database query, the error is logged, and
  ///   the method returns `null`, indicating the balance record could not be
  ///   retrieved.
  ///
  /// Example Usage:
  /// ```dart
  /// var accountId = 1;
  /// var date = DateTime.now().millisecondsSinceEpoch;
  /// var balance = await queryBalanceInDate(account: accountId, date: date);
  /// if (balance != null) {
  ///   print("Latest balance up to date: $balance");
  /// } else {
  ///   print("No balance record found up to date or error occurred.");
  /// }
  /// ```
  ///
  /// Utilizing this method allows for a targeted retrieval of balance
  /// information, facilitating accurate financial tracking and analysis within
  /// the application.
  Future<Map<String, dynamic>?> queryInDate(
      {required int accountId, required int date});

  /// Retrieves all balance records for a specified account after a given date.
  ///
  /// This method performs a query on the `balanceTable` to find all balance
  /// records associated with a particular account that are dated after the
  /// specified date. The balances are returned in ascending order by date,
  /// allowing for chronological processing.
  ///
  /// Parameters:
  /// - `account`: The ID of the account whose balance records are being
  ///              queried.
  /// - `date`: The cutoff date, represented as an integer timestamp. Only
  ///           balances dated after this date are included in the results.
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>>` that completes with a list of
  ///   maps, each representing a balance record. If no records are found, or if
  ///   an error occurs during the query, an empty list is returned.
  ///
  /// Exceptions:
  /// - Any errors encountered during the database query are logged, and the
  ///   method returns an empty list to signify that no records were retrieved
  ///   or that an issue occurred.
  ///
  /// Example Usage:
  /// ```dart
  /// var accountId = 1;
  /// var date = DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch;
  /// var balances = await queryAllBalanceAfterDate(account: accountId, date: date);
  /// if (balances.isNotEmpty) {
  ///   print("Balances found after date: $balances");
  /// } else {
  ///   print("No balance records found after the specified date.");
  /// }
  /// ```
  ///
  /// This method is essential for obtaining a sequence of balance changes over
  /// time, facilitating detailed financial analysis and reporting for an
  /// account.
  Future<List<Map<String, dynamic>>> queryAllAfterDate(
      {required int accountId, required int date});

  /// Updates an existing balance record in the database.
  ///
  /// This method applies modifications to a balance record identified by its
  /// unique ID. It updates the record in the `balanceTable` with the new data
  /// provided in the `balanceMap`. This operation allows for adjusting balance
  /// details, such as the open and close amounts, or the date of the balance.
  ///
  /// Parameters:
  /// - `balanceMap`: A map containing the balance data to update. It must include
  ///   the balance ID (`balanceId`) to specify which record to update, along with
  ///   any other balance fields that need to be modified.
  ///
  /// Exceptions:
  /// - If an error occurs during the update operation, it is logged. This method
  ///   does not return a value, so errors do not alter the control flow. However,
  ///   they are important for debugging and operational logging.
  ///
  /// Example Usage:
  /// ```dart
  /// var updatedBalanceData = {
  ///   "balanceId": 1, // ID of the balance to update
  ///   "balanceOpen": 5000.0,
  ///   "balanceClose": 7500.0,
  ///   // other balance fields as needed...
  /// };
  /// await updateBalance(updatedBalanceData);
  /// ```
  ///
  /// This method is crucial for maintaining accurate and up-to-date balance
  /// information within the system, supporting financial tracking and
  /// management capabilities.
  Future<void> update(Map<String, dynamic> balanceMap);

  /// Deletes a balance record from the database by its ID.
  ///
  /// This method removes a specific balance record from the `balanceTable`,
  /// using the provided `id` to locate the record. It is intended for
  /// situations where a balance record is no longer needed or must be removed
  /// for correctness.
  ///
  /// Parameters:
  /// - `id`: The unique identifier of the balance record to delete.
  ///
  /// Exceptions:
  /// - If an error occurs during the deletion process, the error is logged.
  ///   Similar to `updateBalance`, this method does not communicate errors back
  ///   to the caller beyond logging, maintaining a void return type.
  ///
  /// Usage:
  /// ```dart
  /// await deleteBalance(1);
  /// ```
  ///
  /// Employing this method ensures that balance records can be removed as
  /// needed, maintaining the accuracy and relevancy of the financial dataset.
  Future<void> deleteId(int id);

  /// Deletes a balance record if it has no associated transactions.
  ///
  /// This method removes a balance entry from the `balanceTable` if, and only
  /// if, the `balanceTransCount` is zero, indicating no transactions are linked
  /// to this balance. It is particularly useful for cleaning up placeholder or
  /// erroneously created balance records that remain unused.
  ///
  /// Parameters:
  /// - `id`: The ID of the balance record to be conditionally deleted.
  ///
  /// Exceptions:
  /// - Catches and logs any errors encountered during the conditional deletion
  ///   process. Similar to the other methods, errors are logged for
  ///   troubleshooting.
  ///
  /// Usage:
  /// ```dart
  /// await deleteEmptyBalance(1);
  /// ```
  ///
  /// This method enhances data integrity by ensuring only meaningful balance
  /// records are retained within the database, avoiding clutter from unused
  /// entries.
  Future<void> deleteEmptyBalance(int id);

  /// Deletes all balance records with no associated transactions from the
  /// database.
  ///
  /// This method searches the `balanceTable` for balance records where the
  /// count of associated transactions (`balanceTransCount`) is zero and deletes
  /// them. It is useful for cleaning up balance records that were initialized
  /// but never used due to the lack of transactions affecting them.
  ///
  /// Returns the number of rows (balance records) affected by the operation. If
  /// the operation is successful, this number represents the count of balance
  /// records that were deleted because they had no associated transactions. A
  /// return value of 0 indicates that no such balance records were found.
  ///
  /// Throws:
  ///   - Exception: If the delete operation encounters an error, an exception
  ///     is thrown with a detailed error message. This ensures that any issues
  ///     encountered during the execution of this method are communicated back
  ///     to the caller, facilitating error handling and debugging.
  Future<int> deleteAllEmptyBalances();
}

class BalanceStore implements BalanceStorer {
  final _databaseManager = locator<DatabaseManager>();

  @override
  Future<int> insert(Map<String, dynamic> balanceMap) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.insert(
        balanceTable,
        balanceMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'BalanceStore.insertBalance: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>?> queryId(int id) async {
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
      final message = 'BalanceStore.queryBalanceId: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>?> queryInDate({
    required int accountId,
    required int date,
  }) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.query(
        balanceTable,
        where: '$balanceDate <= ? AND $balanceAccountId = ?',
        whereArgs: [date, accountId],
        orderBy: '$balanceDate DESC',
        limit: 1,
      );
      if (result.isEmpty) return null;
      return result[0];
    } catch (err) {
      final message = 'BalanceStore.queryBalanceInDate: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryAllAfterDate({
    required int accountId,
    required int date,
  }) async {
    final database = await _databaseManager.database;

    try {
      final result = await database.query(
        balanceTable,
        where: '$balanceDate > ? AND $balanceAccountId = ?',
        whereArgs: [date, accountId],
        orderBy: '$balanceDate ASC',
      );
      if (result.isEmpty) return [];
      return result;
    } catch (err) {
      final message = 'BalanceStore.queryAllBalanceAfterDate: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> balanceMap) async {
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
      final message = 'BalanceStore.updateBalance: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<void> deleteId(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      final message = 'BalanceStore.deleteBalance: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<void> deleteEmptyBalance(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        balanceTable,
        where: '$balanceId = ? AND $balanceTransCount = ?',
        whereArgs: [id, 0],
      );
    } catch (err) {
      final message = 'BalanceStore.deleteEmptyBalance: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> deleteAllEmptyBalances() async {
    try {
      final database = await _databaseManager.database;

      final result = await database.delete(
        balanceTable,
        where: '$balanceTransCount = ?',
        whereArgs: [0],
      );

      return result;
    } catch (err) {
      final message = 'BalanceStore.deleteEmptyBalances: $err';
      log(message);
      throw Exception(message);
    }
  }
}
