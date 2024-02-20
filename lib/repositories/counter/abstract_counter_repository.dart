import '../../common/models/account_db_model.dart';
import '../../common/models/category_db_model.dart';

abstract class AbstractCounterRepository {
  Future<int> countTransactionForCategoryId(CategoryDbModel category);
  Future<int> countTransactionsForAccountId(AccountDbModel account);
}
