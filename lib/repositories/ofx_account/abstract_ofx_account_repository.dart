import '../../common/models/extends_date.dart';
import '../../common/models/ofx_account_model.dart';

abstract class AbstractOfxAccountRepository {
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
  Future<int> insert(OfxAccountModel ofxAccount);

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
  Future<int> update(OfxAccountModel ofxAccount);

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
  Future<OfxAccountModel?> queryBankAccountIdStartDate(
    String bankId,
    ExtendedDate date,
  );

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
