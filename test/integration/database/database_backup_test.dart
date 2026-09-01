import 'dart:io';

import 'package:finances/store/constants/constants.dart';
import 'package:finances/store/database/database_backup.dart';
import 'package:finances/store/database/database_manager.dart';
import 'package:finances/store/database/database_migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_setup.dart';

void main() {
  late DatabaseFactory factory;
  late Directory temporaryDirectory;
  late String databasePath;
  late DatabaseManager manager;
  late DatabaseBackup backup;

  setUp(() async {
    factory = initializeFfiDatabase();
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'finances_backup_test_',
    );
    databasePath = join(temporaryDirectory.path, 'finances.db');

    manager = DatabaseManager(
      factory: factory,
      databasePathProvider: () async => databasePath,
    );

    backup = DatabaseBackup(
      databaseManager: manager,
      factory: factory,
      databasePathProvider: () async => databasePath,
      now: () => DateTime(2026, 9, 1, 12, 30),
    );
  });

  tearDown(() async {
    await manager.databaseClose();

    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('DatabaseBackup', () {
    test('exporta uma cópia válida com todos os registros', () async {
      final database = await manager.database;

      await database.execute(
        '''
        CREATE TABLE backupFixture (
          id INTEGER PRIMARY KEY,
          description TEXT NOT NULL,
          amount REAL NOT NULL
        )
        ''',
      );

      await database.insert(
        'backupFixture',
        <String, Object?>{
          'id': 1,
          'description': 'Registro original',
          'amount': 125.75,
        },
      );

      final backupPath = await backup.backupDatabase(
        temporaryDirectory.path,
      );

      expect(backupPath, isNotNull);
      expect(
        basename(backupPath!),
        'app_dataBase.db_bkp_2026_09_01_1230',
      );
      expect(await File(backupPath).exists(), isTrue);

      final backupDatabase = await factory.openDatabase(
        backupPath,
        options: OpenDatabaseOptions(
          singleInstance: false,
          readOnly: true,
        ),
      );

      addTearDown(backupDatabase.close);

      final rows = await backupDatabase.query('backupFixture');

      expect(rows, hasLength(1));
      expect(rows.single['id'], 1);
      expect(rows.single['description'], 'Registro original');
      expect(rows.single['amount'], 125.75);
    });

    test('restaura o banco para o estado registrado no backup', () async {
      var database = await manager.database;

      await database.execute(
        '''
    CREATE TABLE restoreFixture (
      id INTEGER PRIMARY KEY,
      description TEXT NOT NULL
    )
    ''',
      );

      await database.insert(
        'restoreFixture',
        <String, Object?>{
          'id': 1,
          'description': 'Estado original',
        },
      );

      final backupPath = await backup.backupDatabase(
        temporaryDirectory.path,
      );

      expect(backupPath, isNotNull);

      await database.update(
        'restoreFixture',
        <String, Object?>{
          'description': 'Estado alterado',
        },
        where: 'id = ?',
        whereArgs: <Object?>[1],
      );

      await database.insert(
        'restoreFixture',
        <String, Object?>{
          'id': 2,
          'description': 'Registro posterior',
        },
      );

      var rowsBeforeRestore = await database.query(
        'restoreFixture',
        orderBy: 'id',
      );

      expect(rowsBeforeRestore, hasLength(2));
      expect(rowsBeforeRestore.first['description'], 'Estado alterado');

      final restored = await backup.restoreDatabase(backupPath!);

      expect(restored, isTrue);

      database = await manager.database;

      final rowsAfterRestore = await database.query(
        'restoreFixture',
        orderBy: 'id',
      );

      expect(rowsAfterRestore, hasLength(1));
      expect(rowsAfterRestore.single['id'], 1);
      expect(
        rowsAfterRestore.single['description'],
        'Estado original',
      );

      expect(
        await File('$databasePath.bkp').exists(),
        isFalse,
        reason: 'O backup temporário da restauração deve ser removido.',
      );
    });

    test('rejeita backup corrompido e preserva o banco atual', () async {
      var database = await manager.database;

      await database.execute(
        '''
    CREATE TABLE corruptedRestoreFixture (
      id INTEGER PRIMARY KEY,
      description TEXT NOT NULL
    )
    ''',
      );

      await database.insert(
        'corruptedRestoreFixture',
        <String, Object?>{
          'id': 1,
          'description': 'Registro que deve permanecer',
        },
      );

      final corruptedBackupPath = join(
        temporaryDirectory.path,
        'corrupted-backup.db',
      );

      await File(corruptedBackupPath).writeAsString(
        'Este arquivo não é um banco SQLite.',
        flush: true,
      );

      final restored = await backup.restoreDatabase(
        corruptedBackupPath,
      );

      expect(restored, isFalse);

      database = await manager.database;

      final rows = await database.query(
        'corruptedRestoreFixture',
      );

      expect(rows, hasLength(1));
      expect(rows.single['id'], 1);
      expect(
        rows.single['description'],
        'Registro que deve permanecer',
      );

      expect(
        await File('$databasePath.bkp').exists(),
        isFalse,
        reason: 'O arquivo temporário deve ser removido após o rollback.',
      );
    });

    test('falha de exportação preserva um backup anterior', () async {
      await manager.database;

      final expectedBackupPath = join(
        temporaryDirectory.path,
        'app_dataBase.db_bkp_2026_09_01_1230',
      );

      final previousBackup = File(expectedBackupPath);

      await previousBackup.writeAsString(
        'conteúdo do backup anterior',
        flush: true,
      );

      final invalidSourcePath = join(
        temporaryDirectory.path,
        'database-inexistente.db',
      );

      final failingBackup = DatabaseBackup(
        databaseManager: manager,
        factory: factory,
        databasePathProvider: () async => invalidSourcePath,
        now: () => DateTime(2026, 9, 1, 12, 30),
      );

      final result = await failingBackup.backupDatabase(
        temporaryDirectory.path,
      );

      expect(result, isNull);

      expect(
        await previousBackup.exists(),
        isTrue,
        reason: 'Uma exportação com falha não pode apagar o backup anterior.',
      );

      expect(
        await previousBackup.readAsString(),
        'conteúdo do backup anterior',
      );
    });

    test('rejeita um SQLite válido que não possui o schema da aplicação',
        () async {
      var database = await manager.database;

      await database.execute(
        '''
    CREATE TABLE incompatibleRestoreFixture (
      id INTEGER PRIMARY KEY,
      description TEXT NOT NULL
    )
    ''',
      );

      await database.insert(
        'incompatibleRestoreFixture',
        <String, Object?>{
          'id': 1,
          'description': 'Registro financeiro atual',
        },
      );

      final incompatiblePath = join(
        temporaryDirectory.path,
        'incompatible.db',
      );

      final incompatibleDatabase = await factory.openDatabase(
        incompatiblePath,
        options: OpenDatabaseOptions(
          singleInstance: false,
          version: 1,
          onCreate: (database, version) async {
            await database.execute(
              '''
          CREATE TABLE unrelatedTable (
            id INTEGER PRIMARY KEY,
            value TEXT
          )
          ''',
            );
          },
        ),
      );

      await incompatibleDatabase.insert(
        'unrelatedTable',
        <String, Object?>{
          'id': 1,
          'value': 'Não pertence ao Finances',
        },
      );

      await incompatibleDatabase.close();

      final restored = await backup.restoreDatabase(
        incompatiblePath,
      );

      expect(
        restored,
        isFalse,
        reason: 'Um SQLite sem o schema do Finances deve ser rejeitado.',
      );

      database = await manager.database;

      final rows = await database.query(
        'incompatibleRestoreFixture',
      );

      expect(rows, hasLength(1));
      expect(rows.single['id'], 1);
      expect(
        rows.single['description'],
        'Registro financeiro atual',
      );
    });

    test('rejeita backup criado por uma versão futura do schema', () async {
      var database = await manager.database;

      await database.execute(
        '''
    CREATE TABLE futureVersionFixture (
      id INTEGER PRIMARY KEY,
      description TEXT NOT NULL
    )
    ''',
      );

      await database.insert(
        'futureVersionFixture',
        <String, Object?>{
          'id': 1,
          'description': 'Banco atual preservado',
        },
      );

      final futureDatabasePath = join(
        temporaryDirectory.path,
        'future-version.db',
      );

      final futureManager = DatabaseManager(
        factory: factory,
        databasePathProvider: () async => futureDatabasePath,
      );

      final futureDatabase = await futureManager.database;

      await futureDatabase.insert(
        appControlTable,
        <String, Object?>{
          appControlId: 1,
          appControlVersion: DatabaseMigrations.databaseSchemeVersion + 1,
          appControlApp: 'versão futura',
        },
      );

      await futureManager.databaseClose();

      final restored = await backup.restoreDatabase(
        futureDatabasePath,
      );

      expect(
        restored,
        isFalse,
        reason: 'Uma versão desconhecida do schema deve ser rejeitada.',
      );

      database = await manager.database;

      final rows = await database.query(
        'futureVersionFixture',
      );

      expect(rows, hasLength(1));
      expect(rows.single['id'], 1);
      expect(
        rows.single['description'],
        'Banco atual preservado',
      );
    });

    test('aceita backup legado na versão 1007', () async {
      await manager.database;

      final legacyPath = join(
        temporaryDirectory.path,
        'legacy-1007.db',
      );

      final legacyDatabase = await factory.openDatabase(
        legacyPath,
        options: OpenDatabaseOptions(
          singleInstance: false,
        ),
      );

      final batch = legacyDatabase.batch();

      batch.execute(
        '''
    CREATE TABLE $appControlTable (
      $appControlId INTEGER PRIMARY KEY,
      $appControlVersion INTEGER NOT NULL,
      $appControlApp TEXT DEFAULT ""
    )
    ''',
      );

      batch.execute(
        '''
    CREATE TABLE $usersTable (
      $userId TEXT PRIMARY KEY NOT NULL
    )
    ''',
      );

      batch.execute(
        '''
    CREATE TABLE $accountTable (
      $accountId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
    )
    ''',
      );

      batch.execute(
        '''
    CREATE TABLE $balanceTable (
      $balanceId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
    )
    ''',
      );

      batch.execute(
        '''
    CREATE TABLE $categoriesTable (
      $categoryId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
    )
    ''',
      );

      batch.execute(
        '''
    CREATE TABLE $transfersTable (
      $transferId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
    )
    ''',
      );

      batch.execute(
        '''
    CREATE TABLE transactonsTable (
      $transId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
    )
    ''',
      );

      batch.execute(
        '''
    CREATE TABLE transDayTable (
      transDayTransId INTEGER NOT NULL,
      transDayBalanceId INTEGER NOT NULL
    )
    ''',
      );

      batch.insert(
        appControlTable,
        <String, Object?>{
          appControlId: 1,
          appControlVersion: 1007,
          appControlApp: 'legacy',
        },
      );

      await batch.commit(noResult: true);

      // Impede que o DatabaseManager interprete o arquivo como recém-criado.
      await legacyDatabase.execute('PRAGMA user_version = 1');
      await legacyDatabase.close();

      final restored = await backup.restoreDatabase(legacyPath);

      expect(
        restored,
        isTrue,
        reason: 'A versão 1007 ainda possui uma cadeia de migração suportada.',
      );

      final restoredDatabase = await manager.database;

      final tables = await restoredDatabase.rawQuery(
        '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
    ''',
      );

      final tableNames = tables.map((row) => row['name'] as String).toSet();

      expect(tableNames, contains('transactonsTable'));
      expect(tableNames, contains('transDayTable'));

      final control = (await restoredDatabase.query(
        appControlTable,
      ))
          .single;

      expect(control[appControlVersion], 1007);
    });
  });
}
