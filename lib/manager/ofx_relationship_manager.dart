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
