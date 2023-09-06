import 'dart:convert';

class StatisticResult {
  String categoryName;
  double totalSum;
  double? variation;

  StatisticResult({
    required this.categoryName,
    required this.totalSum,
    this.variation,
  });

  @override
  String toString() =>
      'StatisticResult(categoryName: $categoryName, totalSum: $totalSum)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryName': categoryName,
      'totalSum': totalSum,
    };
  }

  factory StatisticResult.fromMap(Map<String, dynamic> map) {
    return StatisticResult(
      categoryName: map['categoryName'] as String,
      totalSum: map['totalSum'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatisticResult.fromJson(String source) =>
      StatisticResult.fromMap(json.decode(source) as Map<String, dynamic>);
}
