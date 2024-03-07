import 'dart:developer';

import '../../common/models/transfer_db_model.dart';
import '../../store/transfer_store.dart';
import 'abstract_transfer_repository.dart';

class TransferRepository implements AbstractTransferRepository {
  final _store = TransferStore();

  @override
  Future<int> insertTransfer(TransferDbModel transfer) async {
    final id = await _store.insertTransfer(transfer.toMap());

    if (id <= 0) {
      log('TransferRepository.insertTranfer: return id $id');
      return id;
    }
    transfer.transferId = id;
    return id;
  }

  @override
  Future<int> deleteTransfer(int transferId) async {
    final result = await _store.deleteTransferId(transferId);

    if (result != 1) {
      log('TransferRepository.deleteTransfer: return id $result');
    }

    return result;
  }

  @override
  Future<TransferDbModel?> getTransferById(int id) async {
    final map = await _store.queryTranferId(id);
    if (map == null) {
      log('Transfer from id $id not found!');
      return null;
    }
    return TransferDbModel.fromMap(map);
  }

  @override
  Future<int> updateTransfer(TransferDbModel transfer) async {
    final result = await _store.updateTransfer(transfer.toMap());

    return result;
  }

  @override
  Future<int> setNullTransferId(int transferId) async {
    try {
      final result = await _store.setNullTransferId(transferId);
      return result;
    } catch (err) {
      final message = 'TransactionRepository.updateTransStatus: $err';
      log(message);
      throw Exception(message);
    }
  }
}
