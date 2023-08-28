import '../../common/models/transfer_db_model.dart';

abstract class TransferRepository {
  Future<void> addTranfer(TransferDbModel transfer);
  Future<int> deleteTransfer(TransferDbModel transfer);
  Future<TransferDbModel?> getTransferId(int id);
  Future<int> updateTransfer(TransferDbModel transfer);
}
