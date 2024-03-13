import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class OfxRelationshipModel {
  int? id;
  String bankId;
  int accountId;

  OfxRelationshipModel({
    this.id,
    required this.bankId,
    required this.accountId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'bankId': bankId,
      'accountId': accountId,
    };
  }

  factory OfxRelationshipModel.fromMap(Map<String, dynamic> map) {
    return OfxRelationshipModel(
      id: map['id'] as int?,
      bankId: map['bankId'] as String,
      accountId: map['accountId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxRelationshipModel.fromJson(String source) =>
      OfxRelationshipModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
