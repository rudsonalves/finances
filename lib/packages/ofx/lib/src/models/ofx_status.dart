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
