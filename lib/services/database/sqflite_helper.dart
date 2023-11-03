import 'dart:developer';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/models/category_db_model.dart';
import '../../common/models/transfer_db_model.dart';
import './database_helper.dart';
import '../../common/models/balance_db_model.dart';
import '../../common/models/trans_day_db_model.dart';
import '../../common/models/transaction_db_model.dart';

class SqfliteHelper implements DatabaseHelper {
  static const _dbName = 'app_dataBase.db';
  static const _dbVersion = 1;

  static const versionControlTable = 'versionControl';
  static const versionControlId = 'id';
  static const versionControlVersion = 'version';

  static const usersTable = 'usersTable';
  static const userId = 'userId';
  static const userName = 'userName';
  static const userEmail = 'userEmail';
  static const userLogged = 'userLogged';
  static const userMainAccountId = 'userMainAccountId';
  static const userTheme = 'userTheme';
  static const userLanguage = 'userLanguage';
  static const userGrpShowGrid = 'userGrpShowGrid';
  static const userGrpIsCurved = 'userGrpIsCurved';
  static const userGrpShowDots = 'userGrpShowDots';
  static const userGrpAreaChart = 'userGrpAreaChart';
  static const userBudgetRef = 'userBudgetRef';
  static const userCategoryList = 'userCategoryList';

  static const iconsTable = 'iconsTable';
  static const iconsNameIndex = 'idxIconsName';
  static const iconId = 'iconId';
  static const iconName = 'iconName';
  static const iconFontFamily = 'iconFontFamily';
  static const iconColor = 'iconColor';

  static const accountTable = 'accountTable';
  static const accountUserIndex = 'idxAccountUserId';
  static const accountId = 'accountId';
  static const accountName = 'accountName';
  static const accountDescription = 'accountDescription';
  static const accountUserId = 'accountUserId';
  static const accountIcon = 'accountIcon';
  static const accountLastBalance = 'accountLastBalance';

  static const balanceTable = 'balanceTable';
  static const balanceDateIndex = 'idxBalanceDate';
  static const checkBalancePreviousId = 'checkBalancePreviousId';
  static const checkBalanceNextId = 'checkBalanceNextId';
  static const balanceAccountIndex = 'idxBalanceAccount';
  static const balanceId = 'balanceId';
  static const balanceAccountId = 'balanceAccountId';
  static const balanceDate = 'balanceDate';
  static const balanceNextId = 'balanceNextId';
  static const balancePreviousId = 'balancePreviousId';
  static const balanceTransCount = 'balanceTransCount';
  static const balanceOpen = 'balanceOpen';
  static const balanceClose = 'balanceClose';

  static const transDayTable = 'transDayTable';
  static const transDayBalanceId = 'transDayBalanceId';
  static const transDayTransId = 'transDayTransId';

  static const categoriesTable = 'categoriesTable';
  static const categoriesNameIndex = 'idxCategoriesName';
  static const categoryId = 'categoryId';
  static const categoryName = 'categoryName';
  static const categoryIcon = 'categoryIcon';
  static const categoryBudget = 'categoryBudget';
  static const categoryIsIncome = 'categoryIsIncome';

  static const transactionsTable = 'transactonsTable';
  static const transactionsDateIndex = 'idxTransactionsDate';
  static const transactionsCategoryIndex = 'idxTransactionsCategory';
  static const transId = 'transId';
  static const transDescription = 'transDescription';
  static const transCategoryId = 'transCategoryId';
  static const transValue = 'transValue';
  static const transStatus = 'transStatus';
  static const transTransferId = 'transTransferId';
  static const transDate = 'transDate';

  static const transfersTable = 'transfersTable';
  static const transferId = 'transferId';
  static const transferTransId0 = 'transferTransId0';
  static const transferTransId1 = 'transferTransId1';
  static const transferAccount0 = 'transferAccount0';
  static const transferAccount1 = 'transferAccount1';

  /*
   Database Scheme Version declarations
   
   This is the database scheme current version. To futures upgrades
   in database increment this value and add a new update script in
   _migrationScripts Map.
  */
  static const _databaseSchemeVersion = 1005;

  // This Map contains the database migration scripts. The last index of this
  // Map must be equal to the current version of the database.
  static const Map<int, List<String>> _migrationScripts = {
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
  };

  @override
  String get dbSchemeVersion {
    String version = _databaseSchemeVersion.toString();
    int length = version.length;
    return '${version.substring(0, length - 3)}.'
        '${version.substring(length - 3, length - 2)}.'
        '${version.substring(length - 2)}';
  }

  late Database _db;

  @override
  Database get db => _db;

  @override
  Future<void> init() async {
    try {
      await _openDatabase();
    } catch (err) {
      log('Error: $err');
    }
  }

  Future<void> _openDatabase() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, _dbName);

    // Only to reset database
    // databaseFactory.deleteDatabase(path);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfiguration,
    );

    int currentVersion = await _getCurrentDatabaseSchemeVersion();
    if (_databaseSchemeVersion > currentVersion) {
      await backupDatabase();
      Batch batch = _db.batch();
      _applyMigrations(
        batch: batch,
        currentVersion: currentVersion,
        targetVersion: _databaseSchemeVersion,
      );
      await batch.commit();
      await _updateMigration(_databaseSchemeVersion);

      await _db.close();
      _db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onConfigure: _onConfiguration,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      Batch batch = db.batch();
      // Tables
      _createVersionControlTable(batch);
      _createUsersTable(batch);
      _createIconsTable(batch);
      _createAccountsTable(batch);
      _createBalanceTable(batch);
      _createCategoryTable(batch);
      _createTransactionsTable(batch);
      _createTransDayTable(batch);
      _createTransfersTable(batch);
      _createTriggers(batch);
      await batch.commit();
    } catch (err) {
      log('Error: $err');
    }
  }

  Future<void> _onConfiguration(Database db) async {
    // Add support for cascade delete
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /* 
  * Create Tables
  */
  void _createVersionControlTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $versionControlTable ('
      ' $versionControlId INTEGER PRIMARY KEY,'
      ' $versionControlVersion INTEGER NOT NULL'
      ')',
    );
  }

  void _createUsersTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $usersTable ('
      ' $userId TEXT PRIMARY KEY NOT NULL,'
      ' $userName TEXT NOT NULL,'
      ' $userEmail TEXT UNIQUE NOT NULL,'
      ' $userLogged INTEGER NOT NULL,'
      ' $userMainAccountId INTEGER,'
      ' $userTheme TEXT NOT NULL,'
      ' $userLanguage TEXT NOT NULL,'
      ' $userGrpShowGrid INTEGER DEFAULT 1,'
      ' $userGrpIsCurved INTEGER DEFAULT 0,'
      ' $userGrpShowDots INTEGER DEFAULT 0,'
      ' $userGrpAreaChart INTEGER DEFAULT 0,'
      ' $userBudgetRef INTEGER DEFAULT 2,'
      ' $userCategoryList TEXT DEFAULT "[]",'
      ' FOREIGN KEY ($userMainAccountId)'
      '  REFERENCES $accountTable ($accountId)'
      '  ON DELETE CASCADE'
      ')',
    );
  }

  void _createIconsTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $iconsTable ('
      ' $iconId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      ' $iconName TEXT NOT NULL,'
      ' $iconFontFamily TEXT NOT NULL,'
      ' $iconColor INTEGER NOT NULL'
      ')',
    );
  }

  void _createAccountsTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $accountTable ('
      ' $accountId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      ' $accountName TEXT NOT NULL,'
      ' $accountDescription TEXT,'
      ' $accountUserId TEXT NOT NULL,'
      ' $accountIcon INTEGER,'
      ' $accountLastBalance INTEGER,'
      ' FOREIGN KEY ($accountIcon)'
      '  REFERENCES $iconsTable ($iconId)'
      '  ON DELETE CASCADE,'
      ' FOREIGN KEY ($accountUserId)'
      '  REFERENCES $usersTable ($userId)'
      '  ON DELETE RESTRICT'
      ')',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS $accountUserIndex '
      'ON $accountTable ($accountUserId)',
    );
  }

  void _createBalanceTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $balanceTable ('
      ' $balanceId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      ' $balanceAccountId INTEGER NOT NULL,'
      ' $balanceDate INTEGER NOT NULL,'
      ' $balanceNextId INTEGER,'
      ' $balancePreviousId INTEGER,'
      ' $balanceTransCount INTEGER,'
      ' $balanceOpen REAL NOT NULL,'
      ' $balanceClose REAL NOT NULL,'
      ' FOREIGN KEY ($balanceAccountId)'
      '  REFERENCES $accountTable ($accountId)'
      '  ON DELETE RESTRICT'
      ')',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS $balanceDateIndex'
      ' ON $balanceTable ($balanceDate)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS $balanceAccountIndex'
      ' ON $balanceTable ($balanceAccountId)',
    );
  }

  void _createCategoryTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $categoriesTable ('
      ' $categoryId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      ' $categoryName TEXT UNIQUE NOT NULL,'
      ' $categoryIcon INTEGER NOT NULL,'
      ' $categoryBudget REAL DEFAULT 0,'
      ' $categoryIsIncome INTEGER DEFAULT 0,'
      ' FOREIGN KEY ($categoryIcon)'
      '  REFERENCES $iconsTable ($iconId)'
      '  ON DELETE CASCADE'
      ')',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS $categoriesNameIndex'
      ' ON $categoriesTable ($categoryName)',
    );
  }

  void _createTransactionsTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $transactionsTable ('
      ' $transId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      ' $transDescription TEXT NOT NULL,'
      ' $transCategoryId INTEGER NOT NULL,'
      ' $transValue REAL NOT NULL,'
      ' $transStatus INTEGER NOT NULL,'
      ' $transTransferId INTEGER,'
      ' $transDate INTEGER NOT NULL,'
      ' FOREIGN KEY ($transCategoryId)'
      '  REFERENCES $categoriesTable ($categoryId)'
      '  ON DELETE RESTRICT'
      ')',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS $transactionsDateIndex'
      ' ON $transactionsTable ($transDate)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS $transactionsCategoryIndex'
      ' ON $transactionsTable ($transCategoryId)',
    );
  }

  void _createTransDayTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $transDayTable ('
      ' $transDayTransId INTEGER PRIMARY KEY NOT NULL,'
      ' $transDayBalanceId INTEGER NOT NULL,'
      ' FOREIGN KEY ($transDayBalanceId)'
      '  REFERENCES $balanceTable ($balanceId)'
      '  ON DELETE RESTRICT,'
      ' FOREIGN KEY ($transDayTransId)'
      '  REFERENCES $transactionsTable ($transId)'
      '  ON DELETE CASCADE'
      ')',
    );
  }

  void _createTransfersTable(Batch batch) {
    batch.execute(
      'CREATE TABLE IF NOT EXISTS $transfersTable ('
      ' $transferId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      ' $transferTransId0 INTEGER NOT NULL,'
      ' $transferTransId1 INTEGER NOT NULL,'
      ' $transferAccount0 INTEGER NOT NULL,'
      ' $transferAccount1 INTEGER NOT NULL,'
      ' FOREIGN KEY ($transferTransId0)'
      '  REFERENCES $transactionsTable ($transId)'
      '  ON DELETE RESTRICT,'
      ' FOREIGN KEY ($transferTransId1)'
      '  REFERENCES $transactionsTable ($transId)'
      '  ON DELETE RESTRICT,'
      ' FOREIGN KEY ($transferAccount0)'
      '  REFERENCES $accountTable ($accountId)'
      '  ON DELETE RESTRICT,'
      ' FOREIGN KEY ($transferAccount1)'
      '  REFERENCES $accountTable ($accountId)'
      '  ON DELETE RESTRICT'
      ')',
    );
  }

  void _createTriggers(Batch batch) {
    // Create a trigger to check referential integrity and
    // limit balanceNextId to balanceId
    batch.execute(
      'CREATE TRIGGER IF NOT EXISTS $checkBalanceNextId'
      ' BEFORE INSERT ON $balanceTable'
      ' FOR EACH ROW'
      ' BEGIN'
      '   SELECT CASE'
      '     WHEN NEW.$balanceNextId IS NOT NULL THEN'
      '       CASE WHEN EXISTS(SELECT 1 FROM $balanceTable'
      '       WHERE $balanceId = NEW.$balanceNextId) THEN'
      '       1 ELSE RAISE(ABORT, \'Invalid $balanceNextId\') END'
      '     ELSE 1'
      '   END;'
      ' END;',
    );

    // Create a trigger to check referential integrity and
    // limit balancePreviousId to balanceId
    batch.execute(
      'CREATE TRIGGER IF NOT EXISTS $checkBalancePreviousId'
      ' BEFORE INSERT ON $balanceTable'
      ' FOR EACH ROW'
      ' BEGIN'
      '   SELECT CASE'
      '     WHEN NEW.$balancePreviousId IS NOT NULL THEN'
      '       CASE WHEN EXISTS(SELECT 1 FROM $balanceTable'
      '       WHERE $balanceId = NEW.$balancePreviousId) THEN'
      '       1 ELSE RAISE(ABORT, \'Invalid $balancePreviousId\') END'
      '     ELSE 1'
      '   END;'
      ' END;',
    );
  }

  /* 
  * Migrations
  */
  // This function applies the database migration scripts
  void _applyMigrations({
    required Batch batch,
    required int currentVersion,
    required int targetVersion,
  }) {
    for (var version = currentVersion + 1;
        version <= targetVersion;
        version++) {
      final scripts = _migrationScripts[version];
      if (scripts != null) {
        for (final script in scripts) {
          batch.execute(script);
        }
      }
    }
  }

  // Record an applied migration in the versionControl table
  Future<void> _recordMigration(int targetVersion) async {
    _db.insert(
      versionControlTable,
      {
        versionControlId: 1,
        versionControlVersion: targetVersion,
      },
    );
  }

  // Record an applied migration in the versionControl table
  Future<void> _updateMigration(int targetVersion) async {
    _db.update(
      versionControlTable,
      {
        versionControlId: 1,
        versionControlVersion: targetVersion,
      },
    );
  }

  @override
  Future<String?> backupDatabase([String? destinyDir]) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String dbPath = join(directory.path, _dbName);
      final strDate = DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now());

      String dbBackupPath;
      if (destinyDir == null) {
        dbBackupPath = join(directory.path, '${_dbName}_bkp');
      } else {
        dbBackupPath = join(destinyDir, '${_dbName}_bkp_$strDate');
      }

      final dbBackupFile = File(dbBackupPath);
      if (await dbBackupFile.exists()) {
        await dbBackupFile.delete();
      }

      final File dbFile = File(dbPath);
      await dbFile.copy(dbBackupPath);

      return dbBackupPath;
    } catch (err) {
      log('Error backupDatabase: ${err.toString()}');
      return null;
    }
  }

  @override
  Future<bool> restoreDatabase(String newDbPath) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String originalPath = join(directory.path, _dbName);
    final backupPath = join(directory.path, '$_dbName.bkp');

    try {
      final File backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      final File originalFile = File(originalPath);
      await originalFile.copy(backupPath);

      await _db.close();

      if (await originalFile.exists()) {
        await originalFile.delete();
      }

      await File(newDbPath).copy(originalPath);
      await _openDatabase();

      await backupFile.delete();

      return true;
    } catch (err) {
      log('Error backupDatabase: ${err.toString()}');
      final File backupFile = File(backupPath);
      if (await backupFile.exists()) {
        if (_db.isOpen) _db.close();
        await backupFile.copy(originalPath);
        await _openDatabase();
        await backupFile.delete();
      }
      return false;
    }
  }

  Future<int> _getCurrentDatabaseSchemeVersion() async {
    final List<Map<String, dynamic>> results = await _db.query(
      versionControlTable,
      where: '$versionControlId = 1',
    );

    if (results.isEmpty) {
      await _recordMigration(_databaseSchemeVersion);
      return _databaseSchemeVersion;
    }

    return results.first[versionControlVersion] as int;
  }

  /*
  * Drop Tables
  */
  @override
  Future<void> restartTables() async {
    if (!_db.isOpen) await _openDatabase();
    try {
      await _dropTables();
      await _onCreate(_db, _dbVersion);
    } catch (err) {
      log('Error: $err');
    }
  }

  @override
  Future<void> restartTestTables() async {
    if (!_db.isOpen) await _openDatabase();
    try {
      Batch batch = _db.batch();

      _dropTransDayTable(batch);
      _dropTransactionsTable(batch);
      _dropTransfersTable(batch);
      // _dropCategoryTabe(batch);
      _dropBalanceTable(batch);
      _dropAccountTable(batch);
      // _dropUsersTable(batch);
      await batch.commit();
      await _onCreate(_db, _dbVersion);
    } catch (err) {
      log('Error: $err');
    }
  }

  Future<void> _dropTables() async {
    try {
      Batch batch = _db.batch();

      _dropTransDayTable(batch);
      _dropTransactionsTable(batch);
      _dropTransfersTable(batch);
      _dropCategoryTabe(batch);
      _dropBalanceTable(batch);
      _dropAccountTable(batch);
      _dropIconsTable(batch);
      _dropUsersTable(batch);

      await batch.commit();
    } catch (err) {
      log('Error: $err');
    }
  }

  void _dropUsersTable(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $usersTable');
  }

  void _dropIconsTable(Batch batch) {
    batch.execute('DROP INDEX IF EXISTS $iconsNameIndex');
    // batch.execute('DROP TABLE IF EXISTS $iconsTable');
  }

  void _dropAccountTable(Batch batch) {
    batch.execute('DROP INDEX IF EXISTS $accountUserIndex');
    batch.execute('DROP TABLE IF EXISTS $accountTable');
  }

  void _dropBalanceTable(Batch batch) {
    batch.execute('DROP INDEX IF EXISTS $balanceDateIndex');
    batch.execute('DROP INDEX IF EXISTS $balanceAccountIndex');
    batch.execute('DROP TABLE IF EXISTS $balanceTable');
  }

  void _dropCategoryTabe(Batch batch) {
    batch.execute('DROP INDEX IF EXISTS $categoriesNameIndex');
    batch.execute('DROP TABLE IF EXISTS $categoriesTable');
  }

  void _dropTransactionsTable(Batch batch) {
    batch.execute('DROP INDEX IF EXISTS $transactionsDateIndex');
    batch.execute('DROP TABLE IF EXISTS $transactionsTable');
  }

  void _dropTransDayTable(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $transDayTable');
  }

  void _dropTransfersTable(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $transfersTable');
  }

  /*
  * Others methods
  */
  @override
  Future<void> logSchema() async {
    // Obtém as tabelas do banco de dados
    List<Map<String, dynamic>> tables = await _db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );

    // Para cada tabela, obtém as colunas
    for (Map<String, dynamic> table in tables) {
      String tableName = table['name'];
      List<Map<String, dynamic>> columns = await _db.rawQuery(
        "PRAGMA table_info($tableName);",
      );

      // Imprime as colunas da tabela
      log('Table: $tableName');
      for (Map<String, dynamic> column in columns) {
        String columnName = column['name'];
        String columnType = column['type'];
        log(' - $columnName: $columnType');
      }
      log('\n');
    }
  }

  @override
  Future<void> logTables() async {
    // await logBalances();
    await logTransactions();
    await logTransDay();
    await logTransfers();
    await logCategories();
  }

  @override
  Future<void> logBalances() async {
    if (!_db.isOpen) await _openDatabase();
    String strOut = 'Balance Table:\n';
    List<Map<String, Object?>> maps = await _db.query(
      balanceTable,
      orderBy: balanceAccountId,
    );
    for (var map in maps) {
      strOut += '${BalanceDbModel.fromMap(map)}\n';
    }
    log(strOut);
  }

  @override
  Future<void> logTransactions() async {
    if (!_db.isOpen) await _openDatabase();
    String strOut = 'Transactions Table:\n';
    List<Map<String, Object?>> maps = await _db.query(
      transactionsTable,
      orderBy: transDate,
    );
    for (var map in maps) {
      strOut += '${TransactionDbModel.fromMap(map)}\n';
    }
    log(strOut);
  }

  @override
  Future<void> logTransDay() async {
    if (!_db.isOpen) await _openDatabase();
    String strOut = 'TransDay Table:\n';
    List<Map<String, Object?>> maps = await _db.query(
      transDayTable,
      orderBy: transDayBalanceId,
    );
    for (var map in maps) {
      strOut += '${TransDayDbModel.fromMap(map)}\n';
    }
    log(strOut);
  }

  @override
  Future<void> logTransfers() async {
    if (!_db.isOpen) await _openDatabase();
    String strOut = 'Transfer Table:\n';
    List<Map<String, Object?>> maps = await _db.query(
      transfersTable,
    );
    for (var map in maps) {
      strOut += '${TransferDbModel.fromMap(map)}\n';
    }
    log(strOut);
  }

  @override
  Future<void> logCategories() async {
    if (!_db.isOpen) await _openDatabase();
    String strOut = 'Categories Table:\n';
    List<Map<String, Object?>> maps = await _db.query(
      categoriesTable,
    );
    for (var map in maps) {
      strOut += '${await CategoryDbModel.fromMap(map)}\n';
    }
    log(strOut);
  }

  /* 
  * Helper methods
  *
  * Users Methods
  */
  @override
  Future<int> insertUser(Map<String, dynamic> userMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
        usersTable,
        userMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<Map<String, Object?>?> queryUserId(String id) async {
    try {
      final List<Map<String, Object?>> result = await _db.query(
        usersTable,
        where: '$userId = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;

      return result.first;
    } catch (err) {
      log('Error: $err');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, dynamic>> result = await _db.query(usersTable);
      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  @override
  Future<int> updateUser(Map<String, dynamic> userMap) async {
    try {
      String id = userMap[userId];
      int result = await _db.update(
        usersTable,
        userMap,
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateUserBudgetRef(String id, int budgetRef) async {
    try {
      int result = await _db.update(
        usersTable,
        {userBudgetRef: budgetRef},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateUserGrpShowGrid(String id, int grpShowGrid) async {
    try {
      int result = await _db.update(
        usersTable,
        {userGrpShowGrid: grpShowGrid},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateUserGrpShowDots(String id, int grpShowDots) async {
    try {
      int result = await _db.update(
        usersTable,
        {userGrpShowDots: grpShowDots},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateUserGrpIsCurved(String id, int grpIsCurved) async {
    try {
      int result = await _db.update(
        usersTable,
        {userGrpIsCurved: grpIsCurved},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateUserGrpAreaChart(String id, int grpAreaChart) async {
    try {
      int result = await _db.update(
        usersTable,
        {userGrpAreaChart: grpAreaChart},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateUserLanguage(String id, String language) async {
    try {
      int result = await _db.update(
        usersTable,
        {userLanguage: language},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateUserTheme(String id, String theme) async {
    try {
      int result = await _db.update(
        usersTable,
        {userTheme: theme},
        where: '$userId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /*
   Icons Methods 
  */
  @override
  Future<int> insertIcon(Map<String, dynamic> iconMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
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
    if (!_db.isOpen) await _openDatabase();
    try {
      int id = iconMap[iconId];
      int result = await _db.update(
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
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, dynamic>> result = await _db.query(
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
    if (!_db.isOpen) await _openDatabase();
    try {
      await _db.delete(
        iconsTable,
        where: '$iconId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /*
  * Accounts Methods 
  */
  @override
  Future<int> insertAccount(Map<String, dynamic> accountMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
        accountTable,
        accountMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryUserAccounts(String userId) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, dynamic>> result = await _db.query(
        accountTable,
        where: '$accountUserId = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  @override
  Future<void> deleteAccountId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      await _db.delete(
        accountTable,
        where: '$accountId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  @override
  Future<void> updateAccount(Map<String, dynamic> accountMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int id = accountMap[accountId];
      await _db.update(
        accountTable,
        accountMap,
        where: '$accountId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  @override
  Future<void> deleteTransactionsByAccountId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      await _db.delete(
        transDayTable,
        where: '$transDayBalanceId IN ('
            ' SELECT $balanceId FROM $balanceTable WHERE $balanceAccountId = ?'
            ')',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  @override
  Future<void> deleteBalancesByAccountId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      await _db.delete(
        balanceTable,
        where: '$balanceAccountId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /*
  * Categories Methods 
  */
  @override
  Future<int> insertCategory(Map<String, dynamic> categoryMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
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
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, dynamic>> result = await _db.query(
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
    if (!_db.isOpen) await _openDatabase();
    try {
      int id = categoryMap[categoryId];
      await _db.update(
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
    if (!_db.isOpen) await _openDatabase();
    try {
      await _db.update(
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
    if (!_db.isOpen) await _openDatabase();
    try {
      await _db.delete(
        categoriesTable,
        where: '$categoryId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /*
  * Balance Methods
  */
  @override
  Future<int> insertBalance(Map<String, dynamic> balanceMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
        balanceTable,
        balanceMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<Map<String, dynamic>?> queryBalanceId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      var result = await _db.query(
        balanceTable,
        where: '$balanceId = ?',
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
  Future<Map<String, dynamic>?> queryBalanceDate({
    required int account,
    required int date,
  }) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      var result = await _db.query(
        balanceTable,
        where: '$balanceAccountId = ? AND $balanceDate = ?',
        whereArgs: [account, date],
      );
      if (result.isEmpty) return null;
      return result[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }

  @override
  Future<void> updateBalance(Map<String, dynamic> balanceMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int id = balanceMap[balanceId];
      await _db.update(
        balanceTable,
        balanceMap,
        where: '$balanceId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  @override
  Future<void> deleteBalance(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      await _db.delete(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: [id],
      );
    } catch (err) {
      log('Error: $err');
    }
  }

  /*
  * Transaction Methods
  */
  @override
  Future<int> insertTransaction(Map<String, dynamic> transactionMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
        transactionsTable,
        transactionMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateTransaction(Map<String, dynamic> transMap) async {
    try {
      int id = transMap[transId];
      int result = await _db.update(
        transactionsTable,
        transMap,
        where: '$transId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> updateTransactionStatus(int id, int newStatus) async {
    try {
      int result = await _db.update(
        transactionsTable,
        {transStatus: newStatus},
        where: '$transId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> deleteTransactionId(int id) async {
    try {
      int result = await _db.delete(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<Map<String, Object?>?> queryTransactionAtId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      final List<Map<String, Object?>> result = await _db.query(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;

      return result.first;
    } catch (err) {
      log('Error: $err');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> rawQueryTransForBalanceId(
    int id,
  ) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, dynamic>> result = await _db.rawQuery(
        'SELECT t.*'
        ' FROM $balanceTable b'
        ' JOIN $transDayTable td ON b.$balanceId = td.$transDayBalanceId'
        ' JOIN $transactionsTable t ON td.$transDayTransId = t.$transId'
        ' WHERE b.$balanceId = ?'
        ' ORDER BY t.transDate DESC',
        [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return [];
    }
  }

  @override
  Future<double> getIncomeBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  }) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, Object?>> result = await _db.rawQuery(
        'SELECT SUM($transValue) AS totalIncomes'
        ' FROM $transactionsTable'
        ' WHERE $transDate BETWEEN $startDate AND $endDate'
        '   AND $transValue > 0'
        '   AND $transId IN ('
        '     SELECT $transDayTransId'
        '     FROM $transDayTable'
        '     WHERE $transDayBalanceId IN ('
        '       SELECT $balanceId'
        '       FROM $balanceTable'
        '       WHERE $balanceAccountId = $accountId'
        '     )'
        '   )',
      );
      double totalEntries = (result.first['totalIncomes'] ?? 0.0) as double;
      return totalEntries;
    } catch (err) {
      log('Error: $err');
      return 0.0;
    }
  }

  @override
  Future<double> getExpenseBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  }) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, Object?>> result = await _db.rawQuery(
        'SELECT SUM($transValue) AS totalExpenses'
        ' FROM $transactionsTable'
        ' WHERE $transDate BETWEEN $startDate AND $endDate'
        '   AND $transValue < 0'
        '   AND $transId IN ('
        '     SELECT $transDayTransId'
        '     FROM $transDayTable'
        '     WHERE $transDayBalanceId IN ('
        '       SELECT $balanceId'
        '       FROM $balanceTable'
        '       WHERE $balanceAccountId = $accountId'
        '     )'
        '   )',
      );
      double totalEntries = (result.first['totalExpenses'] ?? 0.0) as double;
      return totalEntries;
    } catch (err) {
      log('Error: $err');
      return 0.0;
    }
  }

  /*
   * Transfer Methods
   */
  @override
  Future<int> insertTransfer(Map<String, dynamic> transferMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
        transfersTable,
        transferMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> deleteTransferId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.delete(
        transfersTable,
        where: '$transferId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<Map<String, Object?>?> queryTranferId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, Object?>> maps = await _db.query(
        transfersTable,
        where: '$transferId = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return maps[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }

  @override
  Future<int> updateTransfer(Map<String, dynamic> transferMap) async {
    try {
      int id = transferMap[transferId];
      int result = await _db.update(
        transfersTable,
        transferMap,
        where: '$transferId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /*
  * TransDay Methods
  */
  @override
  Future<int> insertTransDay(Map<String, dynamic> transDayMap) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.insert(
        transDayTable,
        transDayMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> deleteTransDay(int transId) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int result = await _db.delete(
        transDayTable,
        where: '$transDayTransId = ?',
        whereArgs: [transId],
      );
      return result;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<Map<String, Object?>?> queryTransDayId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      List<Map<String, Object?>> maps = await _db.query(
        transDayTable,
        where: '$transDayTransId = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return maps[0];
    } catch (err) {
      log('Error: $err');
      return null;
    }
  }

  /*
   * Counters
   */
  @override
  Future<int> countUsers() async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int count = Sqflite.firstIntValue(
            await _db.rawQuery('SELECT COUNT(*) FROM $usersTable'),
          ) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  @override
  Future<int> countIcons() async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int count = Sqflite.firstIntValue(
            await _db.rawQuery('SELECT COUNT(*) FROM $iconsTable'),
          ) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Returns the number of categories in database.
  @override
  Future<int> countCategories() async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int count = Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM $categoriesTable',
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Returns the number of accounts on the passed id user.
  @override
  Future<int> countAccountsForUserId(String id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int count = Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM $accountTable WHERE $accountUserId = ?',
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Returns the number of balances on the passed id account.
  @override
  Future<int> countBalancesForAccountId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int count = Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM $balanceTable WHERE $balanceAccountId = ?',
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Returns the number of transactions on the passed id category.
  @override
  Future<int> countTransactionForCategoryId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int count = Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM $transactionsTable WHERE $transCategoryId = ?',
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /// Returns the number of transactions on the passed id account.
  @override
  Future<int> countTransactionsForAccountId(int id) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      int count = Sqflite.firstIntValue(await _db.rawQuery(
            'SELECT COUNT(*) FROM $transactionsTable '
            ' WHERE $transId IN ('
            '  SELECT $transDayTransId FROM $transDayTable '
            '   WHERE $transDayBalanceId IN ('
            '    SELECT $balanceId FROM $balanceTable '
            '     WHERE $balanceAccountId IN ('
            '      SELECT $accountId FROM $accountTable WHERE $accountId = ?)'
            '  )'
            ')',
            [id],
          )) ??
          0;
      return count;
    } catch (err) {
      log('Error: $err');
      return -1;
    }
  }

  /*
   * Statistics Methods
   */
  @override
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
  }) async {
    if (!_db.isOpen) await _openDatabase();
    try {
      final results = await _db.rawQuery(
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

  // dispose
  @override
  Future<void> dispose() async {
    await _db.close();
  }
}
