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

import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants/constants.dart';
import 'database/database_manager.dart';

// abstract class ManageCounter {
//   Future<int> countTransactionForCategoryId(int id);
//   Future<int> countTransactionsForAccountId(int id);
// }

/// Manages count queries related to transactions within the database.
///
/// Utilizes the DatabaseManager to execute queries that count transactions
/// based on specific criteria, such as category or account ID.
class ManageCount {
  static final _databaseManager = locator<DatabaseManager>();

  /// Counts the number of transactions associated with a specific category ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the category for which to count transactions.
  ///
  /// Returns the count of transactions for the specified category ID, or -1 if
  /// an error occurs.
  static Future<int> countTransactionForCategoryId(int id) async {
    final database = await _databaseManager.database;

    // const countTransactionForCategoryIdSQL =
    // 'SELECT COUNT(*) FROM $transactionsTable WHERE $transCategoryId = ?';

    try {
      int count = Sqflite.firstIntValue(await database.rawQuery(
            countTransactionForCategoryIdSQL,
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Counts the number of transactions directly associated with a specific account ID.
  ///
  /// This method queries the transactions table to count all transactions
  /// directly linked to the given account ID. It simplifies the process of
  /// determining the volume of transactions for a particular account,
  /// providing a straightforward count that can be useful for analysis or
  /// reporting purposes.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the account for which to count transactions.
  ///
  /// Returns:
  ///   The count of transactions associated with the specified account ID,
  ///   or -1 if an error occurs during the query execution.
  static Future<int> countTransactionsForAccountId(int id) async {
    final database = await _databaseManager.database;

    try {
      int count = Sqflite.firstIntValue(await database.rawQuery(
            countTransactionsForAccountIdSQL,
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }
}
