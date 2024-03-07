import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../locator.dart';
import 'constants.dart';
import 'database_manager.dart';

abstract class IconStorer {
  Future<int> insertIcon(Map<String, dynamic> iconMap);
  Future<int> updateIcon(Map<String, dynamic> iconMap);
  Future<Map<String, dynamic>?> queryIconId(int id);
  Future<void> deleteIconId(int id);
}

/// Manages counting operations for transactions in the database.
///
/// Utilizes [DatabaseManager] to execute counting queries related to transactions
/// based on category or account IDs.
class IconStore implements IconStorer {
  final _databaseManager = locator<DatabaseManager>();

  /// Updates an existing icon record in the database.
  ///
  /// Parameters:
  ///   - iconMap: A map containing the updated icon data, including the icon's
  ///     unique ID.
  ///
  /// Returns the number of rows affected (should be 1 for a successful update),
  /// or -1 if an error occurs.
  @override
  Future<int> insertIcon(Map<String, dynamic> iconMap) async {
    final database = await _databaseManager.database;

    try {
      int result = await database.insert(
        iconsTable,
        iconMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Updates an existing icon record in the database.
  ///
  /// Parameters:
  ///   - iconMap: A map containing the updated icon data, including the icon's
  ///     unique ID.
  ///
  /// Returns the number of rows affected (should be 1 for a successful update),
  /// or -1 if an error occurs.
  @override
  Future<int> updateIcon(Map<String, dynamic> iconMap) async {
    final database = await _databaseManager.database;

    try {
      int id = iconMap[iconId];
      int result = await database.update(
        iconsTable,
        iconMap,
        where: '$iconId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Queries an icon record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the icon to be queried.
  ///
  /// Returns a map representing the icon's data if found, or null if not found.
  @override
  Future<Map<String, dynamic>?> queryIconId(int id) async {
    final database = await _databaseManager.database;

    try {
      List<Map<String, dynamic>> result = await database.query(
        iconsTable,
        where: '$iconId = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return result[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }

  /// Deletes an icon record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the icon to be deleted.
  @override
  Future<void> deleteIconId(int id) async {
    final database = await _databaseManager.database;

    try {
      await database.delete(
        iconsTable,
        where: '$iconId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }
}
