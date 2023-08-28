import '../../../locator.dart';
import '../../../common/models/extends_date.dart';
import '../../../common/models/balance_db_model.dart';
import '../../../common/models/trans_day_db_model.dart';
import '../../../common/current_models/current_account.dart';
import '../../../common/models/transaction_db_model.dart';
import '../../../repositories/balance/balance_repository.dart';
import '../../../common/models/account_db_model.dart';
import '../../../repositories/trans_day/trans_day_repository.dart';
import '../../../repositories/transaction/transaction_repository.dart';
import 'balance_manager.dart';

class TransactionsManager {
  TransactionsManager._();

  /// Adds a new transaction to the system.
  ///
  /// This function adds the [transaction] to the database and updates the
  /// balance and daily transaction records.
  ///
  /// [transaction] is the transaction model to be added.
  /// [account] is an optional instance of [AccountDbModel] representing the
  /// associated account.
  ///
  /// Example usage:
  /// ```dart
  /// final transaction = TransactionDbModel(
  ///   // Fill in the transaction fields
  /// );
  /// await addTransaction(transaction: transaction);
  /// ```
  static Future<void> addTransaction({
    required TransactionDbModel transaction,
    AccountDbModel? account,
  }) async {
    account ??= locator.get<CurrentAccount>();

    final transRepository = locator.get<TransactionRepository>();
    final balanceRepository = locator.get<BalanceRepository>();
    final transDayRepository = locator.get<TransDayRepository>();

    await transRepository.addTrans(transaction);

    final transDate = transaction.transDate.onlyDate;

    BalanceDbModel? balance = await balanceRepository.getBalanceInDate(
      date: transDate,
      accountId: account.accountId,
    );

    if (balance == null) {
      balance = BalanceDbModel(
        balanceAccountId: account.accountId,
        balanceDate: transDate,
      );
      await BalanceManager.injectBalance(
        injectedBalance: balance,
        account: account,
      );
    }

    await BalanceManager.addValue(
      balance: balance,
      value: transaction.transValue,
    );

    await transDayRepository.addTransDay(
      TransDayDbModel(
        transDayBalanceId: balance.balanceId,
        transDayTransId: transaction.transId,
      ),
    );
  }

  /// This function is used to update a transaction within the system.
  ///
  /// This method updates a given transaction [transaction] in the system. If
  /// an associated account [account] is not provided, it defaults to the
  /// current account.
  ///
  /// First, it retrieves the existing version of the transaction [oldTrans]
  /// from the database. If either the date or value of the transaction has
  /// been modified, it invokes the removeTransaction method to delete the old
  /// transaction, subsequently nullifying its ID. Then, it adds the updated
  /// transaction to the database.
  ///
  /// Alternatively, if the date and value remain unchanged, the transaction
  /// is updated directly within the database.
  ///
  /// Example of usage:
  /// ```
  /// await TransactionsManager.updateTransaction(
  ///   transaction: updatedTransaction,
  ///   account: account,
  /// );
  /// ```
  static Future<void> updateTransaction({
    required TransactionDbModel transaction,
    AccountDbModel? account,
  }) async {
    account ??= locator.get<CurrentAccount>();
    final transRepository = locator.get<TransactionRepository>();

    final oldTrans = await transRepository.getTransactionId(
      transaction.transId!,
    );
    if ((oldTrans!.transDate.onlyDate != transaction.transDate.onlyDate) ||
        (oldTrans.transValue != transaction.transValue)) {
      // update balance date or value
      await removeTransaction(oldTrans);
      transaction.transId = null;
      await addTransaction(
        transaction: transaction,
        account: account,
      );
    } else {
      // write updated transaction
      await transRepository.updateTrans(transaction);
    }
  }

  /// Removes a transaction from the system.
  ///
  /// This function removes the specified [transaction] from the database,
  /// updates the associated balance, and removes related daily transaction
  /// records.
  ///
  /// [transaction] is the transaction model to be removed.
  ///
  /// Example usage:
  /// ```dart
  /// final transactionToRemove = TransactionDbModel(
  ///   // Fill in the transaction fields
  /// );
  /// await removeTransaction(transactionToRemove);
  /// ```
  static Future<void> removeTransaction(TransactionDbModel transaction) async {
    final transRepository = locator.get<TransactionRepository>();
    final balanceRepository = locator.get<BalanceRepository>();
    final transDayRepository = locator.get<TransDayRepository>();

    TransDayDbModel transDay =
        await transDayRepository.getTransDayId(transaction.transId!);

    final BalanceDbModel balance =
        await balanceRepository.getBalanceId(transDay.transDayBalanceId!);
    await BalanceManager.subtractValue(
      balance: balance,
      value: transaction.transValue,
    );

    await transDayRepository.deleteTransDayId(transaction.transId!);
    // TODO: verificar se é necessário apagar a transação.
    await transRepository.deleteTrans(transaction);
  }

  /// Return the first [maxItens] transactions carried out in the
  /// currentAccount, from date [date]. If [date] is null, use the current date.
  static Future<List<TransactionDbModel>> getNTransFromDate({
    int maxItens = 20,
    ExtendedDate? date,
  }) async {
    final transRepository = locator.get<TransactionRepository>();
    final balanceRepository = locator.get<BalanceRepository>();

    date ??= ExtendedDate.now();
    int count = 0;
    var balance = await findBalanceCloseDate(date.onlyDate);

    List<TransactionDbModel> transactions = [];

    while (count < maxItens) {
      if (balance.balanceTransCount > 0) {
        count += balance.balanceTransCount;
        final newTransactions = await transRepository.getTransForBalanceId(
          balance.balanceId!,
        );
        transactions.addAll(newTransactions);
      }
      if (balance.balancePreviousId == null) break;
      balance = await balanceRepository.getBalanceId(
        balance.balancePreviousId!,
      );
    }

    return transactions;
  }

  /// Return the previous balance (for currentAccount) to the nearest
  /// current date.
  static Future<BalanceDbModel> findBalanceCloseDate(ExtendedDate date) async {
    final balanceRepository = locator.get<BalanceRepository>();
    final currentAccount = locator.get<CurrentAccount>();

    var balance = await balanceRepository.getBalanceInDate(date: date.onlyDate);
    if (balance != null) return balance;

    var previousBalance = await balanceRepository.getBalanceId(
      currentAccount.accountLastBalance!,
    );

    while (previousBalance.balancePreviousId != null &&
        previousBalance.balanceDate! > date.onlyDate) {
      previousBalance = await balanceRepository.getBalanceId(
        previousBalance.balancePreviousId!,
      );
    }

    return previousBalance;
  }
}
