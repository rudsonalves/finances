import '../../common/current_models/current_balance.dart';
import '../../common/models/account_db_model.dart';
import '../../locator.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/balance_db_model.dart';
import '../../common/current_models/current_account.dart';
import '../../repositories/balance/balance_repository.dart';

class BalanceManager {
  BalanceManager._();

  /// This method injects a balance [injectedBalance] from account [account]
  /// into the linked list of balances in balanceTable.
  ///
  /// To locate the new balance injection position, the method starts from the
  /// last balance registered in the last account (account.accountLastBalance),
  /// and searches for a balance with a date lower than the [injectedBalance]
  /// date, or the balance where the balancePreviousId is null, the first
  /// balance on the list.
  ///
  /// Once the position is located, the injectedBalance will be injected in
  /// one of three possible positions:
  ///
  ///  1. Insert the balance at the beginning of the linked list of balances.
  ///     In this case, the balance found is the first in the list and with
  ///     a balanceDate greater than injectedBalance.balanceDate:
  ///     - points injectedBalance.balanceNextId to balance.balanceId;
  ///     - adds injectedBalance to balanceTable;
  ///     - updates balance.balancePreviousId to point to injectedBalance.balanceId;
  ///     - finally update the balance in the balanceTable.
  ///
  /// 2. Insert the balance at the beginning of the linked list of balances.
  ///    In this case, the balance found is the last one on the list and with
  ///    a balanceDate lower than injectedBalance.balanceDate:
  ///    - points injectedBalance.balancePreviousId to balance.balanceId;
  ///    - updates injectedBalance.balanceOpen and injectedBalance.balanceClose
  ///      with balance.balanceClose;
  ///    - adds injectedBalance to balanceTable;
  ///    - updates balance.balanceNextId to point to injectedBalance.balanceId;
  ///    - update the balance in the balanceTable;
  ///    - update account.accountLastBalance to point to
  ///      injectedBalance.balanceId;
  ///    - finally update the account.
  ///
  /// 3. Insert the balance in the middle of the linked list of balances. In
  ///    this case the balance found is the previous balance:
  ///    - updates injectedBalance.balancePreviousId with balance.balanceId;
  ///    - updates injectedBalance.balanceNextId with balance.balanceNextId;
  ///    - updates the injectedBalance.balanceOpen and
  ///      injectedBalance.balanceClose balances with the value of
  ///      balance.balanceClose;
  ///    - adds injectedBalance to balanceTable;
  ///    - updates balance.balanceNextId to point to injectedBalance.balanceId;
  ///    - update the balance in the balanceTable;
  ///    - loads the next balance to update;
  ///    - updates nextBalance.balancePreviousId to point to
  ///      injectedBalance.balanceId;
  ///    - update nextBalance in balanceTable;
  static Future<void> injectBalance({
    required BalanceDbModel injectedBalance,
    AccountDbModel? account,
  }) async {
    final currentAccount = locator<CurrentAccount>();
    final balanceRepository = locator<BalanceRepository>();

    account ??= currentAccount;
    // insert a new balance in balance indexed list
    BalanceDbModel balance =
        await balanceRepository.getBalanceId(account.accountLastBalance!);
    while (balance.balancePreviousId != null &&
        balance.balanceDate! > injectedBalance.balanceDate!) {
      balance =
          await balanceRepository.getBalanceId(balance.balancePreviousId!);
    }

    // insert injectedBalance at begin of indexed list
    if (balance.balancePreviousId == null &&
        balance.balanceDate! > injectedBalance.balanceDate!) {
      // save injectedBalance
      injectedBalance.balanceNextId = balance.balanceId;
      await balanceRepository.addBalance(injectedBalance);
      // update balance
      balance.balancePreviousId = injectedBalance.balanceId;
      await balanceRepository.updateBalance(balance);
      // it is not necessary to update the account,
      // as this has become the first balance of this account
      return;
    }

    // insert injectedBalance at the end of indexed list
    if (balance.balanceNextId == null &&
        balance.balanceDate! < injectedBalance.balanceDate!) {
      // save injectedBalance
      injectedBalance.balancePreviousId = balance.balanceId;
      injectedBalance.balanceOpen = balance.balanceClose;
      injectedBalance.balanceClose = balance.balanceClose;
      await balanceRepository.addBalance(injectedBalance);
      // update balance (now a previous balance)
      balance.balanceNextId = injectedBalance.balanceId;
      await balanceRepository.updateBalance(balance);
      // update account
      account.accountLastBalance = injectedBalance.balanceId;
      await account.updateAccount();
      return;
    }

    // insert injectedBalance in the middle
    injectedBalance.balancePreviousId = balance.balanceId;
    injectedBalance.balanceNextId = balance.balanceNextId;
    injectedBalance.balanceOpen = balance.balanceClose;
    injectedBalance.balanceClose = balance.balanceClose;
    await balanceRepository.addBalance(injectedBalance);
    // update previous balance
    balance.balanceNextId = injectedBalance.balanceId;
    await balanceRepository.updateBalance(balance);
    // update next balance
    final nextBalance = await balanceRepository.getBalanceId(
      injectedBalance.balanceNextId!,
    );
    nextBalance.balancePreviousId = injectedBalance.balanceId;
    await balanceRepository.updateBalance(nextBalance);
  }

  /// This method adds the [value] to the given [balance]
  static Future<void> addValue({
    required BalanceDbModel balance,
    required double value,
  }) async {
    final balanceRepository = locator<BalanceRepository>();

    balance.balanceClose += value;
    balance.balanceTransCount += 1;
    await balanceRepository.updateBalance(balance);

    if (balance.balanceNextId != null) {
      BalanceDbModel nextBalance =
          await balanceRepository.getBalanceId(balance.balanceNextId!);

      while (true) {
        nextBalance.balanceOpen += value;
        nextBalance.balanceClose += value;
        await balanceRepository.updateBalance(nextBalance);
        if (nextBalance.balanceNextId == null) break;
        nextBalance =
            await balanceRepository.getBalanceId(nextBalance.balanceNextId!);
      }
    }
    // is necessary reload currentBalance
    await _reloadCurrentBalance();
    return;
  }

  /// This method subtracts the value [value] in the given [balance]
  static Future<void> subtractValue({
    required BalanceDbModel balance,
    required double value,
  }) async {
    final balanceRepository = locator<BalanceRepository>();

    balance.balanceClose -= value;
    balance.balanceTransCount -= 1;
    await balanceRepository.updateBalance(balance);

    if (balance.balanceNextId != null) {
      BalanceDbModel nextBalance =
          await balanceRepository.getBalanceId(balance.balanceNextId!);

      while (true) {
        nextBalance.balanceOpen -= value;
        nextBalance.balanceClose -= value;
        // nextBalance.balanceTransCount -= 1;
        await balanceRepository.updateBalance(nextBalance);
        if (nextBalance.balanceNextId == null) break;
        nextBalance =
            await balanceRepository.getBalanceId(nextBalance.balanceNextId!);
      }
    }
    // is necessary reload currentBalance
    await _reloadCurrentBalance();
    return;
  }

  static Future<void> _reloadCurrentBalance() async {
    final balanceRepository = locator<BalanceRepository>();
    final balance = await balanceRepository.getBalanceInDate(
      date: ExtendedDate.nowDate(),
    );
    locator<CurrentBalance>().setFromBalanceDbModel(balance!);
  }
}
