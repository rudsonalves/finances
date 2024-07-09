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

class StatisticResult {
  String categoryName;
  double monthSum;
  double? variation;

  StatisticResult({
    this.categoryName = '',
    this.monthSum = 0.0,
    this.variation,
  });

  @override
  String toString() =>
      'StatisticResult(categoryName: $categoryName, totalSum: $monthSum)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryName': categoryName,
      'totalSum': monthSum,
    };
  }

  factory StatisticResult.fromMap(Map<String, dynamic> map) {
    return StatisticResult(
      categoryName: map['categoryName'] as String,
      monthSum: map['totalSum'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatisticResult.fromJson(String source) =>
      StatisticResult.fromMap(json.decode(source) as Map<String, dynamic>);
}
