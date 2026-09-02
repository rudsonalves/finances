import '../common/models/transaction_db_model.dart';
import '../common/models/transfer_db_model.dart';
import '../locator.dart';
import '../repositories/financial_operation/abstract_financial_operation_repository.dart';
import '../repositories/transfer/abstract_transfer_repository.dart';

sealed class TransferManager {
  static final Set<int> _operationsInProgress = {};

  static AbstractTransferRepository get repository =>
      locator<AbstractTransferRepository>();
  static AbstractFinancialOperationRepository get operationRepository =>
      locator<AbstractFinancialOperationRepository>();

  TransferManager._();

  static Future<void> add({
    required TransactionDbModel transOrigin,
    required int accountDestinyId,
  }) async {
    _validateAccounts(transOrigin.transAccountId, accountDestinyId);
    if (transOrigin.transId != null || transOrigin.transTransferId != null) {
      throw StateError('The transfer transaction was already persisted');
    }

    await _runOnce(transOrigin, () async {
      await operationRepository.addTransfer(
        origin: transOrigin,
        destinationAccountId: accountDestinyId,
      );
    });
  }

  static Future<int> remove(TransactionDbModel transOrigin) async {
    final transferId = transOrigin.transTransferId;
    if (transferId == null) {
      throw ArgumentError('The transaction is not associated with a transfer');
    }
    return operationRepository.removeTransfer(transferId: transferId);
  }

  static Future<void> update({
    required TransactionDbModel newTransaction,
    required int accountDestinyId,
  }) async {
    _validateAccounts(newTransaction.transAccountId, accountDestinyId);
    await _runOnce(newTransaction, () async {
      await operationRepository.updateTransfer(
        transaction: newTransaction,
        destinationAccountId: accountDestinyId,
      );
    });
  }

  static Future<TransferDbModel?> getId(int id) {
    return repository.getId(id);
  }

  static void _validateAccounts(int originId, int destinationId) {
    if (originId == destinationId) {
      throw ArgumentError.value(
        destinationId,
        'accountDestinyId',
        'Origin and destination accounts must be different',
      );
    }
  }

  static Future<T> _runOnce<T>(
    TransactionDbModel transaction,
    Future<T> Function() operation,
  ) async {
    final operationKey = identityHashCode(transaction);
    if (!_operationsInProgress.add(operationKey)) {
      throw StateError('This financial operation is already in progress');
    }
    try {
      return await operation();
    } finally {
      _operationsInProgress.remove(operationKey);
    }
  }
}
