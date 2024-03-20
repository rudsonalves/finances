import '../../common/models/account_db_model.dart';
import '../../common/models/category_db_model.dart';
import '../../store/manage_counter.dart';
import 'abstract_counter_repository.dart';

class CounterRepository implements AbstractCounterRepository {
  @override
  Future<int> countTransactionForCategoryId(CategoryDbModel category) async {
    final id = category.categoryId;
    if (id == null) return 0;
    return await ManageCount.countTransactionForCategoryId(id);
  }

  @override
  Future<int> countTransactionsForAccountId(AccountDbModel account) async {
    final id = account.accountId;
    if (id == null) return 0;
    return await ManageCount.countTransactionsForAccountId(id);
  }
}
