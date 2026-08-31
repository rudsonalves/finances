import '../common/models/balance_db_model.dart';
import '../common/models/extends_date.dart';
import '../locator.dart';
import '../repositories/balance/abstract_balance_repository.dart';

sealed class BalanceManager {
  static AbstractBalanceRepository get repository =>
      locator<AbstractBalanceRepository>();

  BalanceManager._();

  static Future<BalanceDbModel> getBalanceInDate({
    required ExtendedDate date,
    required int accountId,
  }) async {
    final onlyDate = date.onlyDate;

    var balance = await getClosedBalanceToDate(
      date: onlyDate,
      accountId: accountId,
    );

    if (balance != null && balance.balanceDate == onlyDate) {
      return balance;
    }

    if (balance == null) {
      balance = BalanceDbModel(
        balanceAccountId: accountId,
        balanceDate: onlyDate,
      );
    } else {
      final previousClosingBalance = balance.balanceClose;

      balance = BalanceDbModel(
        balanceAccountId: accountId,
        balanceDate: onlyDate,
        balanceTransCount: 0,
        balanceOpen: previousClosingBalance,
        balanceClose: previousClosingBalance,
      );
    }

    await repository.insert(balance);

    return balance;
  }

  static Future<BalanceDbModel?> getClosedBalanceToDate({
    required ExtendedDate date,
    required int accountId,
  }) async {
    final onlyDate = date.onlyDate;

    var balance = await repository.getInDate(
      date: onlyDate,
      accountId: accountId,
    );

    return balance;
  }
}
