import 'dart:developer';

import 'package:finances/common/models/ofx_relationship_model.dart';

import '../../store/ofx_relationship_store.dart';
import 'abstract_ofx_ralationship_repository.dart';

class OfxRelationshipRepository implements AbtractOfxRelationshipRepository {
  final _store = OfxRalationshipStore();

  @override
  Future<int> insert(OfxRelationshipModel ofxRelationship) async {
    final id = await _store.insert(ofxRelationship.toMap());

    if (id < 0) {
      log('OfxRelationshipRepository.insert: return id $id');
    }
    ofxRelationship.id = id;
    return id;
  }

  @override
  Future<int> update(OfxRelationshipModel ofxRelationship) async {
    final result = await _store.update(ofxRelationship.toMap());

    if (result != 1) {
      log('OfxRelationshipRepository.update: return id $result');
    }

    return result;
  }

  @override
  Future<OfxRelationshipModel?> queryBankId(String bankId) async {
    final ofxMap = await _store.queryBankId(bankId);

    if (ofxMap == null) return null;

    final ofxRalationship = OfxRelationshipModel.fromMap(ofxMap);
    return ofxRalationship;
  }

  @override
  Future<int> deleteId(int id) async {
    final result = await _store.deleteId(id);
    if (result != 1) {
      log('OfxRelationshipRepository.deleteId: return id $result');
    }
    return result;
  }
}
