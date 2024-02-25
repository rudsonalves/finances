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
  static const databaseSchemeVersion = 1008;

  // Retrieves the database schema version in a readable format (e.g., "1.0.07").
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
    1008: [
      'ALTER TABLE $transactionsTable ADD COLUMN $transBalanceId INTEGER',
      'ALTER TABLE $transactionsTable ADD COLUMN $transAccountId INTEGER',
      'UPDATE $transactionsTable SET $transBalanceId = ('
          'SELECT transDayBalanceId FROM transDayTable '
          '  WHERE transDayTable.transDayTransId = $transactionsTable.$transId'
          ')',
      'UPDATE $transactionsTable SET $transAccountId = ('
          'SELECT $balanceAccountId FROM $balanceTable'
          '  WHERE $balanceTable.$balanceId = $transactionsTable.$transBalanceId'
          ')',
      'PRAGMA foreign_keys=off',
      'BEGIN TRANSACTION',
      'CREATE TABLE IF NOT EXISTS ${transactionsTable}_new ('
          ' $transId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $transBalanceId INTEGER NOT NULL,'
          ' $transAccountId INTEGER NOT NULL,'
          ' $transDescription TEXT NOT NULL,'
          ' $transCategoryId INTEGER NOT NULL,'
          ' $transValue REAL NOT NULL,'
          ' $transStatus INTEGER NOT NULL,'
          ' $transTransferId INTEGER,'
          ' $transDate INTEGER NOT NULL,'
          ' FOREIGN KEY ($transCategoryId)'
          '   REFERENCES $categoriesTable ($categoryId)'
          '   ON DELETE RESTRICT,'
          ' FOREIGN KEY ($transBalanceId)'
          '   REFERENCES $balanceTable ($balanceId)'
          '   ON DELETE RESTRICT,'
          ' FOREIGN KEY ($transAccountId)'
          '   REFERENCES $accountTable ($accountId)'
          '   ON DELETE RESTRICT,'
          ' FOREIGN KEY ($transTransferId)'
          '   REFERENCES $transfersTable ($transferId)'
          '   ON DELETE RESTRICT'
          ')',
      'INSERT INTO ${transactionsTable}_new ($transId, $transBalanceId,'
          ' $transAccountId, $transDescription, $transCategoryId, $transValue, '
          ' $transStatus, $transTransferId, $transDate) '
          ' SELECT $transId, $transBalanceId, $transAccountId, $transDescription,'
          '   $transCategoryId, $transValue, $transStatus, $transTransferId,'
          '   $transDate FROM $transactionsTable',
      'DROP TABLE $transactionsTable',
      'ALTER TABLE ${transactionsTable}_new RENAME TO $transactionsTable',
      'COMMIT',
      'PRAGMA foreign_keys=on',
      'ALTER TABLE $balanceTable DROP COLUMN IF EXISTS balanceNextId',
      'ALTER TABLE $balanceTable DROP COLUMN IF EXISTS balancePreviousId',
      'DROP TRIGGER IF EXISTS $checkBalanceNextId',
      'DROP TRIGGER IF EXISTS $checkBalancePreviousId',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterInsertTransaction'
          'AFTER INSERT ON $transactionsTable'
          'FOR EACH ROW'
          'BEGIN'
          ' UPDATE $balanceTable'
          ' SET $balanceClose = $balanceClose + NEW.$transValue,'
          '   $balanceTransCount = IFNULL($balanceTransCount, 0) + 1'
          ' WHERE $balanceAccountId = NEW.$transAccountId'
          '   AND $balanceDate = NEW.$transDate;'
          'END',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterDeleteTransaction'
          'AFTER DELETE ON $transactionsTable'
          'FOR EACH ROW'
          'BEGIN'
          ' UPDATE $balanceTable'
          ' SET $balanceClose = $balanceClose - OLD.$transValue,'
          '   $balanceTransCount = IFNULL($balanceTransCount, 0) - 1'
          ' WHERE $balanceAccountId = OLD.$transAccountId'
          '   AND $balanceDate = OLD.$transDate;'
          'END',
      'ALTER TABLE $accountTable DROP COLUMN IF EXISTS accountLastBalance',
      'CREATE TABLE IF NOT EXISTS ${transfersTable}_new ('
          ' $transferId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $transferTransId0 INTEGER,'
          ' $transferTransId1 INTEGER,'
          ' $transferAccount0 INTEGER,'
          ' $transferAccount1 INTEGER,'
          ' FOREIGN KEY ($transferTransId0)'
          '   REFERENCES $transactionsTable ($transId)'
          ' FOREIGN KEY ($transferTransId1)'
          '   REFERENCES $transactionsTable ($transId)'
          ' FOREIGN KEY ($transferAccount0)'
          '   REFERENCES $accountTable ($accountId)'
          '   ON DELETE RESTRICT,'
          ' FOREIGN KEY $transferAccount1'
          '   REFERENCES $accountTable ($accountId)'
          '   ON DELETE RESTRICT'
          ')',
      'INSERT INTO ${transfersTable}_new'
          '  ($transferId, $transferTransId0, $transferTransId1,'
          '   $transferAccount0, $transferAccount1) '
          'SELECT $transferId, $transferTransId0, $transferTransId1,'
          '   $transferAccount0, $transferAccount1'
          '  FROM $transfersTable',
      'DROP TABLE $transfersTable',
      'ALTER TABLE ${transfersTable}_new RENAME TO $transfersTable',
      'DROP TABLE transDayTable',
    ],
  };
  // 'CREATE TRIGGER IF NOT EXISTS $triggerAfterUpdateTransaction'
  //     'AFTER UPDATE ON $transactionsTable'
  //     'FOR EACH ROW'
  //     'WHEN OLD.$transValue != NEW.$transValue'
  //     'BEGIN'
  //     '  UPDATE $balanceTable'
  //     '  SET $balanceClose = $balanceClose - OLD.$transValue + NEW.$transValue'
  //     '  WHERE $balanceAccountId = OLD.$transAccountId'
  //     '    AND $balanceDate = OLD.$transDate;'
  //     'END',

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
