import '../../common/models/transfer_db_model.dart';
import '../../locator.dart';
import '../../services/database/database_helper.dart';
import 'transfer_repository.dart';

class SqfliteTransferRepository implements TransferRepository {
  final helper = locator<DatabaseHelper>();

  @override
  Future<void> addTranfer(TransferDbModel transfer) async {
    int id = await helper.insertTransfer(transfer.toMap());
    transfer.transferId = id;
  }

  @override
  Future<int> deleteTransfer(TransferDbModel transfer) async {
    return await helper.deleteTransferId(transfer.transferId!);
  }

  @override
  Future<TransferDbModel?> getTransferId(int id) async {
    final map = await helper.queryTranferId(id);
    if (map == null) {
      throw Exception('Transfer from id $id not found!');
    }
    return TransferDbModel.fromMap(map);
  }

  @override
  Future<int> updateTransfer(TransferDbModel transfer) async {
    return await helper.updateTransfer(transfer.toMap());
  }
}
