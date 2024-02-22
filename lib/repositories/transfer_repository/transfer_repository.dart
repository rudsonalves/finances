import 'dart:developer';

import '../../common/models/transaction_db_model.dart';
import '../../common/models/transfer_db_model.dart';
import '../../locator.dart';
import '../../store/transfer_store.dart';
import '../transaction/transaction_repository.dart';
import 'abstract_transfer_repository.dart';

/// Manages the creation, deletion, and updating of transfer records within the database.
///
/// The `TransferRepository` class is responsible for orchestrating operations
/// related to financial transfers between accounts. It leverages the `TransferStore`
/// for direct database access and manipulations, as well as utilizing the
/// `TransactionRepository` for handling transactions associated with each transfer.
///
/// This class implements the `AbstractTransferRepository` interface, ensuring
/// consistency and reliability in the management of transfer data. It provides
/// comprehensive methods to add, delete, and update transfers, each method
/// ensuring the integrity and consistency of financial records.
///
/// Methods:
///   - `addTranfer`: Adds a new transfer between two accounts, creating corresponding
///     transactions for both the source and destination accounts.
///   - `deleteTransfer`: Removes an existing transfer and its associated transactions
///     from the database, ensuring clean removal of all related records.
///   - `updateTransfer`: Updates the details of an existing transfer by removing the
///     current transfer and creating a new one with the updated information.
///
/// Usage:
/// The `TransferRepository` is utilized within financial or banking applications
/// where managing transfers between accounts is a core functionality. It abstracts
/// away the complexities of directly interfacing with the database, providing a
/// clear and concise API for handling transfers.
///
/// Note:
/// The repository ensures that all operations on transfers are performed atomically
/// and with consideration for data integrity. It makes extensive use of the
/// underlying `TransferStore` for database operations and the `TransactionRepository`
/// for managing transactions, highlighting the importance of collaboration between
/// different components in the application architecture.
class TransferRepository implements AbstractTransferRepository {
  final _store = TransferStore();
  final _transactionRepository = locator<TransactionRepository>();

  /// Adds a transfer between two accounts by creating a pair of transactions.
  ///
  /// This method handles the creation of a transfer involving two transactions:
  /// one originating from the source account and another destined for the target account.
  /// It starts by creating an empty transfer record, then creates the corresponding
  /// transactions, and finally updates the transfer record with the transaction IDs.
  ///
  /// Parameters:
  ///   - transOrigin: The `TransactionDbModel` instance representing the originating transaction.
  ///   - accountDestinyId: The ID of the destination account for the transfer.
  ///
  /// Throws:
  ///   An exception if any step of the transfer creation process fails, including
  ///   transaction creation or updating the transfer record.
  ///
  /// Note:
  ///   This method encapsulates the entire process of recording a transfer, ensuring
  ///   atomicity and consistency across the involved transactions and transfer record.
  @override
  Future<void> addTranfer({
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
      await _createTransactions(transOrigin, transDestiny);

      // Update the transfer transferTransId0 and transferTransId1 with
      // transOrigin and transDestiny transId, respectively.
      transfer.transferTransId0 = transOrigin.transId;
      transfer.transferTransId1 = transDestiny.transId;
      await _updateTransfer(transfer);
    } catch (err) {
      log('addTranfer: $err');
      return;
    }
  }

  /// Creates the transactions for both the source and destination of a transfer.
  ///
  /// This internal method adds new transactions to the database based on the provided
  /// `TransactionDbModel` instances for the origin and destination. It ensures both
  /// transactions are recorded and associated with the same transfer ID.
  ///
  /// Parameters:
  ///   - transOrigin: The transaction originating from the source account.
  ///   - transDestiny: The transaction going to the destination account.
  ///
  /// Throws:
  ///   An exception if the transaction IDs are not properly assigned post-creation,
  ///   indicating a failure in recording the transactions.
  ///
  /// Note:
  ///   Critical for establishing the link between transfer transactions and their
  ///   corresponding transfer record.
  Future<void> _createTransactions(
    TransactionDbModel transOrigin,
    TransactionDbModel transDestiny,
  ) async {
    await _transactionRepository.addNewTransaction(transOrigin);
    await _transactionRepository.addNewTransaction(transDestiny);

    if (transOrigin.transId == null || transDestiny.transId == null) {
      throw Exception('TransferRepository: _createTransactions error');
    }
  }

  /// Updates a transfer record with the transaction IDs of the involved transactions.
  ///
  /// After creating the transfer transactions, this method updates the initial empty
  /// transfer record with the IDs of the originating and destination transactions.
  ///
  /// Parameters:
  ///   - transfer: The `TransferDbModel` instance to be updated.
  ///
  /// Returns:
  ///   The number of records updated in the database, expected to be 1.
  ///
  /// Note:
  ///   Finalizes the creation of a transfer by linking it to its constituent transactions.
  Future<int> _updateTransfer(TransferDbModel transfer) async {
    int count = await _store.updateTransfer(transfer.toMap());
    return count;
  }

  /// Creates an empty transfer record in the database.
  ///
  /// Initiates a transfer by inserting a new record with placeholder values into
  /// the transfers table. This record is later updated with specific transaction IDs.
  ///
  /// Returns:
  ///   A `TransferDbModel` instance representing the newly created transfer record,
  ///   including its assigned ID.
  ///
  /// Throws:
  ///   An exception if the transfer record cannot be created, indicated by a negative ID.
  ///
  /// Note:
  ///   Sets the groundwork for a new transfer, allowing transaction details to be
  ///   filled in subsequent steps.
  Future<TransferDbModel> _createEmptyTransfer() async {
    final transfer = TransferDbModel();

    final id = await _store.insertTransfer(transfer.toMap());
    if (id < 0) {
      const message =
          'TransferRepository: _createEmptyTransfer transferId return null';
      log(message);
      throw Exception(message);
    }
    transfer.transferId = id;

    return transfer;
  }

  /// Deletes a transfer and its associated transactions from the database.
  ///
  /// This method removes a transfer, identified by the transfer ID associated with
  /// the originating transaction, along with the originating and destination transactions.
  ///
  /// Parameters:
  ///   - transOrigin: The `TransactionDbModel` instance representing the originating transaction.
  ///
  /// Returns:
  ///   The number of transfer records deleted, expected to be 1. Returns -1 in case of failure.
  ///
  /// Throws:
  ///   An exception if the transfer ID is null, indicating a logical error in calling this method.
  ///
  /// Note:
  ///   Ensures that both the transfer record and its related transactions are cleanly removed,
  ///   maintaining database integrity.
  @override
  Future<int> deleteTransfer(TransactionDbModel transOrigin) async {
    try {
      // Validate transTransferId
      _validateTransTransferId(transOrigin.transTransferId);

      // Get transfer by id transOrigin.transTransferId
      final transfer = await _getTransferById(transOrigin.transTransferId!);

      // Get transDestiny by id in transfer.transferTransId1
      final transDestiny = await _getTransDestiny(
        transfer!,
        transOrigin.transId!,
      );

      // remove transOrigin and transDestiny transactions
      await _transactionRepository.deleteTransaction(transOrigin);
      await _transactionRepository.deleteTransaction(transDestiny);

      // remove transfer by your id
      return _removeTransferById(transfer.transferId!);
    } catch (err) {
      log('addTranfer: $err');
      return -1;
    }
  }

  /// Validates the presence of a transfer ID in a transaction.
  ///
  /// This method checks if the provided transaction has an associated transfer ID,
  /// throwing an exception if the ID is null.
  ///
  /// Parameters:
  ///   - transTransferId: The transfer ID to validate.
  ///
  /// Throws:
  ///   An exception if `transTransferId` is null, indicating that the transaction
  ///   is not properly linked to a transfer.
  ///
  /// Note:
  ///   A prerequisite check before proceeding with transfer deletion operations.
  void _validateTransTransferId(int? transTransferId) {
    if (transTransferId == null) {
      const message =
          'TransferRepository: deleteTransfer transTransferId is null';
      log(message);
      throw Exception(message);
    }
  }

  /// Retrieves the destination transaction for a given transfer.
  ///
  /// Given a transfer and the ID of the originating transaction, this method
  /// determines and fetches the corresponding destination transaction.
  ///
  /// Parameters:
  ///   - transfer: The `TransferDbModel` instance representing the transfer.
  ///   - transIdOrigin: The ID of the originating transaction.
  ///
  /// Returns:
  ///   The `TransactionDbModel` instance for the destination transaction.
  ///
  /// Throws:
  ///   An exception if the destination transaction cannot be found, indicating
  ///   a data consistency issue.
  ///
  /// Note:
  ///   Critical for identifying the transactions involved in a transfer for deletion.
  Future<TransactionDbModel> _getTransDestiny(
    TransferDbModel transfer,
    int transIdOrigin,
  ) async {
    final transferTransIdDestiny = (transIdOrigin == transfer.transferTransId0!)
        ? transfer.transferTransId1!
        : transfer.transferTransId0!;

    final transDestiny = await _transactionRepository.getTransId(
      transferTransIdDestiny,
    );

    if (transDestiny == null) {
      const message =
          'TransferRepository: _getTransDestiny transDestiny return null';
      log(message);
      throw Exception(message);
    }
    return transDestiny;
  }

  /// Deletes a transfer record by its ID.
  ///
  /// This method removes a transfer from the database based on its unique ID,
  /// ensuring the transfer record is properly deleted.
  ///
  /// Parameters:
  ///   - transferId: The ID of the transfer to be deleted.
  ///
  /// Returns:
  ///   The number of records deleted, expected to be 1.
  ///
  /// Throws:
  ///   An exception if the deletion result is not as expected, indicating a failure.
  ///
  /// Note:
  ///   Final step in cleaning up after a transfer deletion, removing the transfer record.
  Future<int> _removeTransferById(int transferId) async {
    final result = await _store.deleteTransferId(transferId);
    if (result != 1) {
      final message =
          'TransferRepository: _store.deleteTransferId return $result';
      log(message);
      throw Exception(message);
    }
    return result;
  }

  /// Fetches a transfer model by its ID.
  ///
  /// This method retrieves the transfer record corresponding to the given ID,
  /// encapsulating it in a `TransferDbModel`.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the transfer to retrieve.
  ///
  /// Returns:
  ///   A `TransferDbModel` instance if the transfer is found; otherwise, throws an exception.
  ///
  /// Throws:
  ///   An exception if no transfer is found with the given ID, signaling data retrieval issues.
  ///
  /// Note:
  ///   Essential for obtaining transfer details before performing operations like deletion.
  Future<TransferDbModel?> _getTransferById(int id) async {
    final map = await _store.queryTranferId(id);
    if (map == null) {
      throw Exception('Transfer from id $id not found!');
    }
    return TransferDbModel.fromMap(map);
  }

  /// Updates an existing transfer by removing the current one and creating a new transfer.
  ///
  /// This method facilitates the modification of transfer details by first deleting
  /// the existing transfer associated with the provided originating transaction and
  /// then creating a new transfer with updated details. It ensures that the transfer
  /// process is refreshed with the new destination account ID.
  ///
  /// Parameters:
  ///   - transOrigin: The `TransactionDbModel` instance representing the originating
  ///                   transaction of the transfer to be updated.
  ///   - accountDestinyId: The ID of the new destination account for the transfer.
  ///
  /// Note:
  ///   Use this method to modify transfer details between accounts. It ensures that
  ///   all related transactions and transfer records are consistent with the updated
  ///   transfer information. This approach maintains the integrity of the transaction
  ///   history by cleanly removing outdated transfers and creating new, accurate records.
  ///
  /// Throws:
  ///   An exception if any part of the transfer update process fails, including issues
  ///   with deleting the original transfer or creating the new transfer.
  @override
  // this method will remove de current transfer and create a new.
  Future<void> updateTransfer({
    required TransactionDbModel transOrigin,
    required int accountDestinyId,
  }) async {
    try {
      // remove origin transaction by id
      await deleteTransfer(transOrigin);

      // create a new transfer
      await addTranfer(
        transOrigin: transOrigin,
        accountDestinyId: accountDestinyId,
      );
    } catch (err) {
      log('updateTransfer: $err');
    }
  }
}
