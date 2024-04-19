import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../locator.dart';
import '../constants/constants.dart';
import '../database/database_manager.dart';

/// Manages database operations for category-related data.
///
/// Provides methods to insert, query, update, and delete category records in
/// the database, facilitating interactions with the categories table through
/// the DatabaseManager.
abstract class CatgoryStorer {
  /// Inserts a new category record into the database.
  ///
  /// Parameters:
  ///   - categoryMap: A map containing the category data to be inserted.
  ///
  /// Returns the row ID of the newly inserted category, or -1 if an error
  /// occurs.
  Future<int> insertCategory(Map<String, dynamic> categoryMap);

  /// Queries all categories sorted by name in ascending order.
  ///
  /// Returns a list of maps, each representing a category's data.
  Future<List<Map<String, dynamic>>> queryAllCategories();

  /// Updates an existing category record in the database.
  ///
  /// Parameters:
  ///   - categoryMap: A map containing the updated category data, including the
  ///     category's unique ID.
  Future<void> updateCategory(Map<String, dynamic> categoryMap);

  /// Updates the budget for a specific category by its ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the category to be updated.
  ///   - budget: The new budget value for the category.
  Future<void> updateCategoryBudget(int id, double budget);

  /// Deletes a category record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the category to be deleted.
  Future<void> deleteCategoryId(int id);
}

class CatgoryStore implements CatgoryStorer {
  final _databaseManager = locator<DatabaseManager>();

  @override
  Future<int> insertCategory(Map<String, dynamic> categoryMap) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.insert(
        categoriesTable,
        categoryMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryAllCategories() async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, dynamic>> result = await database.query(
        categoriesTable,
        orderBy: '$categoryName ASC',
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  @override
  Future<void> updateCategory(Map<String, dynamic> categoryMap) async {
    final database = await _databaseManager.database;

    try {
      int id = categoryMap[categoryId];
      await database.update(
        categoriesTable,
        categoryMap,
        where: '$categoryId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  @override
  Future<void> updateCategoryBudget(int id, double budget) async {
    final database = await _databaseManager.database;

    try {
      await database.update(
        categoriesTable,
        {categoryBudget: budget},
        where: '$categoryId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  @override
  Future<void> deleteCategoryId(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        categoriesTable,
        where: '$categoryId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }
}
