import 'dart:developer';

import '../../locator.dart';
import '../constants/constants.dart';
import '../database/database_manager.dart';

abstract class StatisticStorer {
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
    required int accountId,
  });
}

class StatisticStore implements StatisticStorer {
  final _databaseManager = locator<DatabaseManager>();

  @override
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
    required int accountId,
  }) async {
    final database = await _databaseManager.database;

    try {
      final results = await database.rawQuery(
        'SELECT c.$categoryName, SUM(t.$transValue) as totalSum'
        ' FROM $transactionsTable t'
        ' INNER JOIN $categoriesTable c ON t.$transCategoryId = c.$categoryId'
        ' WHERE t.$transDate BETWEEN ? AND ?'
        '   AND t.$transAccountId = ?'
        ' GROUP BY c.$categoryName'
        ' ORDER BY c.$categoryName',
        [startDate, endDate, accountId],
      );
      if (results.isEmpty) {
        return [];
      }
      return results;
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }
}
