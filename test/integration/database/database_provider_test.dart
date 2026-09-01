import 'package:finances/store/constants/constants.dart';
import 'package:finances/store/database/database_manager.dart';
import 'package:finances/store/database/database_migrations.dart';
import 'package:finances/store/database/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  late DatabaseManager databaseManager;
  late Database database;
  late MockDatabaseBackuper databaseBackuper;

  setUp(() async {
    final factory = initializeFfiDatabase();

    databaseManager = DatabaseManager(
      factory: factory,
      databasePathProvider: () async => inMemoryDatabasePath,
    );

    database = await databaseManager.database;
    databaseBackuper = MockDatabaseBackuper();
  });

  tearDown(() async {
    await databaseManager.databaseClose();
  });

  group('DatabaseProvide', () {
    test('não cria backup quando o schema já está atualizado', () async {
      await database.insert(
        appControlTable,
        <String, Object?>{
          appControlId: 1,
          appControlVersion: DatabaseMigrations.databaseSchemeVersion,
          appControlApp: '',
        },
      );

      final provider = DatabaseProvide(
        databaseManager: databaseManager,
        databaseBackuper: databaseBackuper,
      );

      await provider.init();

      verifyNever(() => databaseBackuper.backupDatabase());
      verifyNever(
        () => databaseBackuper.restoreDatabase(any()),
      );
    });

    test('aborta migração quando o backup de segurança falha', () async {
      await database.insert(
        appControlTable,
        <String, Object?>{
          appControlId: 1,
          appControlVersion: 1000,
          appControlApp: '',
        },
      );

      when(
        () => databaseBackuper.backupDatabase(),
      ).thenAnswer((_) async => null);

      final provider = DatabaseProvide(
        databaseManager: databaseManager,
        databaseBackuper: databaseBackuper,
      );

      await expectLater(
        provider.init(),
        throwsA(isA<StateError>()),
      );

      final control = (await database.query(
        appControlTable,
      ))
          .single;

      expect(control[appControlVersion], 1000);
      verifyNever(
        () => databaseBackuper.restoreDatabase(any()),
      );
    });

    test('restaura backup e propaga erro quando a migração falha', () async {
      await database.insert(
        appControlTable,
        <String, Object?>{
          appControlId: 1,
          appControlVersion: 1000,
          appControlApp: '',
        },
      );

      when(
        () => databaseBackuper.backupDatabase(),
      ).thenAnswer((_) async => '/safety-backup.db');

      when(
        () => databaseBackuper.restoreDatabase(
          '/safety-backup.db',
        ),
      ).thenAnswer((_) async => true);

      final provider = DatabaseProvide(
        databaseManager: databaseManager,
        databaseBackuper: databaseBackuper,
      );

      await expectLater(
        provider.init(),
        throwsA(anything),
      );

      verify(
        () => databaseBackuper.restoreDatabase(
          '/safety-backup.db',
        ),
      ).called(1);
    });
  });
}
