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
