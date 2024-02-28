import 'dart:developer';

import '../locator.dart';
import 'constants.dart';
import 'database_manager.dart';

abstract class StatisticStorer {
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory(
      {required int startDate, required int endDate});
}

/// Manages database operations for generating statistical data.
///
/// Utilizes [DatabaseManager] to perform complex queries for statistical analysis,
/// such as summing transactions by category over a specified date range.
class StatisticStore implements StatisticStorer {
  final _databaseManager = locator<DatabaseManager>();

  /// Retrieves the sum of transactions by category within a specified date range.
  ///
  /// This method performs a query that sums transaction values grouped by
  /// category name, for transactions occurring between the start and end dates
  /// provided.
  ///
  /// Parameters:
  ///   - startDate: The start of the date range, inclusive, as an integer.
  ///   - endDate: The end of the date range, inclusive, as an integer.
  ///
  /// Returns a list of maps where each map contains the category name and the
  /// total sum of transactions for that category within the specified date range.
  /// Returns an empty list if no transactions match the criteria. Returns null
  /// if an error occurs.
  @override
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
  }) async {
    final database = await _databaseManager.database;

    try {
      final results = await database.rawQuery(
        'SELECT c.$categoryName, SUM(t.$transValue) as totalSum'
        ' FROM $transactionsTable t'
        ' INNER JOIN $categoriesTable c ON t.$transCategoryId = c.$categoryId'
        ' WHERE t.$transDate BETWEEN ? AND ?'
        ' GROUP BY c.$categoryName'
        ' ORDER BY c.$categoryName',
        [startDate, endDate],
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
