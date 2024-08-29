// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import '../../locator.dart';
import '../constants/constants.dart';
import '../database/database_manager.dart';

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
