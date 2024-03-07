import '../../common/models/balance_db_model.dart';
import '../../common/models/extends_date.dart';

abstract class AbstractBalanceRepository {
  /// Inserts a [BalanceDbModel] instance into the database.
  ///
  /// This method attempts to insert a new balance record into the database
  /// by converting the [BalanceDbModel] instance into a map representation
  /// and calling the underlying data store's insert method.
  ///
  /// Upon successful insertion, the method updates the `balanceId` of the
  /// [BalanceDbModel] instance with the newly generated ID from the database.
  /// This ID is then returned to the caller.
  ///
  /// If the insertion fails and a negative ID is returned from the data store,
  /// this method logs the error and throws an [Exception] indicating the failure.
  ///
  /// - Parameters:
  ///   - [balance]: The [BalanceDbModel] instance to be inserted into the database.
  ///
  /// - Returns:
  ///   A [Future] that resolves to the ID of the inserted balance record.
  ///
  /// - Throws:
  ///   - [Exception] if the insertion fails and a negative ID is returned.
  ///
  /// Example:
  /// ```dart
  /// final balance = BalanceDbModel(...);
  /// final id = await insertBalance(balance);
  /// print('Inserted balance with id $id');
  /// ```
  ///
  /// Note: Ensure that the database and the `_store` instance are properly
  /// initialized before calling this method.
  Future<int> insertBalance(BalanceDbModel balance);

  /// Retrieves a balance record by its ID from the database.
  ///
  /// This method queries the database for a balance record with the specified
  /// `id`. It utilizes the underlying data store's query method to fetch the
  /// balance details. If a record is found, it is converted from a map
  /// representation back into a [BalanceDbModel] instance and returned.
  ///
  /// - Parameters:
  ///   -`id`: The unique identifier of the balance record to be retrieved.
  ///
  /// - Returns:
  ///   A `Future` that resolves to the [BalanceDbModel] instance corresponding to the specified [id].
  ///
  /// - Throws:
  ///   - `Exception` if no record is found for the specified `id`, indicating an unexpected null value.
  ///
  /// Example usage:
  /// ```dart
  /// final int id = 1;
  /// final balance = await getBalanceId(id);
  /// print('Retrieved balance: ${balance.toString()}');
  /// ```
  ///
  /// Note: It's important to ensure that the database and the `_store` instance are properly
  /// initialized and that the `id` passed to the method corresponds to an existing balance
  /// record in the database.
  Future<BalanceDbModel> getBalanceId(int id);

  /// Retrieves a balance record for a specific date or the closest previous date.
  ///
  /// This method attempts to find a balance record for the given date. If no balance
  /// exists for the exact date, it searches for the most recent balance before the
  /// specified date. This is particularly useful for applications that need to
  /// display a balance as of a certain date, taking into account the closest historical
  /// balance if no exact match is found.
  ///
  /// The method defaults to using the current account's ID if no `accountId` is
  /// specified by the caller.
  ///
  /// Note: This method may return `null` if it is called with the latest date for which
  /// no balance exists yet. This implies that if the requested date is beyond the
  /// latest recorded balance, the method signifies the absence of any balance record
  /// by returning `null`.
  ///
  /// - Parameters:
  ///   - `date`: An [ExtendedDate] instance representing the date for which the balance is requested.
  ///   - `accountId`: An optional integer specifying the account ID to query the balance for.
  ///                  Defaults to the current account's ID if not provided.
  ///
  /// - Returns:
  ///   A [Future] that resolves to an instance of [BalanceDbModel] representing the balance
  ///   for the requested date or the closest previous date. Returns `null` if no balance
  ///   record exists for the requested date or any previous date.
  ///
  /// Example Usage:
  /// ```dart
  /// final balanceDate = ExtendedDate.fromDateTime(DateTime.now());
  /// final balance = await getBalanceInDate(date: balanceDate, accountId: 1);
  ///
  /// if (balance != null) {
  ///   print('Balance found: ${balance.amount}');
  /// } else {
  ///   print('No balance record exists for the requested date.');
  /// }
  /// ```
  ///
  /// This method is particularly useful for financial applications that need to
  /// calculate the balance as of a certain date, taking into account all transactions
  /// up to and including that date.
  Future<BalanceDbModel?> getBalanceInDate({
    required ExtendedDate date,
    int? accountId,
  });

  /// Retrieves a list of balance records after a specified date.
  ///
  /// This method is designed to fetch all balance records that are dated after the
  /// provided `date`. It is particularly useful for applications that require a
  /// sequence of balance changes following a certain point in time, allowing for
  /// analysis or display of trends over time.
  ///
  /// By default, if no `accountId` is provided, the method uses the current account's
  /// ID. This functionality supports scenarios where balances are tracked per account,
  /// and a specific account's balance history is of interest.
  ///
  /// - Parameters:
  ///   - `date`: An [ExtendedDate] instance specifying the starting point from which
  ///             balances should be retrieved. Only balances after this date are included.
  ///   - `accountId`: An optional integer specifying the account ID for which balances
  ///                  are requested. Defaults to the current account's ID if not provided.
  ///
  /// - Returns:
  ///   A [Future] that resolves to a list of [BalanceDbModel] instances, each representing
  ///   a balance record dated after the specified `date`. The list is ordered chronologically,
  ///   starting from the earliest date after the specified `date`.
  ///
  /// Example Usage:
  /// ```dart
  /// final startDate = ExtendedDate.fromDateTime(DateTime.now().subtract(Duration(days: 30)));
  /// final futureBalances = await getAllBalanceAfterDate(date: startDate, accountId: 1);
  ///
  /// for (final balance in futureBalances) {
  ///   print('Balance on ${balance.date}: ${balance.amount}');
  /// }
  /// ```
  ///
  /// This method enables financial applications to easily retrieve and display a history
  /// of balance changes, facilitating user insights into their financial trends and aiding
  /// in forecasting future balances based on past patterns.
  Future<List<BalanceDbModel>> getAllBalanceAfterDate({
    required ExtendedDate date,
    required int accountId,
  });

  /// Deletes a balance record by its ID.
  ///
  /// This method provides a way to remove a specific balance record from the database.
  /// It is useful in scenarios where a balance entry is no longer relevant or was entered
  /// erroneously and needs to be removed to maintain the accuracy of financial records.
  ///
  /// - Parameters:
  ///   - `id`: An integer representing the unique identifier of the balance record to be
  ///           deleted. This ID corresponds to the primary key of the balance record in
  ///           the database.
  ///
  /// - Returns:
  ///   A [Future] that resolves when the deletion operation is completed. If the operation
  ///   is successful, the balance record with the specified ID will no longer exist in the
  ///   database. If there is no record with the given ID, the method completes without
  ///   error, as the desired end state (the absence of the record) is already achieved.
  ///
  /// Example Usage:
  /// ```dart
  /// final balanceId = 123; // Assume this is a valid balance ID
  /// await deleteBalance(balanceId);
  /// print('Balance with ID $balanceId has been deleted.');
  /// ```
  ///
  /// This method is a critical part of managing financial records within an application,
  /// allowing for the correction of mistakes and ensuring that the database reflects the
  /// current and accurate state of user finances.
  Future<void> updateBalance(BalanceDbModel balance);

  /// Updates a balance record in the database.
  ///
  /// This method allows for the modification of an existing balance record. It is used
  /// when the details of a balance entry need to be corrected or updated to reflect new
  /// information. This could include changes in the balance amount, date, or associated
  /// account details.
  ///
  /// - Parameters:
  ///   - `balance`: A [BalanceDbModel] instance containing the updated balance information.
  ///                The `balanceId` property of this instance must correspond to the ID of
  ///                the balance record in the database that is to be updated.
  ///
  /// - Returns:
  ///   A [Future] that resolves when the update operation is completed. The database will
  ///   then reflect the updated details of the balance record as provided in the `balance`
  ///   parameter.
  ///
  /// Example Usage:
  /// ```dart
  /// final updatedBalance = BalanceDbModel(
  ///   balanceId: 123, // Assume this is a valid balance ID
  ///   amount: 5000, // New balance amount
  ///   // Other balance details...
  /// );
  /// await updateBalance(updatedBalance);
  /// print('Balance with ID ${updatedBalance.balanceId} has been updated.');
  /// ```
  ///
  /// This method ensures that financial records can be kept up-to-date, reflecting the
  /// most current information and maintaining the integrity of the financial data within
  /// the application.
  Future<void> deleteBalance(int id);

  /// Deletes a balance record if it has no associated transactions.
  ///
  /// This method removes a balance entry from the `balanceTable` if, and only if,
  /// the `balanceTransCount` is zero, indicating no transactions are linked to this
  /// balance. It is particularly useful for cleaning up placeholder or erroneously
  /// created balance records that remain unused.
  ///
  /// Parameters:
  /// - `id`: The ID of the balance record to be conditionally deleted.
  ///
  /// Exceptions:
  /// - Catches and logs any errors encountered during the conditional deletion
  ///   process. Similar to the other methods, errors are logged for troubleshooting.
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
