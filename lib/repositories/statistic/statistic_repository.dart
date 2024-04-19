import '../../store/stores/statistic_store.dart';
import 'abstract_statistic_repository.dart';

class StatisticRepository implements AbstractStatisticRepository {
  final _store = StatisticStore();

  @override
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
  }) async {
    return await _store.getTransactionSumsByCategory(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
