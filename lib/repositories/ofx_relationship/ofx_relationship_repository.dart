import 'dart:developer';

import '../../common/models/ofx_relationship_model.dart';
import '../../store/stores/ofx_relationship_store.dart';
import 'abstract_ofx_relationship_repository.dart';

class OfxRelationshipRepository implements AbtractOfxRelationshipRepository {
  final _store = OfxRalationshipStore();

  @override
  Future<int> insert(OfxRelationshipModel ofxRelationship) async {
    try {
      final id = await _store.insert(ofxRelationship.toMap());

      if (id < 0) {
        throw Exception('return id $id');
      }
      ofxRelationship.id = id;
      return id;
    } catch (err) {
      final message = 'OfxRelationshipRepository.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> update(OfxRelationshipModel ofxRelationship) async {
    try {
      final result = await _store.update(ofxRelationship.toMap());

      if (result != 1) {
        log('OfxRelationshipRepository.update: return id $result');
      }

      return result;
    } catch (err) {
      final message = 'OfxRelationshipRepository.update: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<OfxRelationshipModel?> queryBankAccountId(String bankAccountId) async {
    try {
      final ofxMap = await _store.queryBanckAccountId(bankAccountId);

      if (ofxMap == null) return null;

      final ofxRalationship = OfxRelationshipModel.fromMap(ofxMap);
      return ofxRalationship;
    } catch (err) {
      final message = 'OfxRelationshipRepository.queryAccountId: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> deleteId(int id) async {
    try {
      final result = await _store.deleteId(id);
      if (result != 1) {
        log('OfxRelationshipRepository.deleteId: return id $result');
      }
      return result;
    } catch (err) {
      final message = 'OfxRelationshipRepository.deleteId: $err';
      log(message);
      throw Exception(message);
    }
  }
}
