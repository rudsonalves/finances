import '../../../locator.dart';
import './balance_manager.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/models/balance_db_model.dart';
import '../../../common/current_models/current_account.dart';
import '../../../repositories/balance/balance_repository.dart';

class AccountManager {
  AccountManager._();

  /// This method returns the current date balance of the [account] passed.
  /// If no balance is found, a new one will be injected on the current date.
  static Future<BalanceDbModel> getAccountTodayBalance(
    AccountDbModel? account,
  ) async {
    final balanceRepository = locator.get<BalanceRepository>();

    account ??= locator.get<CurrentAccount>();
    final date = ExtendedDate.nowDate();
    BalanceDbModel? todayBalance = await balanceRepository.getBalanceInDate(
      date: date,
      accountId: account.accountId,
    );

    // insert a new balance in the account (accountId)
    if (todayBalance == null) {
      todayBalance = BalanceDbModel(
        balanceAccountId: account.accountId,
        balanceDate: date,
      );
      BalanceManager.injectBalance(
        injectedBalance: todayBalance,
        account: account,
      );
    }

    return todayBalance;
  }
}
