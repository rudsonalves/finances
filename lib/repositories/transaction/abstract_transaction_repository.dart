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

import '../../common/models/card_balance_model.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/transaction_db_model.dart';

abstract class AbstractTransactionRepository {
  /// Retrieves all transactions associated with a specific balance ID.
  ///
  /// This method fetches transactions from the database that are linked to the
  /// specified balance ID, facilitating access to all transactions impacting a
  /// particular balance record.
  ///
  /// Parameters:
  ///   - balanceId: The ID of the balance record for which transactions are sought.
  ///
  /// Returns:
  ///   A list of `TransactionDbModel` instances representing each transaction
  ///   associated with the given balance ID. The list may be empty if no
  ///   transactions are found.
  ///
  /// Note:
  ///   Utilizing this method supports detailed financial analysis and auditing
  ///   by providing a complete view of transactions for a specific balance.
  Future<List<TransactionDbModel>> getForBalanceId(int balanceId);

  /// Fetches a single transaction by its ID.
  ///
  /// This method retrieves a transaction from the database using its unique
  /// identifier. It's used for accessing detailed information about a specific
  /// transaction, such as for editing or analysis purposes.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transaction to retrieve.
  ///
  /// Returns:
  ///   A `TransactionDbModel` instance representing the transaction with the
  ///   specified ID, or null if no such transaction exists.
  ///
  /// Note:
  ///   This method is essential for operations that require interaction with
  ///   individual transaction records.
  Future<TransactionDbModel?> getId(int id);

  Future<int> insert(TransactionDbModel transaction);

  Future<List<TransactionDbModel>> queryFromOfxId(int ofxId);

  /// Deletes a transaction from the database and adjusts subsequent balance
  /// records.
  ///
  /// This method removes a specified transaction and updates the opening and
  /// closing balances of all subsequent balance records to reflect the
  /// deletion. It first validates the transaction to ensure it has both a
  /// transaction ID and a balance ID before proceeding with the deletion.
  ///
  /// Parameters:
  ///   - transId: The transaction id to be deleted.
  ///
  /// Returns:
  ///   The number of transactions deleted. Returns -1 if the transaction fails
  ///   validation checks.
  ///
  /// Note:
  ///   This method also triggers adjustments to subsequent balances to maintain
  ///   accurate financial records.
  Future<int> deleteById(int transId);
  // Future<int> deleteTransaction(TransactionDbModel transaction);

  /// Calculates the income and expense balances for a given card within a specified month.
  ///
  /// This method updates the provided `CardBalanceModel` instance with the total
  /// incomes and expenses accrued over a month. If no date is specified, it defaults
  /// to the current month. It retrieves the income and expense totals from the database
  /// for the current user's account within the specified date range.
  ///
  /// Parameters:
  ///   - cardBalance: The `CardBalanceModel` instance to be updated with the calculated
  ///                  balances.
  ///   - date: An optional `ExtendedDate` instance specifying the month for which the
  ///           balance is calculated. Defaults to the current month if not provided.
  ///
  /// Note:
  ///   This method is essential for financial tracking and reporting, allowing users
  ///   to monitor their spending and income over specific periods. The calculated
  ///   balances provide insights into financial health and budgeting efficacy.
  Future<void> getCardBalance({
    required CardBalanceModel cardBalance,
    ExtendedDate? date,
  });

  /// Retrieves a list of transactions for a specific account up to a specified
  /// start date, limited to a maximum number of transactions.
  ///
  /// This method queries the database for transactions associated with the
  /// provided account ID that occurred on or before the provided start date.
  /// The transactions are returned in descending order by date, allowing for
  /// the retrieval of the most recent transactions first. The number of
  /// transactions returned is capped at the specified maximum number to
  /// prevent excessive data loading.
  ///
  /// Parameters:
  ///   - startDate: An `ExtendedDate` instance representing the upper bound of
  ///                the date range for the query. Only transactions on or before
  ///                this date will be considered.
  ///   - accountId: The unique identifier of the account for which transactions
  ///                are to be retrieved.
  ///   - maxTransactions: The maximum number of transactions to retrieve. This
  ///                      limits the result set to the most recent transactions
  ///                      up to the specified number for the given account.
  ///
  /// Returns:
  ///   A list of maps, each representing a transaction's data for the specified
  ///   account, limited to the number specified by `maxTransactions`. If an error
  ///   occurs during the query, an empty list is returned.
  ///
  /// Throws:
  ///   Logs an error message and returns an empty list if there is an issue
  ///   executing the query.
  ///
  /// Note:
  ///   This method is particularly useful for generating reports or summaries
  ///   of recent transactions for a specific account up to a certain date,
  ///   facilitating financial analysis and record-keeping for individual accounts.
  Future<List<TransactionDbModel>> getNFromDate({
    required ExtendedDate startDate,
    required int accountId,
    required int maxTransactions,
  });

  /// Updates the status of a specific transaction in the database.
  ///
  /// This method allows for the status of a transaction, identified by its `transId`,
  /// to be updated to either active or inactive based on the `status` parameter.
  /// A boolean value is used for the `status` parameter, where `true` sets the transaction
  /// as active (status = 1) and `false` as inactive (status = 0).
  ///
  /// Parameters:
  /// - `transId`: The unique identifier of the transaction whose status is to be updated.
  /// - `status`: A boolean value indicating the new status of the transaction. `true`
  ///   for active and `false` for inactive.
  ///
  /// Returns:
  /// - A `Future<int>` that completes with the number of rows affected by the update
  ///   operation, or -1 in case of an error. The expected return value is 1 for a successful
  ///   update, indicating that exactly one row was affected.
  ///
  /// Exceptions:
  /// - Logs any errors encountered during the database operation. If an error occurs,
  ///   -1 is returned to indicate the failure.
  ///
  /// Example Usage:
  /// ```dart
  /// final updateResult = await transactionRepository.updateTransStatus(
  ///   transId: 123,
  ///   status: true,
  /// );
  /// if (updateResult == 1) {
  ///   print("Transaction status updated successfully.");
  /// } else {
  ///   print("Error updating transaction status.");
  /// }
  /// ```
  ///
  /// This method is useful for toggling the active/inactive status of transactions,
  /// allowing for enhanced control over transaction records.
  Future<int> updateStatus({
    required int transId,
    required TransStatus status,
  });
}
