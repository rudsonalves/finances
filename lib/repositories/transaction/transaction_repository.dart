import '../../common/models/card_balance_model.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/transaction_db_model.dart';

abstract class TransactionRepository {
  Future<void> addTrans(TransactionDbModel transaction);

  Future<List<TransactionDbModel>> getTransForBalanceId(int balanceId);

  Future<TransactionDbModel?> getTransactionId(int id);

  Future<int> updateTrans(TransactionDbModel transaction);

  Future<int> deleteTrans(TransactionDbModel transaction);

  /// Return the balance from last moth
  Future<void> getCardBalance({
    required CardBalanceModel cardBalance,
    ExtendedDate? date,
  });
}
