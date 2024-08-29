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
