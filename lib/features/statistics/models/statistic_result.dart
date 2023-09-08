import 'dart:convert';

class StatisticResult {
  String categoryName;
  double monthSum;
  double? variation;

  StatisticResult({
    this.categoryName = '',
    this.monthSum = 0.0,
    this.variation,
  });

  @override
  String toString() =>
      'StatisticResult(categoryName: $categoryName, totalSum: $monthSum)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryName': categoryName,
      'totalSum': monthSum,
    };
  }

  factory StatisticResult.fromMap(Map<String, dynamic> map) {
    return StatisticResult(
      categoryName: map['categoryName'] as String,
      monthSum: map['totalSum'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatisticResult.fromJson(String source) =>
      StatisticResult.fromMap(json.decode(source) as Map<String, dynamic>);
}
