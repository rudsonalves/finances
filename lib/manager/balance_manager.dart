import '../common/models/balance_db_model.dart';
import '../common/models/extends_date.dart';
import '../locator.dart';
import '../repositories/balance/abstract_balance_repository.dart';

class BalanceManager {
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
  static Future<BalanceDbModel> balanceInDate({
    required ExtendedDate date,
    required int accountId,
  }) async {
    // get today date only
    final onlyDate = date.onlyDate;

    final balanceRepository = locator<AbstractBalanceRepository>();
    // get a balance from accountId in this date
    var balance = await balanceRepository.getBalanceInDate(
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
      // Create a new balance with the closing of the previus one
      balance.balanceId = null;
      balance.balanceDate = onlyDate;
      balance.balanceOpen = balance.balanceClose;
    }

    // Write new balance and return it
    balanceRepository.insertBalance(balance);

    return balance;
  }
}
