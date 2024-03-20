import '../common/models/balance_db_model.dart';
import '../common/models/extends_date.dart';
import '../locator.dart';
import '../repositories/balance/abstract_balance_repository.dart';

sealed class BalanceManager {
  static final repository = locator<AbstractBalanceRepository>();

  BalanceManager._();

  /// Adds or retrieves a balance for a specific account on a given date.
  ///
  /// This method ensures that there is a balance entry for the specified
  /// `accountId` on the `date` provided. If a balance entry already exists for
  /// this date, it is returned. Otherwise, a new balance entry is created and
  /// returned.
  ///
  /// The newly created balance will inherit the closing balance of the last
  /// available balance as its opening balance if a previous balance exists. If
  /// no previous balance exists, a new balance entry is initialized with
  /// default values.
  ///
  /// Parameters:
  /// - `date`: The `ExtendedDate` object representing the date for which the
  ///   balance is being added or retrieved. The time component is ignored,
  ///   focusing only on the date.
  /// - `accountId`: The integer ID of the account for which the balance is
  ///   being added or retrieved.
  ///
  /// Returns:
  /// - A `Future<BalanceDbModel>` that completes with the balance for the given
  ///   date. If no balance existed for this date, a new one is created,
  ///   inserted into the repository, and returned.
  ///
  /// Throws:
  /// - This method might throw exceptions if there are issues accessing the
  ///   balance repository or if there are problems creating a new balance entry
  ///   in the database.
  ///
  /// Example Usage:
  /// ```dart
  /// final balance = await addBalanceInDate(
  ///   date: ExtendedDate.now(),
  ///   accountId: 1,
  /// );
  /// ```
  ///
  /// This method is particularly useful for ensuring that financial
  /// applications maintain continuity in balance tracking, automatically
  /// handling missing balance entries for specific dates.
  static Future<BalanceDbModel> getBalanceInDate({
    required ExtendedDate date,
    required int accountId,
  }) async {
    // // get date only
    final onlyDate = date.onlyDate;

    var balance = await getClosedBalanceToDate(
      date: onlyDate,
      accountId: accountId,
    );

    // if exists and is for today and return it
    if (balance != null && balance.balanceDate == onlyDate) {
      return balance;
    }

    if (balance == null) {
      // Create a new balance if there is no previous one
      balance = BalanceDbModel(
        balanceAccountId: accountId,
        balanceDate: onlyDate,
      );
    } else {
      // Create a NEW balance with the closing of the previus one
      balance.balanceId = null;
      balance.balanceDate = onlyDate;
      balance.balanceTransCount = 0;
      balance.balanceOpen = balance.balanceClose;
    }

    // Write new balance and return it
    await repository.insert(balance);

    return balance;
  }

  /// Retrieves the most recent closed balance for a given account up to a
  /// specified date.
  ///
  /// This method fetches the last balance record for the specified account that
  /// is on or before the provided date. It is useful for obtaining the state of
  /// an account's balance as of a particular date without considering any
  /// transactions that occurred after that date.
  ///
  /// Parameters:
  /// - `date`: An `ExtendedDate` object representing the date up to which the
  ///   balance is requested. The time component is ignored, focusing solely on
  ///   the date.
  /// - `accountId`: The ID of the account for which the balance is being
  ///   requested.
  ///
  /// Returns:
  /// - A `Future<BalanceDbModel?>` that completes with the balance model if a
  ///   balance record exists for the given date and account ID. If no such
  ///   balance is found, returns null.
  ///
  /// Usage:
  /// ```dart
  /// var closedBalance = await TransferManager.getClosedBalanceToDate(
  ///   date: ExtendedDate.now(),
  ///   accountId: 1,
  /// );
  /// if (closedBalance != null) {
  ///   print("Balance as of date: ${closedBalance.balanceClose}");
  /// } else {
  ///   print("No balance record found for the given date and account.");
  /// }
  /// ```
  ///
  /// Note:
  /// - This method is particularly useful for financial reporting and audit
  ///   purposes, where it is necessary to ascertain the account balance at the
  ///   close of a specific date.
  static Future<BalanceDbModel?> getClosedBalanceToDate({
    required ExtendedDate date,
    required int accountId,
  }) async {
    // get date only
    final onlyDate = date.onlyDate;

    // get a balance from accountId in this date
    var balance = await repository.getInDate(
      date: onlyDate,
      accountId: accountId,
    );

    return balance;
  }
}
