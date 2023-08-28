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
