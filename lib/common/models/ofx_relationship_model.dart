import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class OfxRelationshipModel {
  int? id;
  String bankAccountId;
  int? accountId;
  String? bankName;

  OfxRelationshipModel({
    this.id,
    required this.bankAccountId,
    this.accountId,
    this.bankName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'bankAccountId': bankAccountId,
      'accountId': accountId,
      'bankName': bankName,
    };
  }

  factory OfxRelationshipModel.fromMap(Map<String, dynamic> map) {
    return OfxRelationshipModel(
      id: map['id'] as int?,
      bankAccountId: map['bankAccountId'] as String,
      accountId: map['accountId'] as int,
      bankName: map['bankName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxRelationshipModel.fromJson(String source) =>
      OfxRelationshipModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OfxRelationshipModel(id: $id,'
      ' bankAccountId: $bankAccountId,'
      ' accountId: $accountId)'
      ' bankName: $bankName';
}
