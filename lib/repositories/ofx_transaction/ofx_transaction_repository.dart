import 'dart:developer';

import '../../common/models/ofx_transaction_model.dart';
import '../../store/ofx_transactions.dart';
import 'abstract_ofx_transaction_repository.dart';

class OfxTransactionRepository implements AbstractOfxTransactionRepository {
  final _store = OfxTransactionStore();

  @override
  Future<OfxTransactionModel?> insertOfxTransaction(
      OfxTransactionModel ofxTransaction) async {
    final id = await _store.insert(ofxTransaction.toMap());

    if (id < 0) {
      log('OfxTransactionRepository.insertOfxTransaction: return id $id');
      return null;
    }
    ofxTransaction.id = id;
    return ofxTransaction;
  }

  @override
  Future<OfxTransactionModel?> queryOfxTransMemo(
      String memo, int accountId) async {
    final ofxMap = await _store.queryMemo(memo, accountId);

    if (ofxMap == null) return null;

    final ofxTransaction = OfxTransactionModel.fromMap(ofxMap);
    return ofxTransaction;
  }

  @override
  Future<int> updateOfxTransaction(OfxTransactionModel ofxTransaction) async {
    final result = await _store.update(ofxTransaction.toMap());

    if (result != 1) {
      log('OfxTransactionRepository.updateOfxTransaction: return id $result');
    }
    return result;
  }

  @override
  Future<int> deleteOfxTransactionId(int id) async {
    final result = await _store.deleteId(id);

    if (result != 1) {
      log('OfxTransactionRepository.deleteOfxTransactionId: return id $result');
    }
    return result;
  }
}
