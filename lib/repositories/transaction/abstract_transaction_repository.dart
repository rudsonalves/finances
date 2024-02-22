import '../../common/models/card_balance_model.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/transaction_db_model.dart';

abstract class AbstractTransactionRepository {
  Future<void> addNewTransaction(TransactionDbModel transaction);
  Future<List<TransactionDbModel>> getTransForBalanceId(int balanceId);
  Future<TransactionDbModel?> getTransId(int id);
  Future<void> updateTransaction(TransactionDbModel transaction);
  Future<int> deleteTransaction(TransactionDbModel transaction);
  Future<int> updateTransStatus(int id, TransStatus status);
  Future<void> getCardBalance({
    required CardBalanceModel cardBalance,
    ExtendedDate? date,
  });
}
