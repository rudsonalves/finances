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

class TransferDbModel {
  int? transferId;
  int? transferTransId0;
  int? transferTransId1;
  int? transferAccount0;
  int? transferAccount1;

  TransferDbModel({
    this.transferId,
    this.transferTransId0,
    this.transferTransId1,
    this.transferAccount0,
    this.transferAccount1,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transferId': transferId,
      'transferTransId0': transferTransId0,
      'transferTransId1': transferTransId1,
      'transferAccount0': transferAccount0,
      'transferAccount1': transferAccount1,
    };
  }

  factory TransferDbModel.fromMap(Map<String, dynamic> map) {
    return TransferDbModel(
      transferId: map['transferId'] != null ? map['transferId'] as int : null,
      transferTransId0: map['transferTransId0'] as int,
      transferTransId1: map['transferTransId1'] as int,
      transferAccount0: map['transferAccount0'] as int,
      transferAccount1: map['transferAccount1'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransferDbModel.fromJson(String source) =>
      TransferDbModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Transfer('
        'transferId: $transferId;'
        ' transferTransId0: $transferTransId0;'
        ' transferTransId1: $transferTransId1;'
        ' transferAccount0: $transferAccount0;'
        ' transferAccount1: $transferAccount1'
        ')';
  }
}
