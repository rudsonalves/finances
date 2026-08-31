import 'package:finances/store/constants/constants.dart';
import 'package:finances/store/database/database_migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_setup.dart';

void main() {
  late Database database;

  setUp(() async {
    final factory = initializeFfiDatabase();

    database = await factory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('DatabaseMigrations', () {
    test('possui scripts contínuos da versão 1000 até a versão atual', () {
      final expectedVersions = <int>[
        for (var version = 1000;
            version <= DatabaseMigrations.databaseSchemeVersion;
            version++)
          version,
      ];

      expect(
        DatabaseMigrations.migrationScripts.keys.toList()..sort(),
        expectedVersions,
      );
    });

    test('último script corresponde à versão atual do schema', () {
      final lastVersion = DatabaseMigrations.migrationScripts.keys.reduce(
        (current, next) => current > next ? current : next,
      );

      expect(
        lastVersion,
        DatabaseMigrations.databaseSchemeVersion,
      );
    });

    test('restaura foreign keys quando uma migração falha', () async {
      final foreignKeysBefore = await database.rawQuery(
        'PRAGMA foreign_keys',
      );

      expect(foreignKeysBefore.single['foreign_keys'], 1);

      await expectLater(
        () => DatabaseMigrations.applyMigrations(
          db: database,
          currentVersion: 1000,
          targetVersion: 1001,
        ),
        throwsA(isA<DatabaseException>()),
      );

      final foreignKeysAfter = await database.rawQuery(
        'PRAGMA foreign_keys',
      );

      expect(
        foreignKeysAfter.single['foreign_keys'],
        1,
        reason: 'Uma falha de migração não pode deixar foreign_keys desligado.',
      );
    });

    test('migra de 1000 até 1007 preservando os dados existentes', () async {
      await database.execute(
        '''
    CREATE TABLE $categoriesTable (
      $categoryId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $categoryName TEXT UNIQUE NOT NULL,
      $categoryIcon INTEGER NOT NULL
    )
    ''',
      );

      await database.execute(
        '''
    CREATE TABLE $usersTable (
      $userId TEXT PRIMARY KEY NOT NULL,
      $userName TEXT NOT NULL,
      $userEmail TEXT UNIQUE NOT NULL,
      $userLogged INTEGER NOT NULL,
      $userMainAccountId INTEGER,
      $userTheme TEXT NOT NULL,
      $userLanguage TEXT NOT NULL
    )
    ''',
      );

      await database.execute(
        '''
    CREATE TABLE $appControlTable (
      $appControlId INTEGER PRIMARY KEY,
      $appControlVersion INTEGER NOT NULL
    )
    ''',
      );

      await database.insert(
        categoriesTable,
        <String, Object?>{
          categoryId: 1,
          categoryName: 'Alimentação',
          categoryIcon: 10,
        },
      );

      await database.insert(
        usersTable,
        <String, Object?>{
          userId: 'user-1',
          userName: 'Test User',
          userEmail: 'user@example.com',
          userLogged: 1,
          userTheme: 'system',
          userLanguage: 'pt_BR',
        },
      );

      await database.insert(
        appControlTable,
        <String, Object?>{
          appControlId: 1,
          appControlVersion: 1000,
        },
      );

      await DatabaseMigrations.applyMigrations(
        db: database,
        currentVersion: 1000,
        targetVersion: 1007,
      );

      final category = (await database.query(categoriesTable)).single;
      final user = (await database.query(usersTable)).single;
      final control = (await database.query(appControlTable)).single;

      expect(category[categoryId], 1);
      expect(category[categoryName], 'Alimentação');
      expect(category[categoryIcon], 10);
      expect(category[categoryBudget], 0.0);
      expect(category[categoryIsIncome], 0);

      expect(user[userId], 'user-1');
      expect(user[userName], 'Test User');
      expect(user[userEmail], 'user@example.com');
      expect(user[userGrpShowGrid], 1);
      expect(user[userGrpIsCurved], 0);
      expect(user[userGrpShowDots], 0);
      expect(user[userGrpAreaChart], 0);
      expect(user[userBudgetRef], 2);
      expect(user[userCategoryList], '[]');
      expect(user[userMaxTransactions], 35);

      expect(control[appControlId], 1);
      expect(control[appControlVersion], 1000);
      expect(control[appControlApp], '');
    });

    test('migrações 1008 a 1010 preservam dados e atualizam os triggers',
        () async {
      await database.execute(
        '''
  CREATE TABLE $usersTable (
    $userId TEXT PRIMARY KEY NOT NULL,
    $userName TEXT NOT NULL,
    $userEmail TEXT UNIQUE NOT NULL,
    $userLogged INTEGER NOT NULL,
    $userMainAccountId INTEGER,
    $userTheme TEXT NOT NULL,
    $userLanguage TEXT NOT NULL,
    $userGrpShowGrid INTEGER DEFAULT 1,
    $userGrpIsCurved INTEGER DEFAULT 0,
    $userGrpShowDots INTEGER DEFAULT 0,
    $userGrpAreaChart INTEGER DEFAULT 0,
    $userBudgetRef INTEGER DEFAULT 2,
    $userCategoryList TEXT DEFAULT "[]",
    $userMaxTransactions INTEGER DEFAULT 35
  )
  ''',
      );

      await database.execute(
        '''
  CREATE TABLE $categoriesTable (
    $categoryId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    $categoryName TEXT UNIQUE NOT NULL,
    $categoryIcon INTEGER NOT NULL,
    $categoryBudget REAL DEFAULT 0,
    $categoryIsIncome INTEGER DEFAULT 0
  )
  ''',
      );
      await database.execute(
        '''
    CREATE TABLE $accountTable (
      $accountId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $accountName TEXT NOT NULL,
      $accountDescription TEXT,
      $accountUserId TEXT NOT NULL,
      $accountIcon INTEGER
    )
    ''',
      );

      await database.execute(
        '''
    CREATE TABLE $balanceTable (
      $balanceId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $balanceAccountId INTEGER NOT NULL,
      $balanceDate INTEGER NOT NULL,
      $balanceTransCount INTEGER,
      $balanceOpen REAL NOT NULL,
      $balanceClose REAL NOT NULL
    )
    ''',
      );

      await database.execute(
        '''
    CREATE TABLE $transfersTable (
      $transferId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $transferTransId0 INTEGER,
      $transferTransId1 INTEGER,
      $transferAccount0 INTEGER,
      $transferAccount1 INTEGER
    )
    ''',
      );

      await database.execute(
        '''
    CREATE TABLE transactonsTable (
      $transId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $transDescription TEXT NOT NULL,
      $transCategoryId INTEGER NOT NULL,
      $transValue REAL NOT NULL,
      $transStatus INTEGER NOT NULL,
      $transTransferId INTEGER,
      $transDate INTEGER NOT NULL
    )
    ''',
      );

      await database.execute(
        '''
    CREATE TABLE transDayTable (
      transDayTransId INTEGER NOT NULL,
      transDayBalanceId INTEGER NOT NULL
    )
    ''',
      );

      final transactionDate = DateTime(2026, 8, 10).millisecondsSinceEpoch;

      await database.insert(
        usersTable,
        <String, Object?>{
          userId: 'user-1',
          userName: 'Test User',
          userEmail: 'user@example.com',
          userLogged: 1,
          userTheme: 'system',
          userLanguage: 'pt_BR',
        },
      );

      await database.insert(
        categoriesTable,
        <String, Object?>{
          categoryId: 3,
          categoryName: 'Alimentação',
          categoryIcon: 1,
          categoryBudget: 0.0,
          categoryIsIncome: 0,
        },
      );

      await database.insert(
        accountTable,
        <String, Object?>{
          accountId: 1,
          accountName: 'Conta principal',
          accountDescription: 'Conta antiga',
          accountUserId: 'user-1',
          accountIcon: null,
        },
      );

      await database.insert(
        balanceTable,
        <String, Object?>{
          balanceId: 10,
          balanceAccountId: 1,
          balanceDate: transactionDate,
          balanceTransCount: 1,
          balanceOpen: 100.0,
          balanceClose: 75.0,
        },
      );

      await database.insert(
        'transactonsTable',
        <String, Object?>{
          transId: 20,
          transDescription: 'Compra antiga',
          transCategoryId: 3,
          transValue: -25.0,
          transStatus: 1,
          transTransferId: null,
          transDate: transactionDate,
        },
      );

      await database.insert(
        'transDayTable',
        <String, Object?>{
          'transDayTransId': 20,
          'transDayBalanceId': 10,
        },
      );

      await DatabaseMigrations.applyMigrations(
        db: database,
        currentVersion: 1007,
        targetVersion: 1008,
      );

      final account = (await database.query(accountTable)).single;
      final balance = (await database.query(balanceTable)).single;
      final transaction = (await database.query(transactionsTable)).single;

      expect(account[accountId], 1);
      expect(account[accountName], 'Conta principal');
      expect(account[accountDescription], 'Conta antiga');

      expect(balance[balanceId], 10);
      expect(balance[balanceAccountId], 1);
      expect(balance[balanceOpen], 100.0);
      expect(balance[balanceClose], 75.0);

      expect(transaction[transId], 20);
      expect(transaction[transBalanceId], 10);
      expect(transaction[transAccountId], 1);
      expect(transaction[transDescription], 'Compra antiga');
      expect(transaction[transCategoryId], 3);
      expect(transaction[transValue], -25.0);
      expect(transaction[transDate], transactionDate);

      final legacyTransactionTable = await database.rawQuery(
        '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name = 'transactonsTable'
    ''',
      );

      final legacyRelationshipTable = await database.rawQuery(
        '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name = 'transDayTable'
    ''',
      );

      expect(legacyTransactionTable, isEmpty);
      expect(legacyRelationshipTable, isEmpty);

      await DatabaseMigrations.applyMigrations(
        db: database,
        currentVersion: 1008,
        targetVersion: 1009,
      );

      final tablesAfter1009 = await database.rawQuery(
        '''
  SELECT name
  FROM sqlite_master
  WHERE type = 'table'
  ''',
      );

      final tableNamesAfter1009 =
          tablesAfter1009.map((row) => row['name'] as String).toSet();

      expect(tableNamesAfter1009, contains(ofxACCTable));
      expect(tableNamesAfter1009, contains(ofxRelationshipTable));
      expect(tableNamesAfter1009, contains(ofxTransTemplateTable));

      final transactionsAfter1009 = await database.query(
        transactionsTable,
      );

      expect(transactionsAfter1009, hasLength(1));

      final transactionAfter1009 = transactionsAfter1009.single;

      expect(transactionAfter1009[transId], 20);
      expect(transactionAfter1009[transBalanceId], 10);
      expect(transactionAfter1009[transAccountId], 1);
      expect(transactionAfter1009[transDescription], 'Compra antiga');
      expect(transactionAfter1009[transCategoryId], 3);
      expect(transactionAfter1009[transValue], -25.0);
      expect(transactionAfter1009[transDate], transactionDate);
      expect(transactionAfter1009[transOfxId], isNull);

      final transactionColumns = await database.rawQuery(
        'PRAGMA table_info($transactionsTable)',
      );

      expect(
        transactionColumns.map((column) => column['name']),
        contains(transOfxId),
      );

      final indexesAfter1009 = await database.rawQuery(
        '''
  SELECT name
  FROM sqlite_master
  WHERE type = 'index'
    AND name NOT LIKE 'sqlite_autoindex_%'
  ''',
      );

      final indexNamesAfter1009 =
          indexesAfter1009.map((row) => row['name'] as String).toSet();

      expect(indexNamesAfter1009, contains(ofxAccountBankIndex));
      expect(indexNamesAfter1009, contains(ofxRelaltionshipIndex));
      expect(indexNamesAfter1009, contains(ofxTransMemoIndex));
      expect(indexNamesAfter1009, contains(ofxTransAccountIndex));

      await DatabaseMigrations.applyMigrations(
        db: database,
        currentVersion: 1009,
        targetVersion: 1010,
      );

      final secondBalanceDate = DateTime(2026, 8, 11).millisecondsSinceEpoch;

      final secondBalanceKey = await database.insert(
        balanceTable,
        <String, Object?>{
          balanceAccountId: 1,
          balanceDate: secondBalanceDate,
          balanceTransCount: 0,
          balanceOpen: 75.0,
          balanceClose: 75.0,
        },
      );

      final newTransactionKey = await database.insert(
        transactionsTable,
        <String, Object?>{
          transBalanceId: 10,
          transAccountId: 1,
          transDescription: 'Despesa após migração',
          transCategoryId: 3,
          transValue: -5.0,
          transStatus: 1,
          transTransferId: null,
          transDate: transactionDate,
          transOfxId: null,
        },
      );

      var firstBalanceAfterTrigger = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[10],
      ))
          .single;

      var secondBalanceAfterTrigger = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[secondBalanceKey],
      ))
          .single;

      expect(firstBalanceAfterTrigger[balanceOpen], 100.0);
      expect(firstBalanceAfterTrigger[balanceClose], 70.0);
      expect(firstBalanceAfterTrigger[balanceTransCount], 2);

      expect(secondBalanceAfterTrigger[balanceOpen], 70.0);
      expect(secondBalanceAfterTrigger[balanceClose], 70.0);
      expect(secondBalanceAfterTrigger[balanceTransCount], 0);

      await database.delete(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: <Object?>[newTransactionKey],
      );

      firstBalanceAfterTrigger = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[10],
      ))
          .single;

      secondBalanceAfterTrigger = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[secondBalanceKey],
      ))
          .single;

      expect(firstBalanceAfterTrigger[balanceOpen], 100.0);
      expect(firstBalanceAfterTrigger[balanceClose], 75.0);
      expect(firstBalanceAfterTrigger[balanceTransCount], 1);

      expect(secondBalanceAfterTrigger[balanceOpen], 75.0);
      expect(secondBalanceAfterTrigger[balanceClose], 75.0);
      expect(secondBalanceAfterTrigger[balanceTransCount], 0);
    });

    test('reverte toda a versão quando uma instrução intermediária falha',
        () async {
      await database.execute(
        '''
    CREATE TABLE $usersTable (
      $userId TEXT PRIMARY KEY NOT NULL,
      $userName TEXT NOT NULL,
      $userEmail TEXT UNIQUE NOT NULL,
      $userLogged INTEGER NOT NULL,
      $userMainAccountId INTEGER,
      $userTheme TEXT NOT NULL,
      $userLanguage TEXT NOT NULL,
      $userGrpIsCurved INTEGER DEFAULT 0
    )
    ''',
      );

      await database.insert(
        usersTable,
        <String, Object?>{
          userId: 'user-1',
          userName: 'Test User',
          userEmail: 'user@example.com',
          userLogged: 1,
          userTheme: 'system',
          userLanguage: 'pt_BR',
          userGrpIsCurved: 1,
        },
      );

      await expectLater(
        () => DatabaseMigrations.applyMigrations(
          db: database,
          currentVersion: 1001,
          targetVersion: 1002,
        ),
        throwsA(isA<DatabaseException>()),
      );

      final columns = await database.rawQuery(
        'PRAGMA table_info($usersTable)',
      );

      final columnNames =
          columns.map((column) => column['name'] as String).toSet();

      expect(
        columnNames,
        isNot(contains(userGrpShowGrid)),
        reason: 'A primeira alteração da versão deveria ter sido revertida.',
      );

      expect(columnNames, contains(userGrpIsCurved));
      expect(columnNames, isNot(contains(userGrpShowDots)));
      expect(columnNames, isNot(contains(userGrpAreaChart)));

      final user = (await database.query(usersTable)).single;

      expect(user[userId], 'user-1');
      expect(user[userName], 'Test User');
      expect(user[userGrpIsCurved], 1);

      final foreignKeys = await database.rawQuery(
        'PRAGMA foreign_keys',
      );

      expect(foreignKeys.single['foreign_keys'], 1);
    });
  });
}
