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

import '../../locator.dart';
import '../constants/constants.dart';
import '../database/database_manager.dart';

/// Manages counting operations for transactions in the database.
///
/// Utilizes [DatabaseManager] to execute counting queries related to transactions
/// based on category or account IDs.
abstract class IconStorer {
  /// Updates an existing icon record in the database.
  ///
  /// Parameters:
  ///   - iconMap: A map containing the updated icon data, including the icon's
  ///     unique ID.
  ///
  /// Returns the number of rows affected (should be 1 for a successful update),
  /// or -1 if an error occurs.
  Future<int> insertIcon(Map<String, dynamic> iconMap);

  /// Updates an existing icon record in the database.
  ///
  /// Parameters:
  ///   - iconMap: A map containing the updated icon data, including the icon's
  ///     unique ID.
  ///
  /// Returns the number of rows affected (should be 1 for a successful update),
  /// or -1 if an error occurs.
  Future<int> updateIcon(Map<String, dynamic> iconMap);

  /// Queries an icon record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the icon to be queried.
  ///
  /// Returns a map representing the icon's data if found, or null if not found.
  Future<Map<String, dynamic>?> queryIconId(int id);

  /// Deletes an icon record by its unique ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the icon to be deleted.
  Future<void> deleteIconId(int id);
}

class IconStore implements IconStorer {
  final _databaseManager = locator<DatabaseManager>();

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
