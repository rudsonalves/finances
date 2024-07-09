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

import 'dart:convert';

class OfxStatus {
  final int code;
  final String severity;

  OfxStatus({
    required this.code,
    required this.severity,
  });

  OfxStatus copyWith({
    int? code,
    String? severity,
  }) {
    return OfxStatus(
      code: code ?? this.code,
      severity: severity ?? this.severity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'severity': severity,
    };
  }

  factory OfxStatus.fromMapOfx(Map<String, dynamic> map) {
    return OfxStatus(
      code: int.parse(map['CODE']),
      severity: map['SEVERITY'].toString(),
    );
  }

  factory OfxStatus.fromMap(Map<String, dynamic> map) {
    return OfxStatus(
      code: map['code'] ?? 0,
      severity: map['severity'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxStatus.fromJson(String source) =>
      OfxStatus.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Status('
      ' code: $code,'
      ' severity: $severity'
      ')';
}
