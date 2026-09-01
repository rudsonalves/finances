import 'package:finances/common/current_models/current_account.dart';
import 'package:finances/locator.dart';

import '../../store/stores/statistic_store.dart';
import 'abstract_statistic_repository.dart';

class StatisticRepository implements AbstractStatisticRepository {
  final _store = StatisticStore();
  final _currentAccount = locator<CurrentAccount>();

  @override
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
  }) async {
    return await _store.getTransactionSumsByCategory(
      startDate: startDate,
      endDate: endDate,
      accountId: _currentAccount.accountId!,
    );
  }
}
