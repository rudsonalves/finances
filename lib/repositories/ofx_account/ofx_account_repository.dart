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

import 'package:finances/common/models/extends_date.dart';

import '../../common/models/ofx_account_model.dart';
import '../../store/stores/ofx_account_store.dart';
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
  Future<OfxAccountModel?> queryBankAccountIdStartDate(
      String bankAccountId, ExtendedDate date) async {
    final ofxMap = await _store.queryBankAccountIdStartDate(
      bankAccountId,
      date.millisecondsSinceEpoch,
    );

    if (ofxMap == null) return null;

    final ofxAccount = OfxAccountModel.fromMap(ofxMap);
    return ofxAccount;
  }

  @override
  Future<List<OfxAccountModel>> queryAll(int? limit) async {
    final ofxMapList = await _store.queryAll(limit);

    List<OfxAccountModel> ofxAccounts = [];
    for (final map in ofxMapList) {
      if (map != null) {
        final ofxAccount = OfxAccountModel.fromMap(map);
        ofxAccounts.add(ofxAccount);
      }
    }

    return ofxAccounts;
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
