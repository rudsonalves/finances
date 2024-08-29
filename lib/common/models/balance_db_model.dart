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

import './extends_date.dart';

class BalanceDbModel {
  int? balanceId;
  int? balanceAccountId;
  ExtendedDate? balanceDate;
  int balanceTransCount;
  double balanceOpen;
  double balanceClose;

  BalanceDbModel({
    this.balanceId,
    this.balanceAccountId,
    this.balanceDate,
    this.balanceTransCount = 0,
    this.balanceOpen = 0.0,
    this.balanceClose = 0.0,
  });

  @override
  String toString() {
    return 'Balance('
        ' Id: $balanceId;'
        ' AccountId: $balanceAccountId;'
        ' Date: $balanceDate;'
        ' Count: $balanceTransCount;'
        ' Open: $balanceOpen;'
        ' Close: $balanceClose'
        ')';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'balanceId': balanceId,
      'balanceAccountId': balanceAccountId,
      'balanceDate': balanceDate!.millisecondsSinceEpoch,
      'balanceTransCount': balanceTransCount,
      'balanceOpen': balanceOpen,
      'balanceClose': balanceClose,
    };
  }

  factory BalanceDbModel.fromMap(Map<String, dynamic> map) {
    return BalanceDbModel(
      balanceId: map['balanceId'] as int?,
      balanceAccountId: map['balanceAccountId'] as int,
      balanceDate:
          ExtendedDate.fromMillisecondsSinceEpoch(map['balanceDate'] as int),
      balanceTransCount: map['balanceTransCount'] as int,
      balanceOpen: map['balanceOpen'] as double,
      balanceClose: map['balanceClose'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory BalanceDbModel.fromJson(String source) =>
      BalanceDbModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
