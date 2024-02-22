import 'dart:developer';

import '../../common/models/account_db_model.dart';
import '../../locator.dart';
import '../../store/balance_store.dart';
import 'abstract_balance_repository.dart';
import '../../common/models/extends_date.dart';
import '../../common/current_models/current_account.dart';
import '../../common/models/balance_db_model.dart';

/// Facilitates management of balance records in the database.
///
/// `BalanceRepository` implements `AbstractBalanceRepository` to provide a
/// suite of functionalities for handling balance records associated with accounts.
/// It integrates with `BalanceStore` for direct database interactions and
/// leverages the `CurrentAccount` to default to the current user's
/// account when necessary.
///
/// Key Responsibilities:
/// - Inserting new balance records while ensuring data integrity by preventing
///   duplicates for the same account and date.
/// - Fetching balance records for specific dates, accounts, or based on unique
///   identifiers.
/// - Updating and deleting existing balance records to reflect changes in
///   financial status or to correct inaccuracies.
///
/// Usage:
/// This class is crucial for applications that require detailed and accurate
/// financial tracking, offering high-level methods to interact with balance
/// records. It ensures that balance data is consistent, up-to-date, and
/// reflective of all associated transactions.
class BalanceRepository implements AbstractBalanceRepository {
  final _store = BalanceStore();
  final _currentAccount = locator<CurrentAccount>();

  /// Adds a new balance record to the database.
  ///
  /// This method inserts a new balance record into the database, ensuring that there are
  /// no existing balance records for the same date and account. It initializes the new
  /// balance record's open and close values based on the most recent balance before the
  /// given date, if available. This method is designed to maintain the integrity of balance
  /// records by preventing duplicate entries for the same date and account combination
  /// and ensuring continuity in the balance records.
  ///
  /// Parameters:
  ///   - balance: An instance of `BalanceDbModel` representing the balance to be added.
  ///     The `balanceDate` and `balanceAccountId` fields must not be null.
  ///
  /// Throws:
  ///   - An exception if `balanceDate` or `balanceAccountId` is null, indicating a
  ///     logical error in the program.
  ///   - An exception if there is already an existing balance record for the specified
  ///     date and account, to prevent duplicate balance records.
  ///   - An exception if the method fails to insert the new balance record into the
  ///     database, indicated by a negative return ID.
  ///
  /// Note: This method performs several checks before inserting the new balance record,
  /// including verifying the uniqueness of the balance record for the given date and
  /// account, and setting the opening and closing balance based on the last available
  /// balance. After successful insertion, the `balanceId` of the provided `BalanceDbModel`
  /// instance is updated with the ID of the newly inserted record.
  @override
  Future<void> addNewBalance(BalanceDbModel balance) async {
    // This exception will only occur in case of a logical error in the program
    if (balance.balanceDate == null || balance.balanceAccountId == null) {
      const message =
          'addBalance: balanceDate and balanceAccountId can not be null';
      log(message);
      throw Exception(message);
    }

    final onlyDate = balance.balanceDate!.onlyDate;
    // Check if exists another balance in this date
    final balanceInDate = await getBalanceInDate(
      date: onlyDate,
      accountId: balance.balanceAccountId,
    );
    if (balanceInDate != null) {
      const message = 'addBalance: There is already a balance on this date';
      log(message);
      throw Exception(message);
    }

    // Truncates the date
    balance.balanceDate = onlyDate;

    // Get balance before date
    final beforeBalance = await getBalanceBeforeDate(
      date: balance.balanceDate!,
      accountId: balance.balanceAccountId,
    );
    if (beforeBalance != null) {
      // Set balanceOpen and balanceClose igual the last balanceClose
      balance.balanceOpen = beforeBalance.balanceClose;
      balance.balanceClose = beforeBalance.balanceClose;
    }

    // White new ballance in the database.
    int id = await _store.insertBalance(balance.toMap());
    if (id < 0) {
      throw Exception('addBalance return id $id');
    }
    // Update balance id
    balance.balanceId = id;
  }

  /// Creates a balance record for today's date for the specified account.
  ///
  /// This method checks for an existing balance record for today's date
  /// for the provided account. If found, the existing record is returned.
  /// Otherwise, a new balance record for today is created and inserted
  /// into the database.
  ///
  /// Parameters:
  ///   - account: An optional `AccountDbModel` instance for the balance record.
  ///              If null, the current account is used.
  ///
  /// Returns:
  ///   A `BalanceDbModel` instance for today's balance. This could be an
  ///   existing record or a new one if it had to be created.
  ///
  /// Throws:
  ///   Exceptions from the `addNewBalance` method if inserting the new
  ///   balance record into the database fails.
  ///
  /// Note: Utilizes `ExtendedDate.nowDate()` to get the current date without
  /// time info, ensuring balance records are handled on a daily basis. It
  /// abstracts balance record management using `getBalanceInDate` for existing
  /// records and `addNewBalance` for new records.
  @override
  Future<BalanceDbModel> createTodayBalance(AccountDbModel? account) async {
    account ??= _currentAccount;
    final onlyDate = ExtendedDate.nowDate();

    BalanceDbModel? dateBalance = await getBalanceInDate(
      date: onlyDate,
      accountId: account.accountId,
    );
    // If exists a balance in date, return it
    if (dateBalance != null) {
      return dateBalance;
    }

    // Create a new ballance from today
    final balance = BalanceDbModel(
      balanceAccountId: account.accountId,
      balanceDate: onlyDate,
    );

    await addNewBalance(balance);
    return balance;
  }

  /// Retrieves a balance record by its unique ID.
  ///
  /// This method fetches a balance record from the database using its unique
  /// identifier. It is utilized when specific balance details are needed based
  /// on the ID, such as for editing, displaying, or further processing of
  /// financial data.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the balance record to be retrieved.
  ///
  /// Returns:
  ///   A `BalanceDbModel` instance representing the balance record associated
  ///   with the given ID.
  ///
  /// Throws:
  ///   An exception if no balance record is found for the specified ID, indicating
  ///   that a balance with the given ID does not exist in the database.
  ///
  /// Note:
  ///   This method ensures direct access to a specific balance record, supporting
  ///   precise and efficient management of balance data. It is crucial for operations
  ///   that require interaction with individual balance entries.
  @override
  Future<BalanceDbModel> getBalanceId(int id) async {
    final map = await _store.queryBalanceId(id);
    if (map == null) {
      throw Exception(
          'SqfliteBalanceRepository: null value in unexpected balance');
    }
    BalanceDbModel balance = BalanceDbModel.fromMap(map);

    return balance;
  }

  /// Retrieves a specific balance record for a given date and account.
  ///
  /// This method searches for a balance record corresponding to the specified
  /// date. If an account ID is provided, the search is limited to balances
  /// associated with that account. If no account ID is specified, the method
  /// defaults to using the current account.
  ///
  /// Parameters:
  ///   - date: An `ExtendedDate` instance representing the date for which the
  ///           balance record is sought.
  ///   - accountId: An optional account ID to narrow down the search. If not
  ///                provided, the current account is used.
  ///
  /// Returns:
  ///   A `BalanceDbModel` instance representing the balance record found for
  ///   the specified date and account, or null if no matching record is found.
  ///
  /// Note:
  ///   This method is vital for obtaining balance information for specific dates,
  ///   facilitating accurate financial tracking and analysis. It ensures that
  ///   users can access their financial data efficiently for reporting, auditing,
  ///   or reconciliation purposes.
  @override
  Future<BalanceDbModel?> getBalanceInDate({
    required ExtendedDate date,
    int? accountId,
  }) async {
    accountId ??= _currentAccount.accountId!;

    final map = await _store.queryBalanceDate(
      account: accountId,
      date: date.millisecondsSinceEpoch,
    );
    if (map != null) return BalanceDbModel.fromMap(map);
    return null;
  }

  /// Retrieves the most recent balance record before a specified date for an
  /// optional account.
  ///
  /// This method fetches the balance record that is closest to, but before, the
  /// specified date. If an account ID is provided, the search is narrowed to
  /// balances associated with that account. If no account ID is specified, it
  /// defaults to the current account.
  ///
  /// Parameters:
  ///   - date: An `ExtendedDate` instance representing the cutoff date before
  ///           which the balance record is sought.
  ///   - accountId: An optional account ID to filter the balance records. If not
  ///                provided, the current account is used.
  ///
  /// Returns:
  ///   A `BalanceDbModel` instance representing the most recent balance record
  ///   found before the specified date for the given account, or null if no
  ///   such record exists.
  ///
  /// Note:
  ///   Utilizing this method is essential for financial reporting, forecasting,
  ///   and analysis tasks that require access to balance information preceding
  ///   a specific date.
  @override
  Future<BalanceDbModel?> getBalanceBeforeDate({
    required ExtendedDate date,
    int? accountId,
  }) async {
    accountId ??= _currentAccount.accountId!;

    final map = await _store.queryBalanceBeforeDate(
      account: accountId,
      date: date.millisecondsSinceEpoch,
    );
    if (map != null) return BalanceDbModel.fromMap(map);
    return null;
  }

  /// Retrieves a list of balance records after a specified date for an optional account.
  ///
  /// This method fetches all balance records that are dated after the provided date.
  /// If an account ID is specified, the results are filtered to include balances
  /// only for that account. Otherwise, it defaults to using the current account.
  ///
  /// Parameters:
  ///   - date: An `ExtendedDate` instance representing the date after which the
  ///           balance records are sought.
  ///   - accountId: An optional account ID to filter the balance records. If not
  ///                provided, the current account is used.
  ///
  /// Returns:
  ///   A list of `BalanceDbModel` instances representing the balance records
  ///   found after the specified date for the given account. The list may be empty
  ///   if no records are found.
  ///
  /// Note:
  ///   This method is essential for financial reporting, forecasting, and analysis
  ///   tasks that require access to future-dated balance information.
  @override
  Future<List<BalanceDbModel>> getAllBalanceAfterDate({
    required ExtendedDate date,
    int? accountId,
  }) async {
    accountId ??= _currentAccount.accountId!;

    final mapsList = await _store.queryAllBalanceAfterDate(
      account: accountId,
      date: date.microsecondsSinceEpoch,
    );

    final List<BalanceDbModel> balancesList =
        List.from(mapsList.map((map) => BalanceDbModel.fromMap(map)));

    return balancesList;
  }

  /// Deletes a balance record from the database by its ID.
  ///
  /// This method removes a specific balance record identified by the given ID.
  /// It is useful for managing balance records, allowing for the removal of
  /// outdated or incorrect entries.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the balance record to be deleted.
  ///
  /// Note:
  ///   Care should be taken when using this method, as deleting balance records
  ///   can affect financial reporting and analysis. Ensure that the deletion is
  ///   indeed intended and that any dependent data or calculations are updated
  ///   accordingly.
  @override
  Future<void> deleteBalance(int id) async {
    await _store.deleteBalance(id);
  }

  /// Updates an existing balance record in the database.
  ///
  /// This method modifies a balance record with new data provided in the `balance`
  /// parameter. It is used to reflect changes in account balances, such as after
  /// reconciling transactions or adjusting for errors.
  ///
  /// Parameters:
  ///   - balance: A `BalanceDbModel` instance containing the updated balance
  ///              information, including the unique ID of the record to update.
  ///
  /// Note:
  ///   The balance record to be updated is identified by the ID within the
  ///   `BalanceDbModel` instance. Ensure that this ID corresponds to an existing
  ///   record in the database. This method is critical for maintaining accurate
  ///   and up-to-date financial information.
  @override
  Future<void> updateBalance(BalanceDbModel balance) async {
    await _store.updateBalance(balance.toMap());
  }
}
