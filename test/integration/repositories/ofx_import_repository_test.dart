import 'package:finances/repositories/ofx_import/ofx_import_repository.dart';
import 'package:finances/store/constants/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_setup.dart';

void main() {
  late Database database;
  late OfxImportRepository repository;

  setUp(() async {
    final factory = initializeFfiDatabase();
    database = await factory.openDatabase(inMemoryDatabasePath);
    repository = OfxImportRepository(databaseLoader: () async => database);

    await database.execute(
      'CREATE TABLE $ofxACCTable ($ofxACCId INTEGER PRIMARY KEY)',
    );
    await database.execute(createOfxImportedTransactionsSQL);
    await database.execute(createOfxImportedTransactionUniqueIndexSQL);
    await database.insert(ofxACCTable, {ofxACCId: 1});
    await database.insert(ofxACCTable, {ofxACCId: 2});
    await database.execute('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await database.close();
  });

  test('impede reimportação da mesma chave composta', () async {
    final first = await repository.claim(
      ofxAccountId: 1,
      institutionId: 'bank-a',
      bankAccountId: 'account-a',
      fitId: 'fit-1',
    );
    final second = await repository.claim(
      ofxAccountId: 2,
      institutionId: 'bank-a',
      bankAccountId: 'account-a',
      fitId: 'fit-1',
    );

    expect(first, isTrue);
    expect(second, isFalse);
    expect(
      await repository.isImported(
        institutionId: 'bank-a',
        bankAccountId: 'account-a',
        fitId: 'fit-1',
      ),
      isTrue,
    );
  });

  test('não presume que FITID seja globalmente único', () async {
    final claims = await Future.wait([
      repository.claim(
        ofxAccountId: 1,
        institutionId: 'bank-a',
        bankAccountId: 'account-a',
        fitId: 'shared-fit',
      ),
      repository.claim(
        ofxAccountId: 2,
        institutionId: 'bank-b',
        bankAccountId: 'account-a',
        fitId: 'shared-fit',
      ),
      repository.claim(
        ofxAccountId: 2,
        institutionId: 'bank-a',
        bankAccountId: 'account-b',
        fitId: 'shared-fit',
      ),
    ]);

    expect(claims, everyElement(isTrue));
  });

  test('concorrência permite apenas uma reserva da mesma transação', () async {
    final claims = await Future.wait([
      repository.claim(
        ofxAccountId: 1,
        institutionId: 'bank-a',
        bankAccountId: 'account-a',
        fitId: 'concurrent-fit',
      ),
      repository.claim(
        ofxAccountId: 2,
        institutionId: 'bank-a',
        bankAccountId: 'account-a',
        fitId: 'concurrent-fit',
      ),
    ]);

    expect(claims.where((claimed) => claimed), hasLength(1));
  });

  test('libera a reserva após falha da importação', () async {
    await repository.claim(
      ofxAccountId: 1,
      institutionId: 'bank-a',
      bankAccountId: 'account-a',
      fitId: 'retry-fit',
    );

    await repository.release(
      institutionId: 'bank-a',
      bankAccountId: 'account-a',
      fitId: 'retry-fit',
    );

    expect(
      await repository.claim(
        ofxAccountId: 2,
        institutionId: 'bank-a',
        bankAccountId: 'account-a',
        fitId: 'retry-fit',
      ),
      isTrue,
    );
  });
}
