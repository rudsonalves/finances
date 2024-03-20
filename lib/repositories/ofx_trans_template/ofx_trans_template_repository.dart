import 'dart:developer';

import '../../common/models/ofx_trans_template_model.dart';
import '../../store/ofx_trans_template.dart';
import 'abstract_ofx_trans_template_repository.dart';

class OfxTransTemplateRepository implements AbstractOfxTransTemplateRepository {
  final _store = OfxTransTemplateStore();

  @override
  Future<OfxTransTemplateModel?> insert(
      OfxTransTemplateModel ofxTransTemplate) async {
    final id = await _store.insert(ofxTransTemplate.toMap());

    if (id < 0) {
      throw Exception('OfxTransactionRepository.insert: return id $id');
    }
    ofxTransTemplate.id = id;
    return ofxTransTemplate;
  }

  @override
  Future<OfxTransTemplateModel?> queryMemo(String memo, int accountId) async {
    final ofxMap = await _store.queryMemo(memo, accountId);

    if (ofxMap == null) return null;

    final ofxTransaction = OfxTransTemplateModel.fromMap(ofxMap);
    return ofxTransaction;
  }

  @override
  Future<int> update(OfxTransTemplateModel ofxTransTemplate) async {
    final result = await _store.update(ofxTransTemplate.toMap());

    if (result != 1) {
      log('OfxTransactionRepository.update: return id $result');
    }
    return result;
  }

  @override
  Future<int> deleteId(int id) async {
    final result = await _store.deleteId(id);

    if (result != 1) {
      log('OfxTransactionRepository.deleteId: return id $result');
    }
    return result;
  }
}
