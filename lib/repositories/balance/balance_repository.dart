import '../../common/models/account_db_model.dart';
import '../../common/models/balance_db_model.dart';
import '../../common/models/extends_date.dart';

abstract class BalanceRepository {
  Future<void> addBalance(BalanceDbModel balance);
  Future<BalanceDbModel> getBalanceId(int id);
  Future<BalanceDbModel> createTodayBalance(AccountDbModel? account);
  Future<BalanceDbModel?> getBalanceInDate({
    required ExtendedDate date,
    int? accountId,
  });
  Future<void> updateBalance(BalanceDbModel balance);
  Future<void> deleteBalance(int id);
}
