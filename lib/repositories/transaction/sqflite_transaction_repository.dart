import '../../locator.dart';
import './transaction_repository.dart';
import '../../services/database/database_helper.dart';
import '../../common/models/extends_date.dart';
import '../../common/current_models/current_account.dart';
import '../../common/models/card_balance_model.dart';
import '../../common/models/transaction_db_model.dart';

class SqfliteTransactionRepository implements TransactionRepository {
  final DatabaseHelper helper = locator.get<DatabaseHelper>();

  @override
  Future<void> addTrans(TransactionDbModel transaction) async {
    int transId = await helper.insertTransaction(transaction.toMap());
    if (transId < 0) {
      throw Exception('addTransaction return id $transId.');
    }
    transaction.transId = transId;
  }

  @override
  Future<List<TransactionDbModel>> getTransForBalanceId(int balanceId) async {
    var maps = await helper.rawQueryTransForBalanceId(balanceId);
    return maps
        .map((transMap) => TransactionDbModel.fromMap(transMap))
        .toList();
  }

  @override
  Future<TransactionDbModel?> getTransactionId(int id) async {
    Map<String, Object?>? transMap = await helper.queryTransactionAtId(id);

    if (transMap != null) return TransactionDbModel.fromMap(transMap);

    return null;
  }

  @override
  Future<int> updateTrans(TransactionDbModel transaction) async {
    int changes = await helper.updateTransaction(transaction.toMap());
    return changes;
  }

  @override
  Future<int> deleteTrans(TransactionDbModel transaction) async {
    int deleted = await helper.deleteTransactionId(transaction.transId!);
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

    int accountId = locator.get<CurrentAccount>().accountId!;

    double incomes = await helper.getIncomeBetweenDates(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
    );

    double expanses = await helper.getExpenseBetweenDates(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
    );

    cardBalance.incomes = incomes;
    cardBalance.expanses = expanses;
  }
}
