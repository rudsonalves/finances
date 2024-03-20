import 'dart:developer';

import '../common/models/ofx_trans_template_model.dart';
import '../repositories/ofx_trans_template/ofx_trans_template_repository.dart';

sealed class OfxTransTemplateManager {
  static final repository = OfxTransTemplateRepository();
  OfxTransTemplateManager._();

  static Future<OfxTransTemplateModel?> getByMemo({
    required String memo,
    required int accountId,
  }) async {
    try {
      final ofxTransaction = await repository.queryMemo(memo, accountId);
      return ofxTransaction;
    } catch (err) {
      log('OfxTransactionManager.getByMemo: $err');
      return null;
    }
  }

  static Future<void> add(OfxTransTemplateModel ofxTransTemplate) async {
    try {
      final result = await repository.insert(ofxTransTemplate);
      ofxTransTemplate.id = result!.id;
    } catch (err) {
      log('OfxTransactionManager.add: $err');
      return;
    }
  }

  static Future<void> update(OfxTransTemplateModel ofxTransTemplate) async {
    try {
      final result = await repository.update(ofxTransTemplate);
      if (result != 1) {
        throw Exception('repository.update return $result');
      }
    } catch (err) {
      log('OfxTransactionManager.update: $err');
      return;
    }
  }
}
