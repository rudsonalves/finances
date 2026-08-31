import 'package:finances/store/constants/constants.dart';
import 'package:finances/store/database/database_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_setup.dart';

void main() {
  late DatabaseManager manager;

  setUp(() {
    final factory = initializeFfiDatabase();

    manager = DatabaseManager(
      factory: factory,
      databasePathProvider: () async => inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await manager.databaseClose();
  });

  group('DatabaseManager', () {
    test('abre banco em memória e cria o schema completo', () async {
      final database = await manager.database;

      final rows = await database.rawQuery(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
        ''',
      );

      final tableNames = rows.map((row) => row['name'] as String).toSet();

      expect(tableNames, contains(usersTable));
      expect(tableNames, contains(accountTable));
      expect(tableNames, contains(balanceTable));
      expect(tableNames, contains(transactionsTable));
      expect(tableNames, contains(ofxImportedTransactionsTable));
    });

    test('habilita foreign keys durante a abertura', () async {
      final database = await manager.database;
      final result = await database.rawQuery('PRAGMA foreign_keys');

      expect(result.single['foreign_keys'], 1);
    });

    test('reutiliza a mesma conexão enquanto estiver aberta', () async {
      final first = await manager.database;
      final second = await manager.database;

      expect(second, same(first));
      expect(second.isOpen, isTrue);
    });

    test('cria uma nova conexão depois do fechamento', () async {
      final first = await manager.database;

      await manager.databaseClose();

      final second = await manager.database;

      expect(second, isNot(same(first)));
      expect(first.isOpen, isFalse);
      expect(second.isOpen, isTrue);
    });
  });
}
