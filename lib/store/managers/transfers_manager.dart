import '../../common/current_models/current_account.dart';
import '../../common/models/account_db_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../common/models/transfer_db_model.dart';
import '../../locator.dart';
import '../../repositories/account/account_repository.dart';
import '../../repositories/transaction/transaction_repository.dart';
import '../../repositories/transfer_repository/transfer_repository.dart';
import 'transactions_manager.dart';

class TransfersManager {
  TransfersManager._();

  /// This function facilitates the transfer of values between two accounts.
  ///
  /// This method takes a transaction [transaction0] to be executed in the
  /// source account [account0] and uses it to create a value transfer to the
  /// destination account [account1].
  ///
  /// Initially, it creates a transaction [transaction1] by copying
  /// [transaction0], with the value inverted. Subsequently, it records these
  /// source [transaction0] and destination [transaction1] transactions in
  /// their respective accounts in the database.
  ///
  /// Following this, a transfer [transfer] is constructed with relevant
  /// information to document the transfer in the database. The transfer is
  /// then recorded, and finally, the transactions are updated to store the
  /// transfer's ID.
  ///
  /// Example of usage:
  /// ```
  /// await TransfersManager.addTransfer(
  ///   transaction0: referenceTransaction,
  ///   account1: account1,
  /// );
  /// ```
  static Future<void> addTransfer({
    required TransactionDbModel transaction0,
    AccountDbModel? account0,
    required AccountDbModel account1,
  }) async {
    account0 ??= locator<CurrentAccount>();
    final transaction1 = transaction0.copyToTransfer();

    await TransactionsManager.addTransaction(
      transaction: transaction0,
      account: account0,
    );
    await TransactionsManager.addTransaction(
      transaction: transaction1,
      account: account1,
    );

    final transfer = TransferDbModel(
      transferTransId0: transaction0.transId!,
      transferTransId1: transaction1.transId!,
      transferAccount0: account0.accountId!,
      transferAccount1: account1.accountId!,
    );

    await locator<TransferRepository>().addTranfer(transfer);

    transaction0.transTransferId = transfer.transferId;
    transaction1.transTransferId = transfer.transferId;
    await transaction0.updateTransaction();
    await transaction1.updateTransaction();
  }

  /// This method removes a Transfer and its associated transactions from the
  /// system.
  ///
  /// This function removes a transfer conducted through a transaction
  /// [transaction0] in the database. The transfer is identified using the
  /// transTransferId attribute of the provided transaction [transaction0], and
  /// it is retrieved from the database as "transfer."
  ///
  /// Subsequently, the second transaction is retrieved using transferTransId1
  /// from the data in the "transfer" record. Finally, the transfer is removed,
  /// first by deleting the "transfer" record and then by removing the
  /// transactions [transaction0] and [transaction1].
  ///
  /// Example usage:
  /// ```dart
  /// await removeTransfer(transactionToRemove);
  /// ```
  static Future<void> removeTransfer(TransactionDbModel transaction0) async {
    final transRepository = locator<TransactionRepository>();
    final transferRepository = locator<TransferRepository>();

    final transfer = await transferRepository.getTransferId(
      transaction0.transTransferId!,
    );
    if (transfer == null) {
      throw Exception('Transfer not fount in TransfersManager.removeTransfer');
    }

    int transferTransId1 = transfer.transferTransId0 == transaction0.transId!
        ? transfer.transferTransId1
        : transfer.transferTransId0;
    final transaction1 =
        await transRepository.getTransactionId(transferTransId1);
    if (transaction1 == null) {
      throw Exception(
          'transaction1 not fount in TransfersManager.removeTransfer');
    }

    await transferRepository.deleteTransfer(transfer);

    await TransactionsManager.removeTransaction(transaction0);
    await TransactionsManager.removeTransaction(transaction1);
  }

  /// updateTransfer
  ///    Description:
  ///    Updates a transfer and its related transactions.
  ///
  ///    Signature:
  ///    static Future<void> updateTransfer({
  ///        required TransactionDbModel transaction0,
  ///        AccountDbModel? account1,
  ///    })
  ///
  ///    Parameters:
  ///    - `transaction0`: The edited transaction that is part of the transfer.
  ///    - `account1`: (Optional) The destination account for the updated
  ///       transfer.
  ///
  ///    Description:
  ///    This method updates a transfer by removing the current transfer
  /// associated with the provided `transaction0` and adding a new transfer
  /// based on the updated `transaction0` and the provided `account1`.
  ///
  ///    The process involves:
  ///    - Recovering the original `transaction0` from the database.
  ///    - Checking and recovering the `account1` if not provided.
  ///    - Removing the current transfer associated with the original
  ///      `transaction0`.
  ///    - Resetting the `transaction0` fields for adding a new transfer.
  ///    - Adding a new transfer with the updated `transaction0` and the
  ///      provided `account1`.
  ///
  ///    Note:
  ///    It is recommended to thoroughly test this method with various
  /// scenarios before deploying it in a production environment.
  ///
  /// Usage Example:
  /// ```dart
  /// await TransfersManager.updateTransfer(
  ///   transaction0: updatedTransaction,
  ///   account1: destinationAccount,
  /// );
  static Future<void> updateTransfer({
    required TransactionDbModel transaction0,
    AccountDbModel? account0,
    AccountDbModel? account1,
  }) async {
    final transferRepository = locator<TransferRepository>();
    final transactionRepository = locator<TransactionRepository>();
    final accountRepository = locator<AccountRepository>();

    account0 ??= locator<CurrentAccount>();

    // recover the original transaction
    final originalTransaction0 =
        await transactionRepository.getTransactionId(transaction0.transId!);
    if (originalTransaction0 == null) {
      throw Exception('updateTransfer: Original transaction not found');
    }

    // account1 must be recognized before removing the current transfer
    if (account1 == null) {
      // get account1 from current transfer
      int? transferId = originalTransaction0.transTransferId;
      if (transferId == null) {
        throw Exception(
          'updateTransfer: Original transaction don\'t have transTransferId',
        );
      }

      // recover current transfer
      final transfer = await transferRepository.getTransferId(transferId);
      if (transfer == null) {
        throw Exception(
          'updateTransfer: transferId ($transferId) not found',
        );
      }

      // recover account1 from transfer.transferAccount? (not currentAccount)
      int accountId1 = transfer.transferAccount0 == account0.accountId!
          ? transfer.transferAccount1
          : transfer.transferAccount0;
      account1 = accountRepository.accountsMap[accountId1];
      if (account1 == null) {
        throw Exception(
          'updateTransfer: account1 ($accountId1) not found',
        );
      }
    }
    // remove current transfer
    await removeTransfer(originalTransaction0);

    // Reset transaction0
    transaction0.transId = null;
    transaction0.transTransferId = null;
    // add a new transfer with transaction0 and account1
    await addTransfer(
      transaction0: transaction0,
      account0: account0,
      account1: account1,
    );
  }
}
