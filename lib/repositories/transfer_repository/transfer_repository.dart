import '../../common/models/transfer_db_model.dart';
import '../../store/transfer_store.dart';
import 'abstract_transfer_repository.dart';

class TransferRepository implements AbstractTransferRepository {
  final _store = TransferStore();

  @override
  Future<void> addTranfer(TransferDbModel transfer) async {
    int id = await _store.insertTransfer(transfer.toMap());
    transfer.transferId = id;
  }

  @override
  Future<int> deleteTransfer(TransferDbModel transfer) async {
    return await _store.deleteTransferId(transfer.transferId!);
  }

  @override
  Future<TransferDbModel?> getTransferId(int id) async {
    final map = await _store.queryTranferId(id);
    if (map == null) {
      throw Exception('Transfer from id $id not found!');
    }
    return TransferDbModel.fromMap(map);
  }

  @override
  Future<int> updateTransfer(TransferDbModel transfer) async {
    return await _store.updateTransfer(transfer.toMap());
  }
}
