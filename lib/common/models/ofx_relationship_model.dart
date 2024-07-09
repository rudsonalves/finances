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

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class OfxRelationshipModel {
  int? id;
  String bankAccountId;
  int? accountId;
  String? bankName;

  OfxRelationshipModel({
    this.id,
    required this.bankAccountId,
    this.accountId,
    this.bankName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'bankAccountId': bankAccountId,
      'accountId': accountId,
      'bankName': bankName,
    };
  }

  factory OfxRelationshipModel.fromMap(Map<String, dynamic> map) {
    return OfxRelationshipModel(
      id: map['id'] as int?,
      bankAccountId: map['bankAccountId'] as String,
      accountId: map['accountId'] as int,
      bankName: map['bankName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxRelationshipModel.fromJson(String source) =>
      OfxRelationshipModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OfxRelationshipModel(id: $id,'
      ' bankAccountId: $bankAccountId,'
      ' accountId: $accountId)'
      ' bankName: $bankName';
}
