import 'package:sqflite/sqflite.dart';

import 'constants.dart';

/// Manages database schema migrations for the application.
///
/// This class provides mechanisms to apply schema migrations to the SQLite database,
/// ensuring the database schema is up-to-date with the current version of the application.
/// It maintains a map of migration scripts organized by database version numbers.
class DatabaseMigrations {
  /// Database Scheme Version declarations
  ///
  /// This is the database scheme current version. To futures upgrades
  /// in database increment this value and add a new update script in
  /// _migrationScripts Map.
  static const databaseSchemeVersion = 1007;

  // Retrieves the database schema version in a readable format (e.g., "1.0.7").
  static String get dbSchemeVersion {
    String version = databaseSchemeVersion.toString();
    int length = version.length;
    return '${version.substring(0, length - 3)}.'
        '${version.substring(length - 3, length - 2)}.'
        '${version.substring(length - 2)}';
  }

  /// This Map contains the database migration scripts. The last index of this
  /// Map must be equal to the current version of the database.
  static const Map<int, List<String>> migrationScripts = {
    1000: [],
    1001: [
      'ALTER TABLE categoriesTable ADD COLUMN categoryBudget REAL DEFAULT 0'
    ],
    1002: [
      'ALTER TABLE $usersTable ADD COLUMN $userGrpShowGrid INTEGER DEFAULT 1',
      'ALTER TABLE $usersTable ADD COLUMN $userGrpIsCurved INTEGER DEFAULT 0',
      'ALTER TABLE $usersTable ADD COLUMN $userGrpShowDots INTEGER DEFAULT 0',
      'ALTER TABLE $usersTable ADD COLUMN $userGrpAreaChart INTEGER DEFAULT 0',
    ],
    1003: [
      'ALTER TABLE $usersTable ADD COLUMN $userBudgetRef INTEGER DEFAULT 2',
    ],
    1004: [
      'ALTER TABLE $usersTable ADD COLUMN $userCategoryList TEXT DEFAULT "[]"',
    ],
    1005: [
      'ALTER TABLE $categoriesTable ADD COLUMN $categoryIsIncome INTEGER DEFAULT 0',
    ],
    1006: [
      'ALTER TABLE $usersTable ADD COLUMN $userMaxTransactions INTEGER DEFAULT 35',
    ],
    1007: [
      'ALTER TABLE $appControlTable ADD COLUMN $appControlApp TEXT DEFAULT ""',
    ],
  };

  /// Applies migration scripts to the database batch.
  ///
  /// This method iterates through the migration scripts from the current
  /// database version up to the target version, executing each script in
  /// sequence to update the database schema.
  ///
  /// - Parameters:
  ///   - batch: The database batch on which to execute the migration scripts.
  ///   - currentVersion: The current version of the database schema.
  ///   - targetVersion: The target version to which the database should
  ///     be migrated.
  static void applyMigrations({
    required Batch batch,
    required int currentVersion,
    required int targetVersion,
  }) {
    for (var version = currentVersion + 1;
        version <= targetVersion;
        version++) {
      final scripts = migrationScripts[version];
      if (scripts != null) {
        for (final script in scripts) {
          batch.execute(script);
        }
      }
    }
  }
}
