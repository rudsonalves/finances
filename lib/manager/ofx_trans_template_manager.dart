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
