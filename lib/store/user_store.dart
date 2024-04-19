import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants/constants.dart';
import 'database/database_manager.dart';

abstract class UserStorer {
  Future<int> insertUser(Map<String, dynamic> userMap);
  Future<Map<String, Object?>?> queryUserId(String id);
  Future<List<Map<String, dynamic>>> queryAllUsers();
  Future<int> updateUser(Map<String, dynamic> userMap);
  Future<int> updateUserBudgetRef(String id, int budgetRef);
  Future<int> updateUserGrpShowGrid(String id, int grpShowGrid);
  Future<int> updateUserGrpShowDots(String id, int grpShowDots);
  Future<int> updateUserGrpIsCurved(String id, int grpIsCurved);
  Future<int> updateUserGrpAreaChart(String id, int grpAreaChart);
  Future<int> updateUserLanguage(String id, String language);
  Future<int> updateUserTheme(String id, String theme);
  Future<int> updateUserMaxTransactions(String id, int maxTransactions);
}

/// Manages database operations for user-related data.
///
/// Facilitates the insertion, querying, and updating of user records in the database,
/// leveraging the DatabaseManager for interactions with the database.
class UserStore implements UserStorer {
  final _databaseManager = locator<DatabaseManager>();

  /// Inserts a new user record into the database.
  ///
  /// Parameters:
  ///   - userMap: A map containing the user data to be inserted.
  ///
  /// Returns the row ID of the newly inserted user, or -1 if an error occurs.
  @override
  Future<int> insertUser(Map<String, dynamic> userMap) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.insert(
        usersTable,
        userMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('UserStore.insertUser: $err');
      return -1;
    }
  }

  /// Queries a user record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user to be queried.
  ///
  /// Returns a map representing the user's data if found, or null if not found.
  @override
  Future<Map<String, Object?>?> queryUserId(String id) async {
    try {
      final database = await _databaseManager.database;

      final List<Map<String, Object?>> result = await database.query(
        usersTable,
        where: '$userId = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;

      return result.first;
    } catch (err) {
      log('UserStore.queryUserId: $err');
      return {};
    }
  }

  /// Queries all user records.
  ///
  /// Returns a list of maps, each representing a user's data.
  @override
  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    try {
      final database = await _databaseManager.database;

      List<Map<String, dynamic>> result = await database.query(usersTable);
      return result;
    } catch (err) {
      log('UserStore.queryAllUsers: $err');
      return [];
    }
  }

  /// Updates an existing user record in the database.
  ///
  /// Parameters:
  ///   - userMap: A map containing the updated user data, including the user's unique ID.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUser(Map<String, dynamic> userMap) async {
    try {
      final database = await _databaseManager.database;

      String id = userMap[userId];
      int result = await database.update(
        usersTable,
        userMap,
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUser: $err');
      return -1;
    }
  }

  /// Updates the budget reference for a specific user.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - budgetRef: The new budget reference value.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserBudgetRef(String id, int budgetRef) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userBudgetRef: budgetRef},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserBudgetRef: $err');
      return -1;
    }
  }

  /// Updates the user preference for showing the grid.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - grpShowGrid: The new preference value for showing the userGrpShowGrid.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserGrpShowGrid(String id, int grpShowGrid) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userGrpShowGrid: grpShowGrid},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserGrpShowGrid: $err');
      return -1;
    }
  }

  /// Updates the user preference for showing the dots.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - grpShowDots: The new preference value for showing the userGrpShowDots.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserGrpShowDots(String id, int grpShowDots) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userGrpShowDots: grpShowDots},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserGrpShowDots: $err');
      return -1;
    }
  }

  /// Updates the user preference for showing the isCurve.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - grpIsCurved: The new preference value for showing the userGrpIsCurved.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserGrpIsCurved(String id, int grpIsCurved) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userGrpIsCurved: grpIsCurved},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserGrpIsCurved: $err');
      return -1;
    }
  }

  /// Updates the user preference for showing the areaChart.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - grpAreaChart: The new preference value for showing the userGrpAreaChart.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserGrpAreaChart(String id, int grpAreaChart) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userGrpAreaChart: grpAreaChart},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserGrpAreaChart: $err');
      return -1;
    }
  }

  /// Updates the user preference for showing the language.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - language: The new preference value for showing the userLanguage.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserLanguage(String id, String language) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userLanguage: language},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserLanguage: $err');
      return -1;
    }
  }

  /// Updates the user preference for showing the theme.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - theme: The new preference value for showing the userTheme.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserTheme(String id, String theme) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userTheme: theme},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserTheme: $err');
      return -1;
    }
  }

  /// Updates the user preference for showing the maxTransactions.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the user.
  ///   - maxTransactions: The new preference value for showing the userMaxTransactions.
  ///
  /// Returns the number of rows affected, or -1 if an error occurs.
  @override
  Future<int> updateUserMaxTransactions(String id, int maxTransactions) async {
    try {
      final database = await _databaseManager.database;

      int result = await database.update(
        usersTable,
        {userMaxTransactions: maxTransactions},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('UserStore.updateUserMaxTransactions: $err');
      return -1;
    }
  }
}
