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
  final _currentUser = locator<CurrentAccount>();

  @override
  Future<int> insertTransaction(TransactionDbModel transaction) async {
    try {
      int id = await _store.insertTransaction(transaction.toMap());
      // This exception is a program logical error
      if (id <= 0) {
        final message =
            'TransactionRepository.insertTransaction: return id $id!!!';
        log(message);
        throw Exception(message);
      }
      transaction.transId = id;
      return id;
    } catch (err) {
      log('TransactionRepository.insertTransaction: $err');
      return -1;
    }
  }

  @override
  Future<List<TransactionDbModel>> getTransactionForBalanceId(
      int balanceId) async {
    try {
      var maps = await _store.queryTransactionForBalanceId(balanceId);

      return maps
          .map((transMap) => TransactionDbModel.fromMap(transMap))
          .toList();
    } catch (err) {
      log('TransactionRepository.getTransId: $err');
      return [];
    }
  }

  @override
  Future<TransactionDbModel?> getTransactionId(int id) async {
    try {
      Map<String, Object?>? transMap = await _store.queryTransactionAtId(id);

      if (transMap == null) return null;
      return TransactionDbModel.fromMap(transMap);
    } catch (err) {
      log('TransactionRepository.getTransId: $err');
      return null;
    }
  }

  @override
  Future<int> deleteTransactionById(int transId) async {
    try {
      final result = await _store.deleteTransactionId(transId);
      if (result != 1) {
        throw Exception('_store.deleteTransactionId return $result');
      }

      return result;
    } catch (err) {
      log('TransactionRepository.deleteTransaction: $err');
      return -1;
    }
  }

  @override
  Future<void> getCardBalance({
    required CardBalanceModel cardBalance,
    ExtendedDate? date,
  }) async {
    try {
      int startDate;
      int endDate;

      (startDate, endDate) = ExtendedDate.getMillisecondsIntervalOfMonth(
        date ?? ExtendedDate.now(),
      );

      int accountId = _currentUser.accountId!;

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
    } catch (err) {
      log('TransactionRepository.getCardBalance: $err');
    }
  }

  @override
  Future<List<TransactionDbModel>> getNTransactionsFromDate({
    required ExtendedDate startDate,
    required int accountId,
    required int maxTransactions,
  }) async {
    try {
      final result = await _store.queryNTransactionsFromDate(
        startDate: startDate,
        accountId: accountId,
        maxTransactions: maxTransactions,
      );

      final List<TransactionDbModel> transactions = [];

      transactions.addAll(
        result.map((element) => TransactionDbModel.fromMap(element)),
      );

      return transactions;
    } catch (err) {
      log('TransactionRepository.getNTransactionsFromDate: $err');
      return [];
    }
  }

  @override
  Future<int> updateTransactionStatus({
    required int transId,
    required TransStatus status,
  }) async {
    try {
      final result = await _store.updateTransactionStatus(
        id: transId,
        newStatus: status.index,
      );

      return result;
    } catch (err) {
      log('TransactionRepository.updateTransStatus: $err');
      return -1;
    }
  }
}
