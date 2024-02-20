import 'dart:developer';

import '../../locator.dart';
import '../../store/transaction_store.dart';
import 'abstract_transaction_repository.dart';
import '../../common/models/extends_date.dart';
import '../../common/current_models/current_account.dart';
import '../../common/models/card_balance_model.dart';
import '../../common/models/transaction_db_model.dart';

class TransactionRepository implements AbstractTransactionRepository {
  final _store = TransactionStore();

  @override
  Future<void> addTrans(TransactionDbModel transaction) async {
    int transId = await _store.insertTransaction(transaction.toMap());
    if (transId < 0) {
      throw Exception('addTransaction return id $transId.');
    }
    transaction.transId = transId;
  }

  @override
  Future<List<TransactionDbModel>> getTransForBalanceId(int balanceId) async {
    var maps = await _store.rawQueryTransForBalanceId(balanceId);
    return maps
        .map((transMap) => TransactionDbModel.fromMap(transMap))
        .toList();
  }

  @override
  Future<TransactionDbModel?> getTransactionId(int id) async {
    Map<String, Object?>? transMap = await _store.queryTransactionAtId(id);

    if (transMap != null) return TransactionDbModel.fromMap(transMap);

    return null;
  }

  @override
  Future<int> updateTrans(TransactionDbModel transaction) async {
    int changes = await _store.updateTransaction(transaction.toMap());
    return changes;
  }

  @override
  Future<int> deleteTrans(TransactionDbModel transaction) async {
    int deleted = await _store.deleteTransactionId(transaction.transId!);
    return deleted;
  }

  @override
  Future<void> getCardBalance({
    required CardBalanceModel cardBalance,
    ExtendedDate? date,
  }) async {
    int startDate;
    int endDate;

    (startDate, endDate) = ExtendedDate.getMillisecondsIntervalOfMonth(
      date ?? ExtendedDate.now(),
    );

    int accountId = locator<CurrentAccount>().accountId!;

    double incomes = await _store.getIncomeBetweenDates(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
    );

    double expanses = await _store.getExpenseBetweenDates(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
    );

    cardBalance.incomes = incomes;
    cardBalance.expanses = expanses;
  }

  @override
  Future<int> updateTransactionStatus(
    int id,
    TransStatus status,
  ) async {
    final result = await _store.updateTransactionStatus(id, status.index);

    if (result != 1) {
      log('updateTransactionStatus return $result');
    }
    return result;
  }
}
