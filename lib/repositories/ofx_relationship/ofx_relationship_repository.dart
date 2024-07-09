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
