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

import 'package:finances/packages/ofx/lib/ofx.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class OfxTransTemplateModel {
  int? id;
  String memo;
  int accountId;
  int categoryId;
  String? description;
  int? transferAccountId;

  OfxTransTemplateModel({
    this.id,
    required this.memo,
    required this.accountId,
    required this.categoryId,
    this.description,
    this.transferAccountId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'memo': memo,
      'accountId': accountId,
      'categoryId': categoryId,
      'description': description,
      'transferAccountId': transferAccountId,
    };
  }

  factory OfxTransTemplateModel.fromOfxTransaction({
    required OfxTransaction ofxTransaction,
    required int accountId,
  }) {
    return OfxTransTemplateModel(
      memo: ofxTransaction.memo,
      accountId: accountId,
      categoryId: -1,
      description: ofxTransaction.memo,
    );
  }

  factory OfxTransTemplateModel.fromMap(Map<String, dynamic> map) {
    return OfxTransTemplateModel(
      id: map['id'] as int?,
      memo: map['memo'] as String,
      accountId: map['accountId'] as int,
      categoryId: map['categoryId'] as int,
      description: map['description'] as String?,
      transferAccountId: map['transferAccountId'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxTransTemplateModel.fromJson(String source) =>
      OfxTransTemplateModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OfxTransTemplateModel(id: $id,'
        ' memo: $memo,'
        ' accountId: $accountId,'
        ' categoryId: $categoryId,'
        ' description: $description,'
        ' transferAccountId: $transferAccountId)';
  }

  factory OfxTransTemplateModel.copyTemplate(
      OfxTransTemplateModel ofxTransTemplate) {
    return OfxTransTemplateModel(
      id: ofxTransTemplate.id,
      memo: ofxTransTemplate.memo,
      accountId: ofxTransTemplate.accountId,
      categoryId: ofxTransTemplate.categoryId,
      description: ofxTransTemplate.description,
      transferAccountId: ofxTransTemplate.transferAccountId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OfxTransTemplateModel &&
        id == other.id &&
        memo == other.memo &&
        accountId == other.accountId &&
        categoryId == other.categoryId &&
        description == other.description &&
        transferAccountId == other.transferAccountId;
  }

  @override
  int get hashCode => Object.hash(
      id, memo, accountId, categoryId, description, transferAccountId);
}
