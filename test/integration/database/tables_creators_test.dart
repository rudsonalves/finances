import 'package:finances/store/constants/constants.dart';
import 'package:finances/store/tables_creators.dart';
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
        onCreate: (database, version) async {
          final batch = database.batch();

          TablesCreators.createAppControlTable(batch);
          TablesCreators.createUsersTable(batch);
          TablesCreators.createIconsTable(batch);
          TablesCreators.createAccountsTable(batch);
          TablesCreators.createBalanceTable(batch);
          TablesCreators.createCategoryTable(batch);
          TablesCreators.createTransactionsTable(batch);
          TablesCreators.createTransfersTable(batch);
          TablesCreators.createOfxAccuntTable(batch);
          TablesCreators.createOfxRelationshipTable(batch);
          TablesCreators.createOfxTransactionsTable(batch);
          TablesCreators.createOfxImportedTransactionsTable(batch);
          TablesCreators.createTriggers(batch);

          await batch.commit(noResult: true);
        },
        version: 1,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('TablesCreators', () {
    test('cria todas as tabelas do schema atual', () async {
      final rows = await database.rawQuery(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
        ORDER BY name
        ''',
      );

      final tableNames = rows
          .map((row) => row['name'] as String)
          .where((name) => !name.startsWith('sqlite_'))
          .toSet();

      expect(
        tableNames,
        containsAll(<String>{
          appControlTable,
          usersTable,
          iconsTable,
          accountTable,
          balanceTable,
          categoriesTable,
          transactionsTable,
          transfersTable,
          ofxACCTable,
          ofxRelationshipTable,
          ofxTransTemplateTable,
          ofxImportedTransactionsTable,
        }),
      );

      expect(tableNames, hasLength(12));
    });

    test('habilita a validação de chaves estrangeiras', () async {
      final result = await database.rawQuery('PRAGMA foreign_keys');

      expect(result.single['foreign_keys'], 1);
    });

    test('cria todos os índices explícitos do schema', () async {
      final rows = await database.rawQuery(
        '''
    SELECT name, tbl_name, sql
    FROM sqlite_master
    WHERE type = 'index'
      AND name NOT LIKE 'sqlite_autoindex_%'
    ORDER BY name
    ''',
      );

      final indexes = <String, Map<String, Object?>>{
        for (final row in rows) row['name'] as String: row,
      };

      expect(
        indexes.keys,
        containsAll(<String>{
          accountUserIndex,
          balanceDateIndex,
          balanceAccountIndex,
          categoriesNameIndex,
          transactionsDateIndex,
          transactionsCategoryIndex,
          transactionsAccountDateIndex,
          ofxAccountBankIndex,
          ofxRelaltionshipIndex,
          ofxTransMemoIndex,
          ofxTransAccountIndex,
          ofxImportedTransactionUniqueIndex,
        }),
      );

      expect(indexes, hasLength(12));

      expect(
        indexes[accountUserIndex]!['tbl_name'],
        accountTable,
      );
      expect(
        indexes[balanceDateIndex]!['tbl_name'],
        balanceTable,
      );
      expect(
        indexes[balanceAccountIndex]!['tbl_name'],
        balanceTable,
      );
      expect(
        indexes[transactionsDateIndex]!['tbl_name'],
        transactionsTable,
      );
      expect(
        indexes[transactionsAccountDateIndex]!['tbl_name'],
        transactionsTable,
      );
      expect(
        indexes[transactionsCategoryIndex]!['tbl_name'],
        transactionsTable,
      );
      expect(
        indexes[ofxImportedTransactionUniqueIndex]!['tbl_name'],
        ofxImportedTransactionsTable,
      );
    });

    test('índice de transações OFX importadas possui chave composta e única',
        () async {
      final indexList = await database.rawQuery(
        'PRAGMA index_list($ofxImportedTransactionsTable)',
      );

      final uniqueIndex = indexList.singleWhere(
        (row) => row['name'] == ofxImportedTransactionUniqueIndex,
      );

      expect(uniqueIndex['unique'], 1);

      final indexColumns = await database.rawQuery(
        'PRAGMA index_info($ofxImportedTransactionUniqueIndex)',
      );

      expect(
        indexColumns.map((row) => row['name']).toList(),
        <String>[
          ofxImportedTransactionInstitutionId,
          ofxImportedTransactionBankAccountId,
          ofxImportedTransactionFitId,
        ],
      );
    });

    test('transactions possui chave primária e campos obrigatórios', () async {
      final columns = await database.rawQuery(
        'PRAGMA table_info($transactionsTable)',
      );

      final columnsByName = <String, Map<String, Object?>>{
        for (final column in columns) column['name'] as String: column,
      };

      expect(columnsByName.keys, <String>[
        transId,
        transBalanceId,
        transAccountId,
        transDescription,
        transCategoryId,
        transValue,
        transStatus,
        transTransferId,
        transDate,
        transOfxId,
      ]);

      expect(columnsByName[transId]!['pk'], 1);
      expect(columnsByName[transId]!['type'], 'INTEGER');

      for (final columnName in <String>[
        transBalanceId,
        transAccountId,
        transDescription,
        transCategoryId,
        transValue,
        transStatus,
        transDate,
      ]) {
        expect(
          columnsByName[columnName]!['notnull'],
          1,
          reason: '$columnName deveria ser obrigatório',
        );
      }

      expect(columnsByName[transTransferId]!['notnull'], 0);
      expect(columnsByName[transOfxId]!['notnull'], 0);
    });

    test('users possui chave primária, campos obrigatórios e padrões',
        () async {
      final columns = await database.rawQuery(
        'PRAGMA table_info($usersTable)',
      );

      final columnsByName = <String, Map<String, Object?>>{
        for (final column in columns) column['name'] as String: column,
      };

      expect(columnsByName[userId]!['pk'], 1);
      expect(columnsByName[userId]!['notnull'], 1);
      expect(columnsByName[userName]!['notnull'], 1);
      expect(columnsByName[userEmail]!['notnull'], 1);
      expect(columnsByName[userLogged]!['notnull'], 1);
      expect(columnsByName[userTheme]!['notnull'], 1);
      expect(columnsByName[userLanguage]!['notnull'], 1);

      expect(columnsByName[userGrpShowGrid]!['dflt_value'], '1');
      expect(columnsByName[userGrpIsCurved]!['dflt_value'], '0');
      expect(columnsByName[userGrpShowDots]!['dflt_value'], '0');
      expect(columnsByName[userGrpAreaChart]!['dflt_value'], '0');
      expect(columnsByName[userBudgetRef]!['dflt_value'], '2');
      expect(columnsByName[userCategoryList]!['dflt_value'], '"[]"');
      expect(columnsByName[userMaxTransactions]!['dflt_value'], '35');
      expect(columnsByName[userOfxStopCategories]!['dflt_value'], '"[1]"');
    });

    test('category possui os padrões financeiros esperados', () async {
      final columns = await database.rawQuery(
        'PRAGMA table_info($categoriesTable)',
      );

      final columnsByName = <String, Map<String, Object?>>{
        for (final column in columns) column['name'] as String: column,
      };

      expect(columnsByName[categoryId]!['pk'], 1);
      expect(columnsByName[categoryName]!['notnull'], 1);
      expect(columnsByName[categoryIcon]!['notnull'], 1);
      expect(columnsByName[categoryBudget]!['dflt_value'], '0');
      expect(columnsByName[categoryIsIncome]!['dflt_value'], '0');
    });

    test('rejeita campos obrigatórios ausentes', () async {
      expect(
        () => database.insert(
          iconsTable,
          <String, Object?>{
            iconFontFamily: 'MaterialIcons',
            iconColor: 0,
          },
        ),
        throwsA(isA<DatabaseException>()),
      );

      expect(
        () => database.insert(
          usersTable,
          <String, Object?>{
            userId: 'user-1',
            userEmail: 'user@example.com',
            userLogged: 1,
            userTheme: 'system',
            userLanguage: 'pt_BR',
          },
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rejeita referências inexistentes', () async {
      expect(
        () => database.insert(
          accountTable,
          <String, Object?>{
            accountName: 'Conta inválida',
            accountUserId: 'usuario-inexistente',
          },
        ),
        throwsA(isA<DatabaseException>()),
      );

      expect(
        () => database.insert(
          categoriesTable,
          <String, Object?>{
            categoryName: 'Categoria inválida',
            categoryIcon: 999,
          },
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('impede excluir conta que possui saldo associado', () async {
      final iconKey = await database.insert(
        iconsTable,
        <String, Object?>{
          iconName: 'wallet',
          iconFontFamily: 'MaterialIcons',
          iconColor: 0,
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

      final accountKey = await database.insert(
        accountTable,
        <String, Object?>{
          accountName: 'Conta principal',
          accountUserId: 'user-1',
          accountIcon: iconKey,
        },
      );

      await database.insert(
        balanceTable,
        <String, Object?>{
          balanceAccountId: accountKey,
          balanceDate: DateTime(2026, 8, 1).millisecondsSinceEpoch,
          balanceTransCount: 0,
          balanceOpen: 0.0,
          balanceClose: 0.0,
        },
      );

      expect(
        () => database.delete(
          accountTable,
          where: '$accountId = ?',
          whereArgs: <Object?>[accountKey],
        ),
        throwsA(isA<DatabaseException>()),
      );

      final accounts = await database.query(
        accountTable,
        where: '$accountId = ?',
        whereArgs: <Object?>[accountKey],
      );

      expect(accounts, hasLength(1));
    });

    test('triggers propagam inserção e remoção aos saldos posteriores',
        () async {
      final iconKey = await database.insert(
        iconsTable,
        <String, Object?>{
          iconName: 'wallet',
          iconFontFamily: 'MaterialIcons',
          iconColor: 0,
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

      final accountKey = await database.insert(
        accountTable,
        <String, Object?>{
          accountName: 'Conta principal',
          accountUserId: 'user-1',
          accountIcon: iconKey,
        },
      );

      final categoryKey = await database.insert(
        categoriesTable,
        <String, Object?>{
          categoryName: 'Alimentação',
          categoryIcon: iconKey,
          categoryBudget: 0.0,
          categoryIsIncome: 0,
        },
      );

      final firstDate = DateTime(2026, 8, 10).millisecondsSinceEpoch;
      final secondDate = DateTime(2026, 8, 11).millisecondsSinceEpoch;

      final firstBalanceKey = await database.insert(
        balanceTable,
        <String, Object?>{
          balanceAccountId: accountKey,
          balanceDate: firstDate,
          balanceTransCount: 0,
          balanceOpen: 100.0,
          balanceClose: 100.0,
        },
      );

      final secondBalanceKey = await database.insert(
        balanceTable,
        <String, Object?>{
          balanceAccountId: accountKey,
          balanceDate: secondDate,
          balanceTransCount: 0,
          balanceOpen: 100.0,
          balanceClose: 100.0,
        },
      );

      final transactionKey = await database.insert(
        transactionsTable,
        <String, Object?>{
          transBalanceId: firstBalanceKey,
          transAccountId: accountKey,
          transDescription: 'Compra de mercado',
          transCategoryId: categoryKey,
          transValue: -25.0,
          transStatus: 1,
          transDate: firstDate,
        },
      );

      var firstBalance = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[firstBalanceKey],
      ))
          .single;

      var secondBalance = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[secondBalanceKey],
      ))
          .single;

      expect(firstBalance[balanceOpen], 100.0);
      expect(firstBalance[balanceClose], 75.0);
      expect(firstBalance[balanceTransCount], 1);

      expect(secondBalance[balanceOpen], 75.0);
      expect(secondBalance[balanceClose], 75.0);
      expect(secondBalance[balanceTransCount], 0);

      await database.delete(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: <Object?>[transactionKey],
      );

      firstBalance = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[firstBalanceKey],
      ))
          .single;

      secondBalance = (await database.query(
        balanceTable,
        where: '$balanceId = ?',
        whereArgs: <Object?>[secondBalanceKey],
      ))
          .single;

      expect(firstBalance[balanceOpen], 100.0);
      expect(firstBalance[balanceClose], 100.0);
      expect(firstBalance[balanceTransCount], 0);

      expect(secondBalance[balanceOpen], 100.0);
      expect(secondBalance[balanceClose], 100.0);
      expect(secondBalance[balanceTransCount], 0);
    });

    test('possui índice composto para paginação por conta e data', () async {
      final indexRows = await database.rawQuery(
        'PRAGMA index_list($transactionsTable)',
      );

      final indexedColumnLists = <List<String>>[];

      for (final indexRow in indexRows) {
        final indexName = indexRow['name'] as String;

        final columns = await database.rawQuery(
          'PRAGMA index_info($indexName)',
        );

        indexedColumnLists.add(
          columns.map((column) => column['name'] as String).toList(),
        );
      }

      final hasAccountDateIndex = indexedColumnLists.any(
        (columns) =>
            columns.length == 2 &&
            columns[0] == transAccountId &&
            columns[1] == transDate,
      );

      expect(
        hasAccountDateIndex,
        isTrue,
        reason:
            'A paginação filtra por conta e data e precisa de um índice composto.',
      );
    });
  });
}
