import '../../common/models/transaction_db_model.dart';

class TransferOperationResult {
  const TransferOperationResult({
    required this.transferId,
    required this.originTransactionId,
    required this.destinationTransactionId,
  });

  final int transferId;
  final int originTransactionId;
  final int destinationTransactionId;
}

abstract interface class AbstractFinancialOperationRepository {
  Future<TransferOperationResult> addTransfer({
    required TransactionDbModel origin,
    required int destinationAccountId,
  });

  Future<int> removeTransfer({required int transferId});

  Future<TransferOperationResult> updateTransfer({
    required TransactionDbModel transaction,
    required int destinationAccountId,
  });

  Future<int> updateTransaction(TransactionDbModel transaction);
}
