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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:finances/common/models/extends_date.dart';
import 'package:finances/packages/ofx/lib/ofx.dart';

class OfxAccountModel {
  int? id;
  int? accountId;
  String bankAccountId;
  String? bankName;
  String accountType;
  int nTrans;
  ExtendedDate startDate;
  ExtendedDate endDate;

  OfxAccountModel({
    this.id,
    this.accountId,
    required this.bankAccountId,
    this.bankName,
    required this.accountType,
    required this.nTrans,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'accountId': accountId,
      'bankAccountId': bankAccountId,
      'bankName': bankName,
      'accountType': accountType,
      'nTrans': nTrans,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
    };
  }

  void copy(OfxAccountModel ofxAccount) {
    id = ofxAccount.id;
    accountId = ofxAccount.accountId;
    bankAccountId = ofxAccount.bankAccountId;
    bankName = ofxAccount.bankName;
    accountType = ofxAccount.accountType;
    nTrans = ofxAccount.nTrans;
    startDate = ofxAccount.startDate;
    endDate = ofxAccount.endDate;
  }

  factory OfxAccountModel.fromOfx(Ofx ofx, [int? accountId]) {
    return OfxAccountModel(
      accountId: accountId,
      bankAccountId: ofx.accountID,
      bankName: ofx.financialInstitution.organization,
      accountType: ofx.accountType,
      nTrans: ofx.transactions.length,
      startDate: ExtendedDate.fromDateTime(ofx.start),
      endDate: ExtendedDate.fromDateTime(ofx.end),
    );
  }

  factory OfxAccountModel.fromMap(Map<String, dynamic> map) {
    return OfxAccountModel(
      id: map['id'] as int?,
      accountId: map['accountId'] as int,
      bankAccountId: map['bankAccountId'] as String,
      bankName: map['bankName'] as String?,
      accountType: map['accountType'] as String,
      nTrans: map['nTrans'] as int,
      startDate:
          ExtendedDate.fromMillisecondsSinceEpoch(map['startDate'] as int),
      endDate: ExtendedDate.fromMillisecondsSinceEpoch(map['endDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxAccountModel.fromJson(String source) =>
      OfxAccountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OfxAccountModel(id: $id,'
        ' accountId: $accountId,'
        ' bankAccountId: $bankAccountId,'
        ' bankName: $bankName,'
        ' accountType: $accountType,'
        ' nTrans: $nTrans,'
        ' startDate: $startDate,'
        ' endDate: $endDate)';
  }
}
