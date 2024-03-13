import 'dart:developer';

import 'package:finances/common/models/extends_date.dart';

import '../../common/models/ofx_account_model.dart';
import '../../store/ofx_account_store.dart';
import 'abstract_ofx_account_repository.dart';

class OfxAccountRepository implements AbstractOfxAccountRepository {
  final _store = OfxAccountStore();

  @override
  Future<int> insert(OfxAccountModel ofxAccount) async {
    final id = await _store.insert(ofxAccount.toMap());

    if (id < 0) {
      log('OfxAccountRepository.insert: return id $id');
      return id;
    }
    ofxAccount.id = id;
    return id;
  }

  @override
  Future<OfxAccountModel?> queryBankIdStartDate(
      String bankId, ExtendedDate date) async {
    final ofxMap = await _store.queryBankIdStartDate(
      bankId,
      date.millisecondsSinceEpoch,
    );

    if (ofxMap == null) return null;

    final ofxAccount = OfxAccountModel.fromMap(ofxMap);
    return ofxAccount;
  }

  @override
  Future<int> update(OfxAccountModel ofxAccount) async {
    final result = await _store.update(ofxAccount.toMap());
    if (result != 1) {
      log('OfxAccountRepository.update: return id $result');
    }
    return result;
  }

  @override
  Future<int> deleteId(int id) async {
    final result = await _store.deleteId(id);
    if (result != 1) {
      log('OfxAccountRepository.deleteId: return id $result');
    }
    return result;
  }
}
