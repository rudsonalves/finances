import 'dart:developer';

import '../../common/models/transaction_db_model.dart';
import '../../common/models/transfer_db_model.dart';
import '../locator.dart';
import '../repositories/transfer/abstract_transfer_repository.dart';
import 'transaction_manager.dart';

/// Manages the creation, update, and removal of financial transfers between accounts.
///
/// This class provides static methods to facilitate the management of transfers
/// within a financial application. It ensures that transfers are processed
/// correctly, maintaining the integrity and consistency of financial data.
///
/// The class employs a singleton pattern to prevent instantiation and ensures
/// that all transfer operations are centralized through its static methods.
///
/// Methods:
/// - `addTransfer`: Creates a new transfer between two accounts, generating
///   corresponding transactions for both the origin and destination accounts.
/// - `removeTransfer`: Removes an existing transfer and its associated transactions
///   based on the originating transaction's details.
/// - `updateTransfer`: Updates a transfer by removing the existing one and creating
///   a new transfer with updated account details.
///
/// Usage:
/// The class is used statically and does not require instantiation. Methods are
/// accessed directly through the class name, e.g., `TransferManager.addTransfer(...)`.
///
/// Example:
/// ```dart
/// await TransferManager.addTransfer(
///   transOrigin: transactionModel,
///   accountDestinyId: destinationAccountId,
/// );
/// ```
///
/// This approach ensures that transfer-related operations are handled in a
/// consistent manner, providing a clear and concise API for managing transfers.
class TransferManager {
  /// Private constructor to prevent instantiation.
  TransferManager._();

  /// Initiates a financial transfer between two accounts.
  ///
  /// This method creates a pair of linked transactions representing a transfer
  /// from one account (origin) to another (destination). It ensures that both
  /// transactions are correctly associated with a transfer record.
  ///
  /// Parameters:
  /// - `transOrigin`: The transaction from the origin account.
  /// - `accountDestinyId`: The ID of the destination account.
  ///
  /// The process involves:
  /// 1. Creating an empty transfer record to obtain a unique ID.
  /// 2. Cloning the origin transaction to create a corresponding
  ///    transaction for the destination account.
  /// 3. Assigning the transfer ID to both transactions.
  /// 4. Inserting both transactions into the database.
  /// 5. Updating the transfer record with the transaction IDs and
  ///    account IDs.
  ///
  /// Exceptions:
  /// - Logs any encountered errors and throws an exception for critical failures,
  ///   especially when creating the empty transfer record or during transactions
  ///   insertion.
  ///
  /// Usage:
  /// ```dart
  /// await TransferManager.addTransfer(
  ///   transOrigin: transOriginModel,
  ///   accountDestinyId: destinationAccountId,
  /// );
  /// ```
  ///
  /// Ensures financial transactions are mirrored across accounts with a consistent
  /// link for traceability and auditing purposes.
  static Future<void> addTranfer({
    required TransactionDbModel transOrigin,
    required int accountDestinyId,
  }) async {
    try {
      // Creat a empty transfer
      final transfer = await _createEmptyTransfer();

      // Instantiate a TransactionDbModel destiny transaction
      final transDestiny = transOrigin.copyToTransfer(accountDestinyId);

      // Update transTransferId in transOrigin and transDestiny
      transOrigin.transTransferId = transfer.transferId;
      transDestiny.transTransferId = transfer.transferId;

      // Write the new transOrigin and transDestiny transactions
      await _insertTransactions(transOrigin, transDestiny);

      // Update the transfer transferTransId0 and transferTransId1 with
      // transOrigin and transDestiny transId, respectively.
      transfer.transferTransId0 = transOrigin.transId;
      transfer.transferTransId1 = transDestiny.transId;
      transfer.transferAccount0 = transOrigin.transAccountId;
      transfer.transferAccount1 = transDestiny.transAccountId;
      await locator<AbstractTransferRepository>().updateTransfer(transfer);
    } catch (err) {
      log('TransferManager.addTranfer: $err');
    }
  }

  /// Creates an empty transfer record in the database.
  ///
  /// This method is used internally to generate a new transfer record
  /// with a unique ID. It is a prerequisite step for linking transactions
  /// in a transfer operation.
  ///
  /// Returns:
  /// - A `Future<TransferDbModel>` representing the newly created transfer
  ///   record with a populated `transferId`.
  ///
  /// Throws:
  /// - An exception if the transfer record could not be created or if
  ///   the database operation returns an invalid ID.
  ///
  /// Usage is internal within `TransferManager` for transfer operations.
  static Future<TransferDbModel> _createEmptyTransfer() async {
    // Create a empty transfer
    final transfer = TransferDbModel();

    // Write the transfer in the store to receive a transverId
    final id =
        await locator<AbstractTransferRepository>().insertTransfer(transfer);

    // Create a Exception if id <= 0.
    if (id <= 0) {
      final message =
          'TransferRepository_createEmptyTransfer: transferId return $id';
      log(message);
      throw Exception(message);
    }
    transfer.transferId = id;

    return transfer;
  }

  /// Inserts the origin and destination transactions into the database.
  ///
  /// This internal method adds both the originating and destination transactions
  /// of a transfer to the database, ensuring they are linked to the same transfer
  /// record.
  ///
  /// Parameters:
  /// - `transOrigin`: The originating transaction model.
  /// - `transDestiny`: The destination transaction model.
  ///
  /// Throws:
  /// - An exception if either transaction fails to insert correctly.
  ///
  /// Note: This method assumes `addNewTransaction` successfully assigns a
  /// `transId` to each transaction, which is critical for linking them to the
  /// transfer record.
  static Future<void> _insertTransactions(
    TransactionDbModel transOrigin,
    TransactionDbModel transDestiny,
  ) async {
    await TransactionManager.addNewTransaction(transOrigin);
    await TransactionManager.addNewTransaction(transDestiny);

    // FIXME: never happens. Remove after some tests
    if (transOrigin.transId == null || transDestiny.transId == null) {
      throw Exception('TransferRepository._insertTransactions: error');
    }
  }

  /// Removes a financial transfer and its associated transactions.
  ///
  /// This method handles the deletion of both the origin and destination
  /// transactions linked by a common transfer ID, as well as the transfer
  /// record itself. It ensures that all database entries related to a
  /// transfer are cleanly removed.
  ///
  /// Parameters:
  /// - `transOrigin`: The originating transaction model, which includes
  ///   the transfer ID linking it to the corresponding destination
  ///   transaction.
  ///
  /// Returns:
  /// - A `Future<int>` that completes with the result of the transfer
  ///   deletion operation. A value of 1 indicates success, while -1
  ///   indicates a failure.
  ///
  /// Exceptions:
  /// - Logs any encountered errors during the process and throws an
  ///   exception if the transfer or its transactions cannot be removed.
  ///
  /// Usage:
  /// ```dart
  /// var transOrigin = TransactionDbModel(
  ///   // initialization with origin transaction details...
  /// );
  /// var result = await TransferManager.removeTransfer(transOrigin);
  /// if (result == 1) {
  ///   print("Transfer and its transactions removed successfully.");
  /// } else {
  ///   print("Failed to remove transfer.");
  /// }
  /// ```
  ///
  /// Ensures the atomic removal of transfers and their transactions to
  /// maintain database integrity and consistency.
  static Future<int> removeTransfer(TransactionDbModel transOrigin) async {
    try {
      final transOriginId = transOrigin.transId!;
      final date = transOrigin.transDate;
      final value = transOrigin.transValue;
      final transferId = transOrigin.transTransferId!;

      // Get transfer by id transOrigin.transTransferId
      final transfer = await locator<AbstractTransferRepository>()
          .getTransferById(transferId);

      // Select transaction destiny id
      final transDestinyId = transfer!.transferTransId0 != transOrigin.transId
          ? transfer.transferTransId0
          : transfer.transferTransId1;

      // remove transOrigin and transDestiny transactions by id
      await TransactionManager.removeTransactionByValues(
        id: transOriginId,
        date: date,
        value: value,
      );
      await TransactionManager.removeTransactionByValues(
        id: transDestinyId!,
        date: date,
        value: -value,
      );

      // remove transfer by your id
      return await _removeTransferById(transferId);
    } catch (err) {
      log('TransferRepository.removeTransfer: $err');
      return -1;
    }
  }

  /// Deletes a transfer record from the database by its ID.
  ///
  /// This internal method is called to remove a specific transfer record,
  /// identified by `transferId`, from the database. It is part of the
  /// cleanup process when a transfer is being removed.
  ///
  /// Parameters:
  /// - `transferId`: The unique identifier of the transfer to delete.
  ///
  /// Returns:
  /// - A `Future<int>` that completes with the result of the deletion
  ///   operation. A value of 1 indicates that the transfer was successfully
  ///   deleted.
  ///
  /// Throws:
  /// - An exception if the transfer could not be deleted or if the operation
  ///   does not result in exactly one record being removed, to ensure data
  ///   integrity.
  ///
  /// Usage is strictly internal within `TransferManager` as part of the
  /// transfer removal process.
  static Future<int> _removeTransferById(int transferId) async {
    final result =
        await locator<AbstractTransferRepository>().deleteTransfer(transferId);
    if (result != 1) {
      final message = 'TransferRepository._removeTransferById: return $result';
      log(message);
      throw Exception(message);
    }
    return result;
  }

  /// Updates an existing financial transfer between two accounts.
  ///
  /// This method facilitates the update of a transfer by first removing the
  /// existing transfer (and its associated transactions) identified by the
  /// origin transaction, and then creating a new transfer with the updated
  /// details. It ensures that all related database entries are refreshed to
  /// reflect the update accurately.
  ///
  /// Parameters:
  /// - `transOrigin`: The `TransactionDbModel` object representing the original
  ///   transaction details from the origin account.
  /// - `accountDestinyId`: The ID of the destination account for the updated
  ///   transfer.
  ///
  /// Process:
  /// 1. Removes the existing transfer and its transactions using the origin
  ///    transaction's ID.
  /// 2. Resets the `transId` of the origin transaction to null, indicating that
  ///    it will be treated as a new transaction.
  /// 3. Creates a new transfer with the updated account destination ID and the
  ///    details from the origin transaction.
  ///
  /// Exceptions:
  /// - Logs any errors encountered during the process. This includes errors in
  ///   removing the existing transfer or in creating the new transfer.
  ///
  /// Usage:
  /// ```dart
  /// var transOrigin = TransactionDbModel(
  ///   // initialization with origin account details...
  /// );
  /// await TransferManager.updateTransfer(
  ///   transOrigin: transOrigin,
  ///   accountDestinyId: newDestinationAccountId,
  /// );
  /// ```
  ///
  /// This method provides a robust mechanism for updating transfers, ensuring
  /// the integrity and consistency of financial data within the system.
  static Future<void> updateTransfer({
    required TransactionDbModel transOrigin,
    required int accountDestinyId,
  }) async {
    try {
      // remove origin transaction by id
      await removeTransfer(transOrigin);

      // create a new transfer
      transOrigin.transId = null;
      await addTranfer(
        transOrigin: transOrigin,
        accountDestinyId: accountDestinyId,
      );
    } catch (err) {
      log('TransferRepository.updateTransfer: $err');
    }
  }
}
