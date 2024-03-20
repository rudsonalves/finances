import 'dart:developer';

import 'package:finances/common/models/ofx_relationship_model.dart';

import '../repositories/ofx_relationship/ofx_relationship_repository.dart';

sealed class OfxRelationshipManager {
  static final repository = OfxRelationshipRepository();

  OfxRelationshipManager._();

  static Future<void> add(OfxRelationshipModel ofxRelation) async {
    try {
      final result = await repository.insert(ofxRelation);

      if (result < 1) {
        throw Exception('repository.insert return $result');
      }
    } catch (err) {
      final message = 'OfxRelationshipManager.addOfxRelationship $err';
      log(message);
      throw Exception(message);
    }
  }

  static Future<OfxRelationshipModel?> getByBankAccountId(
      String bankAccountId) async {
    final findOfxRelationship =
        await repository.queryBankAccountId(bankAccountId);

    return findOfxRelationship;
  }

  static Future<int> update(OfxRelationshipModel ofxRelationship) async {
    final result = await repository.update(ofxRelationship);
    return result;
  }
}
