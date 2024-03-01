import '../../locator.dart';
import '../../manager/balance_manager.dart';
import '../models/extends_date.dart';
import 'current_account.dart';
import '../models/balance_db_model.dart';
import '../../repositories/balance/abstract_balance_repository.dart';

class CurrentBalance extends BalanceDbModel {
  CurrentBalance();

  final balanceRepository = locator<AbstractBalanceRepository>();
  final currentAccount = locator<CurrentAccount>();

  Future<void> start() async {
    final balance = await BalanceManager.getClosedBalanceToDate(
      date: ExtendedDate.nowDate(),
      accountId: currentAccount.accountId!,
    );

    setFromBalanceDbModel(balance);
  }

  // replace currentBalance by a passed balance
  void setFromBalanceDbModel(BalanceDbModel? balance) {
    balanceId = balance?.balanceId;
    balanceAccountId = balance?.balanceAccountId;
    balanceDate = balance?.balanceDate;
    balanceOpen = balance?.balanceOpen ?? 0.0;
    balanceClose = balance?.balanceClose ?? 0.0;
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
