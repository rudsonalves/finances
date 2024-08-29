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
  Future<int> deleteId(int transferId);

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
  Future<TransferDbModel?> getId(int id);

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

  /// Sets the transfer IDs and account IDs to null for a specified transfer record.
  ///
  /// This method is used to disassociate a transfer record in the `transfersTable`
  /// from its related transactions and accounts by setting `transferTransId0`,
  /// `transferTransId1`, `transferAccount0`, and `transferAccount1` fields to null.
  /// This operation targets the record identified by the provided [id].
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transfer to be updated.
  ///
  /// Returns the number of rows affected by the operation. Typically, this will
  /// be 1 if the update is successful, indicating that one record was updated.
  /// A return value of 0 indicates that no record was found with the provided
  /// `transferId`.
  ///
  /// Throws:
  ///   - Exception: If the update operation fails, an exception is thrown with
  ///     an error message detailing the cause of the failure. This ensures that
  ///     any failure in the process of disassociating the transfer is clearly
  ///     communicated to the caller.
  Future<int> setNullId(int id);
}
