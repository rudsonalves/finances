// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import '../../common/models/transfer_db_model.dart';
import '../../store/stores/transfer_store.dart';
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
  Future<int> deleteId(int transferId) async {
    final result = await _store.deleteTransferId(transferId);

    if (result != 1) {
      log('TransferRepository.deleteTransfer: return id $result');
    }

    return result;
  }

  @override
  Future<TransferDbModel?> getId(int id) async {
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
  Future<int> setNullId(int transferId) async {
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
