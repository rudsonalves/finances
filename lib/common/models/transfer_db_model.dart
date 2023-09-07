import 'dart:convert';

class TransferDbModel {
  int? transferId;
  int transferTransId0;
  int transferTransId1;
  int transferAccount0;
  int transferAccount1;

  TransferDbModel({
    this.transferId,
    required this.transferTransId0,
    required this.transferTransId1,
    required this.transferAccount0,
    required this.transferAccount1,
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
        ' transferAccount1: $transferAccount1;'
        ')';
  }
}
