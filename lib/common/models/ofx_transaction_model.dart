import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class OfxTransactionModel {
  int? id;
  String memo;
  int accountId;
  int cadegoryId;
  String? description;
  int? transferAccountId;

  OfxTransactionModel({
    this.id,
    required this.memo,
    required this.accountId,
    required this.cadegoryId,
    this.description,
    this.transferAccountId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'memo': memo,
      'accountId': accountId,
      'cadegoryId': cadegoryId,
      'description': description,
      'transferAccountId': transferAccountId,
    };
  }

  factory OfxTransactionModel.fromMap(Map<String, dynamic> map) {
    return OfxTransactionModel(
      id: map['id'] as int?,
      memo: map['memo'] as String,
      accountId: map['accountId'] as int,
      cadegoryId: map['cadegoryId'] as int,
      description: map['description'] as String?,
      transferAccountId: map['transferAccountId'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxTransactionModel.fromJson(String source) =>
      OfxTransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
