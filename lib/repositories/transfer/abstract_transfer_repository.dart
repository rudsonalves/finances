import '../../common/models/transfer_db_model.dart';

/// A repository for managing transfers in a financial application.
///
/// This class implements the `AbstractTransferRepository` interface and
/// provides concrete implementations for transfer-related operations, such as
/// inserting, deleting, and retrieving transfer records from a persistent
/// store.
abstract class AbstractTransferRepository {
  /// Inserts a new transfer record into the store.
  ///
  /// Parameters:
  /// - `transfer`: A `TransferDbModel` object representing the transfer to be
  ///   inserted.
  ///
  /// Returns:
  /// - A `Future<int>` that completes with the ID of the inserted transfer. If
  ///   the insertion fails, a negative value or zero might be returned.
  ///
  /// This method also updates the `transferId` property of the provided
  /// `TransferDbModel` object with the new ID returned by the store.
  Future<int> insertTransfer(TransferDbModel transfer);

  /// Deletes a transfer record from the store by its ID.
  ///
  /// Parameters:
  /// - `transferId`: The integer ID of the transfer to be deleted.
  ///
  /// Returns:
  /// - A `Future<int>` that completes with the result of the deletion
  ///   operation.
  ///   A value of 1 indicates successful deletion, while other values indicate
  ///   failure.
  ///
  /// This method logs the result of the deletion operation for debugging
  /// purposes.
  Future<int> deleteTransfer(int transferId);

  /// Retrieves a transfer record by its ID.
  ///
  /// Parameters:
  /// - `id`: The integer ID of the transfer to retrieve.
  ///
  /// Returns:
  /// - A `Future<TransferDbModel?>` that completes with the transfer record
  ///   if found, or `null` if no transfer with the given ID exists.
  ///
  /// This method logs a message if the transfer record is not found.
  Future<TransferDbModel?> getTransferById(int id);

  /// Updates an existing transfer in the database.
  ///
  /// This method takes a `TransferDbModel` object representing the transfer
  /// with updated data and saves it to the database. The update is performed
  /// based on the `id` of the provided transfer.
  ///
  /// Parameters:
  /// - `transfer`: The `TransferDbModel` object containing the updated transfer
  ///   information.
  ///
  /// Returns:
  /// - A `Future<int>` that, upon completion, provides the number of rows
  ///   affected by the update. Ideally, this value should be 1, indicating that
  ///   one row was successfully updated.
  ///
  /// Notes:
  /// - This method relies on the specific implementation of
  ///   `_store.updateTransfer` to perform the update in the database, which in
  ///   turn, expects the `TransferDbModel` object to be converted to a map
  ///   before the call.
  /// - The function does not perform a pre-existence check of the transfer in
  ///   the database, assuming the provided `id` is valid and exists.
  Future<int> updateTransfer(TransferDbModel transfer);
}
