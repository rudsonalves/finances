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
  Future<int> insert(TransactionDbModel transaction) async {
    try {
      int id = await _store.insert(transaction.toMap());
      // This exception is a program logical error
      if (id <= 0) {
        final message = 'return id $id!!!';

        throw Exception(message);
      }
      transaction.transId = id;
      return id;
    } catch (err) {
      final message = 'TransactionRepository.insertTransaction: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<List<TransactionDbModel>> getForBalanceId(int balanceId) async {
    try {
      var maps = await _store.queryForBalanceId(balanceId);

      return maps
          .map((transMap) => TransactionDbModel.fromMap(transMap))
          .toList();
    } catch (err) {
      final message = 'TransactionRepository.getTransId: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<TransactionDbModel?> getId(int id) async {
    try {
      Map<String, Object?>? transMap = await _store.queryId(id);

      if (transMap == null) return null;
      return TransactionDbModel.fromMap(transMap);
    } catch (err) {
      final message = 'TransactionRepository.getTransId: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> deleteById(int transId) async {
    try {
      final result = await _store.deleteId(transId);
      if (result != 1) {
        throw Exception('_store.deleteTransactionId return $result');
      }

      return result;
    } catch (err) {
      final message = 'TransactionRepository.deleteTransaction: $err';
      log(message);
      throw Exception(message);
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
      final message = 'TransactionRepository.getCardBalance: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<List<TransactionDbModel>> getNFromDate({
    required ExtendedDate startDate,
    required int accountId,
    required int maxTransactions,
  }) async {
    try {
      final result = await _store.queryNFromDate(
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
      final message = 'TransactionRepository.getNTransactionsFromDate: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<int> updateStatus({
    required int transId,
    required TransStatus status,
  }) async {
    try {
      final result = await _store.updateStatus(
        id: transId,
        newStatus: status.index,
      );

      return result;
    } catch (err) {
      final message = 'TransactionRepository.updateTransStatus: $err';
      log(message);
      throw Exception(message);
    }
  }

  @override
  Future<List<TransactionDbModel>> queryFromOfxId(int ofxId) async {
    try {
      final listOfMaps = await _store.queryFromOfxId(ofxId);

      List<TransactionDbModel> transactions = [];
      for (final map in listOfMaps) {
        transactions.add(TransactionDbModel.fromMap(map!));
      }
      return transactions;
    } catch (err) {
      final message = 'TransactionRepository.queryTransactionsFromOfxId: $err';
      log(message);
      throw Exception(message);
    }
  }
}
