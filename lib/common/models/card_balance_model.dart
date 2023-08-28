class CardBalanceModel {
  double incomes;
  double expanses;
  double get balance => incomes + expanses;

  CardBalanceModel({
    this.incomes = 0.0,
    this.expanses = 0.0,
  });

  @override
  String toString() => 'BalanceModel:'
      ' Incomes: $incomes;'
      ' Expanses: $expanses;'
      ' Balance: $balance';
}
