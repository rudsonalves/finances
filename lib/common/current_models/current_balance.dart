import '../../locator.dart';
import 'current_account.dart';
import '../models/balance_db_model.dart';
import '../../repositories/balance/abstract_balance_repository.dart';

class CurrentBalance extends BalanceDbModel {
  CurrentBalance();

  final balanceRepository = locator<AbstractBalanceRepository>();
  final currentAccount = locator<CurrentAccount>();

  Future<void> start() async {
    final balance = await balanceRepository.createTodayBalance(currentAccount);
    setFromBalanceDbModel(balance);
  }

  // replace currentBalance by a passed balance
  void setFromBalanceDbModel(BalanceDbModel balance) {
    balanceId = balance.balanceId;
    balanceAccountId = balance.balanceAccountId;
    balanceDate = balance.balanceDate;
    balanceOpen = balance.balanceOpen;
    balanceClose = balance.balanceClose;
  }

  factory CurrentBalance.fromAccountDbModel(BalanceDbModel balance) {
    final newBalance = CurrentBalance();
    newBalance.setFromBalanceDbModel(balance);

    return newBalance;
  }

  // update currentBalance
  Future<void> update() async {
    await balanceRepository.updateBalance(this);
  }
}
