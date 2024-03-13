import 'dart:convert';

class OfxFinancialInstitution {
  final String organization;
  final String financialInstitutionID;

  OfxFinancialInstitution({
    required this.organization,
    required this.financialInstitutionID,
  });

  OfxFinancialInstitution copyWith({
    String? organization,
    String? financialInstitutionID,
  }) {
    return OfxFinancialInstitution(
      organization: organization ?? this.organization,
      financialInstitutionID:
          financialInstitutionID ?? this.financialInstitutionID,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'organization': organization,
      'financial_institution_id': financialInstitutionID,
    };
  }

  factory OfxFinancialInstitution.fromMapOfx(Map<String, dynamic> map) {
    return OfxFinancialInstitution(
      organization: map['ORG'].toString(),
      financialInstitutionID: map['FID'].toString(),
    );
  }

  factory OfxFinancialInstitution.fromMap(Map<String, dynamic> map) {
    return OfxFinancialInstitution(
      organization: map['organization'].toString(),
      financialInstitutionID: map['financial_institution_id'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OfxFinancialInstitution.fromJson(String source) =>
      OfxFinancialInstitution.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'FinancialInstitution('
      ' organization: $organization,'
      ' financialInstitutionID: $financialInstitutionID'
      ')';
}
