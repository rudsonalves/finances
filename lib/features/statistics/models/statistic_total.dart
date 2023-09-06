class StatisticTotal {
  double total;
  double reference;
  int count;

  StatisticTotal(
    this.total, [
    this.reference = 0,
    this.count = 1,
  ]);

  static StatisticTotal create(double value) {
    return StatisticTotal(value);
  }

  void addValue(double value) {
    total += value;
    count++;
  }
}
