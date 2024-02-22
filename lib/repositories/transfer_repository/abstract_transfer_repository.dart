import '../../common/models/transaction_db_model.dart';

abstract class AbstractTransferRepository {
  Future<void> addTranfer({
    required TransactionDbModel transOrigin,
    required int accountDestinyId,
  });
  Future<int> deleteTransfer(TransactionDbModel transOrigin);
  Future<void> updateTransfer({
    required TransactionDbModel transOrigin,
    required int accountDestinyId,
  });
}
