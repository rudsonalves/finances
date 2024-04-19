import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../constants/constants.dart';

/// Manages database schema migrations for the application.
///
/// This class provides mechanisms to apply schema migrations to the SQLite database,
/// ensuring the database schema is up-to-date with the current version of the application.
/// It maintains a map of migration scripts organized by database version numbers.
class DatabaseMigrations {
  DatabaseMigrations._();

  /// Database Scheme Version declarations
  ///
  /// This is the database scheme current version. To futures upgrades
  /// in database increment this value and add a new update script in
  /// _migrationScripts Map.
  static const databaseSchemeVersion = 1011;

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
      'ALTER TABLE $categoriesTable ADD COLUMN $categoryBudget REAL DEFAULT 0'
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
      'BEGIN TRANSACTION',
      'DROP TRIGGER IF EXISTS $checkBalanceNextId',
      'DROP TRIGGER IF EXISTS $checkBalancePreviousId',
      'ALTER TABLE transactonsTable ADD COLUMN $transBalanceId INTEGER',
      'ALTER TABLE transactonsTable ADD COLUMN $transAccountId INTEGER',
      'UPDATE transactonsTable SET $transBalanceId = ('
          'SELECT transDayBalanceId FROM transDayTable '
          '  WHERE transDayTable.transDayTransId = transactonsTable.$transId'
          ')',
      'UPDATE transactonsTable SET $transAccountId = ('
          'SELECT $balanceAccountId FROM $balanceTable'
          '  WHERE $balanceTable.$balanceId = transactonsTable.$transBalanceId'
          ')',
      'CREATE TABLE IF NOT EXISTS $transactionsTable ('
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
      'INSERT INTO $transactionsTable ($transId, $transBalanceId,'
          ' $transAccountId, $transDescription, $transCategoryId, $transValue, '
          ' $transStatus, $transTransferId, $transDate) '
          ' SELECT $transId, $transBalanceId, $transAccountId, $transDescription,'
          '   $transCategoryId, $transValue, $transStatus, $transTransferId,'
          '   $transDate FROM transactonsTable',
      'CREATE TABLE IF NOT EXISTS ${balanceTable}_new ('
          ' $balanceId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $balanceAccountId INTEGER NOT NULL,'
          ' $balanceDate INTEGER NOT NULL,'
          ' $balanceTransCount INTEGER,'
          ' $balanceOpen REAL NOT NULL,'
          ' $balanceClose REAL NOT NULL,'
          ' FOREIGN KEY ($balanceAccountId)'
          '  REFERENCES $accountTable ($accountId)'
          '  ON DELETE RESTRICT'
          ')',
      'INSERT INTO ${balanceTable}_new'
          ' ($balanceId, $balanceAccountId, $balanceDate, $balanceTransCount, '
          ' $balanceOpen, $balanceClose) '
          ' SELECT $balanceId, $balanceAccountId, $balanceDate, $balanceTransCount, '
          ' $balanceOpen, $balanceClose FROM $balanceTable',
      'CREATE TABLE IF NOT EXISTS ${accountTable}_new ('
          ' $accountId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $accountName TEXT NOT NULL,'
          ' $accountDescription TEXT,'
          ' $accountUserId TEXT NOT NULL,'
          ' $accountIcon INTEGER,'
          ' FOREIGN KEY ($accountIcon)'
          '   REFERENCES $iconsTable ($iconId)'
          '   ON DELETE CASCADE,'
          ' FOREIGN KEY ($accountUserId)'
          '   REFERENCES $usersTable ($userId)'
          '   ON DELETE RESTRICT'
          ')',
      'INSERT INTO ${accountTable}_new '
          ' ($accountId, $accountName, $accountDescription, '
          ' $accountUserId, $accountIcon) '
          ' SELECT $accountId, $accountName, $accountDescription, '
          ' $accountUserId, $accountIcon FROM $accountTable',
      'CREATE TABLE IF NOT EXISTS ${transfersTable}_new ('
          ' $transferId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $transferTransId0 INTEGER,'
          ' $transferTransId1 INTEGER,'
          ' $transferAccount0 INTEGER,'
          ' $transferAccount1 INTEGER,'
          ' FOREIGN KEY ($transferTransId0)'
          '   REFERENCES $transactionsTable ($transId),'
          ' FOREIGN KEY ($transferTransId1)'
          '   REFERENCES $transactionsTable ($transId),'
          ' FOREIGN KEY ($transferAccount0)'
          '   REFERENCES $accountTable ($accountId)'
          '   ON DELETE RESTRICT,'
          ' FOREIGN KEY ($transferAccount1)'
          '   REFERENCES $accountTable ($accountId)'
          '   ON DELETE RESTRICT'
          ')',
      'INSERT INTO ${transfersTable}_new'
          '  ($transferId, $transferTransId0, $transferTransId1,'
          '   $transferAccount0, $transferAccount1) '
          'SELECT $transferId, $transferTransId0, $transferTransId1,'
          '   $transferAccount0, $transferAccount1'
          '  FROM $transfersTable',
      'DROP TABLE transDayTable',
      'DROP TABLE $balanceTable',
      'DROP TABLE $transfersTable',
      'DROP TABLE transactonsTable',
      'DROP TABLE $accountTable',
      'ALTER TABLE ${balanceTable}_new RENAME TO $balanceTable',
      'ALTER TABLE ${transfersTable}_new RENAME TO $transfersTable',
      'ALTER TABLE ${accountTable}_new RENAME TO $accountTable',
      'CREATE INDEX IF NOT EXISTS $accountUserIndex'
          ' ON $accountTable ($accountUserId)',
      'CREATE INDEX IF NOT EXISTS $balanceAccountIndex'
          ' ON $balanceTable ($balanceAccountId)',
      'CREATE INDEX IF NOT EXISTS $balanceDateIndex'
          ' ON $balanceTable ($balanceDate)',
      'CREATE INDEX IF NOT EXISTS $categoriesNameIndex'
          ' ON $categoriesTable ($categoryName)',
      'CREATE INDEX IF NOT EXISTS $transactionsDateIndex'
          ' ON $transactionsTable ($transDate)',
      'CREATE INDEX IF NOT EXISTS $transactionsCategoryIndex'
          ' ON $transactionsTable ($transCategoryId)',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterInsertTransaction'
          ' AFTER INSERT ON $transactionsTable'
          ' FOR EACH ROW'
          ' BEGIN'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose + NEW.$transValue,'
          '       $balanceTransCount = IFNULL($balanceTransCount, 0) + 1'
          '   WHERE $balanceId = NEW.$transBalanceId;'
          ' END',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterDeleteTransaction'
          ' AFTER DELETE ON $transactionsTable'
          ' FOR EACH ROW'
          ' BEGIN'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose - OLD.$transValue,'
          '       $balanceTransCount = IFNULL($balanceTransCount, 0) - 1'
          '   WHERE $balanceId = OLD.$transBalanceId;'
          ' END',
      'COMMIT',
    ],
    1009: [
      'BEGIN TRANSACTION',
      'CREATE TABLE IF NOT EXISTS $ofxACCTable ('
          ' $ofxACCId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $ofxACCAccountId INTEGER NOT NULL,'
          ' $ofxACCBankAccountId TEXT NOT NULL,'
          ' $ofxACCBankName TEXT,'
          ' $ofxACCType TEXT NOT NULL,'
          ' $ofxACCNTrans INTEGER NOT NULL,'
          ' $ofxACCStartDate INTEGER NOT NULL,'
          ' $ofxACCEndDate INTEGER NOT NULL,'
          ' FOREIGN KEY ($ofxACCAccountId)'
          '   REFERENCES $accountTable ($accountId),'
          ' FOREIGN KEY ($ofxACCBankAccountId)'
          '   REFERENCES $ofxRelationshipTable ($ofxRelBankAccountId)'
          ')',
      'CREATE INDEX IF NOT EXISTS $ofxAccountBankIndex'
          ' ON $ofxACCTable ($ofxACCStartDate)',
      'CREATE TABLE IF NOT EXISTS $ofxRelationshipTable ('
          ' $ofxRelId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $ofxRelBankAccountId TEXT UNIQUE NOT NULL,'
          ' $ofxRelAccountId INTEGER NOT NULL,'
          ' $ofxRelBankName TEXT,'
          ' FOREIGN KEY ($ofxRelAccountId)'
          '   REFERENCES $accountTable ($accountId)'
          ')',
      'CREATE INDEX IF NOT EXISTS $ofxRelaltionshipIndex'
          ' ON $ofxRelationshipTable ($ofxRelBankAccountId)',
      'CREATE TABLE IF NOT EXISTS $ofxTransTemplateTable ('
          ' $ofxTransId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $ofxTransMemo TEXT NOT NULL,'
          ' $ofxTransAccountId INTEGER NOT NULL,'
          ' $ofxTransCategoryId INTEGER NOT NULL,'
          ' $ofxTransDescription TEXT,'
          ' $ofxTransTransferAccountId INTEGER,'
          ' FOREIGN KEY ($ofxTransAccountId)'
          '   REFERENCES $accountTable ($accountId),'
          ' FOREIGN KEY ($ofxTransCategoryId)'
          '   REFERENCES $categoriesTable ($categoryId),'
          ' FOREIGN KEY ($ofxTransTransferAccountId)'
          '   REFERENCES $accountTable ($accountId)'
          ')',
      'CREATE INDEX IF NOT EXISTS $ofxTransMemoIndex'
          ' ON $ofxTransTemplateTable ($ofxTransMemo)',
      'CREATE INDEX IF NOT EXISTS $ofxTransAccountIndex'
          ' ON $ofxTransTemplateTable ($ofxTransAccountId)',
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
          ' $transOfxId INTEGER,'
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
          '   ON DELETE RESTRICT,'
          ' FOREIGN KEY ($transOfxId)'
          '   REFERENCES $ofxACCTable ($ofxACCId)'
          ')',
      'INSERT INTO ${transactionsTable}_new ($transId, $transBalanceId,'
          ' $transAccountId, $transDescription, $transCategoryId, $transValue, '
          ' $transStatus, $transTransferId, $transDate) '
          ' SELECT $transId, $transBalanceId, $transAccountId, $transDescription,'
          '   $transCategoryId, $transValue, $transStatus, $transTransferId,'
          '   $transDate FROM $transactionsTable',
      'DROP TABLE $transactionsTable',
      'ALTER TABLE ${transactionsTable}_new RENAME TO $transactionsTable',
      'CREATE INDEX IF NOT EXISTS $transactionsDateIndex'
          ' ON $transactionsTable ($transDate)',
      'CREATE INDEX IF NOT EXISTS $transactionsCategoryIndex'
          ' ON $transactionsTable ($transCategoryId)',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterInsertTransaction'
          ' AFTER INSERT ON $transactionsTable'
          ' FOR EACH ROW'
          ' BEGIN'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose + NEW.$transValue,'
          '       $balanceTransCount = IFNULL($balanceTransCount, 0) + 1'
          '   WHERE $balanceId = NEW.$transBalanceId;'
          ' END',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterDeleteTransaction'
          ' AFTER DELETE ON $transactionsTable'
          ' FOR EACH ROW'
          ' BEGIN'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose - OLD.$transValue,'
          '       $balanceTransCount = IFNULL($balanceTransCount, 0) - 1'
          '   WHERE $balanceId = OLD.$transBalanceId;'
          ' END',
      'COMMIT',
    ],
    1010: [
      'BEGIN TRANSACTION',
      'DROP TRIGGER IF EXISTS $triggerAfterInsertTransaction',
      'DROP TRIGGER IF EXISTS $triggerAfterDeleteTransaction',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterInsertTransaction'
          ' AFTER INSERT ON $transactionsTable'
          ' FOR EACH ROW'
          ' BEGIN'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose + NEW.$transValue,'
          '       $balanceTransCount = IFNULL($balanceTransCount, 0) + 1'
          '   WHERE $balanceId = NEW.$transBalanceId;'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose + NEW.$transValue,'
          '       $balanceOpen = $balanceOpen + NEW.$transValue'
          '   WHERE $balanceDate > NEW.$transDate'
          '     AND $balanceAccountId = NEW.$transAccountId;'
          ' END',
      'CREATE TRIGGER IF NOT EXISTS $triggerAfterDeleteTransaction'
          ' AFTER DELETE ON $transactionsTable'
          ' FOR EACH ROW'
          ' BEGIN'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose - OLD.$transValue,'
          '       $balanceTransCount = IFNULL($balanceTransCount, 0) - 1'
          '   WHERE $balanceId = OLD.$transBalanceId;'
          '   UPDATE $balanceTable'
          '   SET $balanceClose = $balanceClose - OLD.$transValue,'
          '       $balanceOpen = $balanceOpen - OLD.$transValue'
          '   WHERE $balanceDate > OLD.$transDate'
          '     AND $balanceAccountId = OLD.$transAccountId;'
          ' END',
      'COMMIT',
    ],
    1011: [
      'ALTER TABLE $usersTable'
          ' ADD COLUMN $userOfxStopCategories TEXT DEFAULT "[1]"',
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
  static Future<void> applyMigrations({
    required Database db,
    required int currentVersion,
    required int targetVersion,
  }) async {
    await db.execute('PRAGMA foreign_keys=off');
    for (var version = currentVersion + 1;
        version <= targetVersion;
        version++) {
      log('Database migrating to version: $version');
      final batch = db.batch();
      final scripts = migrationScripts[version];
      if (scripts != null) {
        for (final script in scripts) {
          batch.execute(script);
        }
      }
      await batch.commit(noResult: true);

      if (version == 1008) {
        // Remove empty balances
        await db.delete(
          balanceTable,
          where: '$balanceTransCount = ?',
          whereArgs: [0],
        );
      }
    }
    await db.execute('PRAGMA foreign_keys=on');
  }
}
