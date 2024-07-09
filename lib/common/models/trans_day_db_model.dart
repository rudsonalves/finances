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

class TransDayDbModel {
  int? transDayBalanceId;
  int? transDayTransId;

  TransDayDbModel({
    this.transDayBalanceId,
    this.transDayTransId,
  });

  @override
  String toString() => 'TransDay('
      ' balanceId: $transDayBalanceId;'
      ' TransId: $transDayTransId'
      ')';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transDayBalanceId': transDayBalanceId,
      'transDayTransId': transDayTransId,
    };
  }

  factory TransDayDbModel.fromMap(Map<String, dynamic> map) {
    return TransDayDbModel(
      transDayBalanceId: map['transDayBalanceId'] != null
          ? map['transDayBalanceId'] as int
          : null,
      transDayTransId:
          map['transDayTransId'] != null ? map['transDayTransId'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransDayDbModel.fromJson(String source) =>
      TransDayDbModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
