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

import '../../common/models/ofx_trans_template_model.dart';
import '../../store/stores/ofx_trans_template_store.dart';
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
