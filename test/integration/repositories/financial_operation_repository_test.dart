import 'package:finances/common/models/extends_date.dart';
import 'package:finances/repositories/financial_operation/financial_operation_repository.dart';
import 'package:finances/store/constants/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fixtures/model_fixtures.dart';
import '../../helpers/test_setup.dart';

void main() {
  late Database database;
  late FinancialOperationRepository repository;

  setUp(() async {
    final factory = initializeFfiDatabase();
    database = await factory.openDatabase(inMemoryDatabasePath);
    repository = FinancialOperationRepository(
      databaseLoader: () async => database,
    );

    await database.execute(
      'CREATE TABLE $accountTable ($accountId INTEGER PRIMARY KEY)',
    );
    await database.execute(
      'CREATE TABLE $categoriesTable ($categoryId INTEGER PRIMARY KEY)',
    );
    await database.execute(
      'CREATE TABLE $ofxACCTable ($ofxACCId INTEGER PRIMARY KEY)',
    );
    await database.execute(createBalanceSQL);
    await database.execute(createTransfersSQL);
    await database.execute(createTransactionsSQL);
    await database.execute(createTriggerAfterInsertTransaction);
    await database.execute(createTriggerAfterDeleteTransaction);
    await database.insert(accountTable, {accountId: 1});
    await database.insert(accountTable, {accountId: 2});
    await database.insert(categoriesTable, {categoryId: 1});
    await database.execute('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await database.close();
  });

  test('grava débito, crédito, transferência e saldos atomicamente', () async {
    final origin = createFakeTransaction(
      id: null,
      balanceId: null,
      accountId: 1,
      value: -25.50,
      date: ExtendedDate(2026, 8, 31),
    );

    final result = await repository.addTransfer(
      origin: origin,
      destinationAccountId: 2,
    );

    final transactions = await database.query(
      transactionsTable,
      orderBy: transAccountId,
    );
    final transfers = await database.query(transfersTable);
    final balances = await database.query(
      balanceTable,
      orderBy: balanceAccountId,
    );

    expect(transactions, hasLength(2));
    expect(transactions[0][transValue], -25.5);
    expect(transactions[1][transValue], 25.5);
    expect(transfers, hasLength(1));
    expect(transfers.single[transferId], result.transferId);
    expect(balances, hasLength(2));
    expect(_toCents(balances[0][balanceClose] as num), -2550);
    expect(_toCents(balances[1][balanceClose] as num), 2550);
  });

  test('faz rollback quando a segunda transação não pode ser inserida',
      () async {
    await database.execute('''
      CREATE TRIGGER fail_destination
      BEFORE INSERT ON $transactionsTable
      WHEN NEW.$transAccountId = 2
      BEGIN
        SELECT RAISE(ABORT, 'destination failure');
      END
    ''');
    final origin = createFakeTransaction(
      id: null,
      balanceId: null,
      accountId: 1,
      value: -25.50,
    );

    await expectLater(
      () => repository.addTransfer(
        origin: origin,
        destinationAccountId: 2,
      ),
      throwsA(anything),
    );

    expect(await _count(database, transactionsTable), 0);
    expect(await _count(database, transfersTable), 0);
    expect(await _count(database, balanceTable), 0);
    expect(origin.transId, isNull);
    expect(origin.transTransferId, isNull);
  });

  test('remove as duas transações e a transferência atomicamente', () async {
    final origin = createFakeTransaction(
      id: null,
      balanceId: null,
      accountId: 1,
      value: -25.50,
    );
    final result = await repository.addTransfer(
      origin: origin,
      destinationAccountId: 2,
    );

    final deleted = await repository.removeTransfer(
      transferId: result.transferId,
    );

    expect(deleted, 1);
    expect(await _count(database, transactionsTable), 0);
    expect(await _count(database, transfersTable), 0);
    expect(await _count(database, balanceTable), 0);
  });

  test('faz rollback da atualização se a reinserção falhar', () async {
    final balanceIdValue = await database.insert(balanceTable, {
      balanceAccountId: 1,
      balanceDate: ExtendedDate(2026, 8, 30).millisecondsSinceEpoch,
      balanceTransCount: 0,
      balanceOpen: 0.0,
      balanceClose: 0.0,
    });
    final original = createFakeTransaction(
      id: null,
      balanceId: balanceIdValue,
      accountId: 1,
      value: 10,
      date: ExtendedDate(2026, 8, 30),
    );
    original.transId = await database.insert(
      transactionsTable,
      original.toMap(),
    );
    await database.execute('''
      CREATE TRIGGER fail_update
      BEFORE INSERT ON $transactionsTable
      WHEN NEW.$transDescription = 'invalid update'
      BEGIN
        SELECT RAISE(ABORT, 'update failure');
      END
    ''');
    original
      ..transDescription = 'invalid update'
      ..transValue = 99;

    await expectLater(
      () => repository.updateTransaction(original),
      throwsA(anything),
    );

    final transactions = await database.query(transactionsTable);
    expect(transactions, hasLength(1));
    expect(transactions.single[transDescription], 'Test transaction');
    expect(transactions.single[transValue], 10.0);
    final balances = await database.query(balanceTable);
    expect(_toCents(balances.single[balanceClose] as num), 1000);
  });

  test('atualiza o único lançamento do dia sem manter saldo órfão', () async {
    final balanceIdValue = await database.insert(balanceTable, {
      balanceAccountId: 1,
      balanceDate: ExtendedDate(2026, 8, 30).millisecondsSinceEpoch,
      balanceTransCount: 0,
      balanceOpen: 0.0,
      balanceClose: 0.0,
    });
    final transaction = createFakeTransaction(
      id: null,
      balanceId: balanceIdValue,
      accountId: 1,
      value: 10,
      date: ExtendedDate(2026, 8, 30),
    );
    transaction.transId = await database.insert(
      transactionsTable,
      transaction.toMap(),
    );
    final oldTransactionId = transaction.transId;
    transaction
      ..transDescription = 'updated transaction'
      ..transValue = 25;

    final newTransactionId = await repository.updateTransaction(transaction);

    expect(newTransactionId, isNot(oldTransactionId));
    final transactions = await database.query(transactionsTable);
    expect(transactions, hasLength(1));
    expect(transactions.single[transDescription], 'updated transaction');
    expect(transactions.single[transValue], 25.0);
    final balances = await database.query(balanceTable);
    expect(balances, hasLength(1));
    expect(
      transactions.single[transBalanceId],
      balances.single[balanceId],
    );
    expect(_toCents(balances.single[balanceClose] as num), 2500);
  });

  test('substitui uma transferência inteira na mesma transação', () async {
    final origin = createFakeTransaction(
      id: null,
      balanceId: null,
      accountId: 1,
      value: -25.50,
    );
    final originalResult = await repository.addTransfer(
      origin: origin,
      destinationAccountId: 2,
    );
    origin
      ..transDescription = 'updated transfer'
      ..transValue = -40;

    final updatedResult = await repository.updateTransfer(
      transaction: origin,
      destinationAccountId: 2,
    );

    expect(updatedResult.transferId, isNot(originalResult.transferId));
    final transfers = await database.query(transfersTable);
    expect(transfers, hasLength(1));
    final transactions = await database.query(
      transactionsTable,
      orderBy: transValue,
    );
    expect(transactions, hasLength(2));
    expect(transactions[0][transValue], -40.0);
    expect(transactions[1][transValue], 40.0);
    expect(
      transactions.every(
        (item) => item[transDescription] == 'updated transfer',
      ),
      isTrue,
    );
  });

  test('restaura a transferência anterior se a atualização falhar', () async {
    final origin = createFakeTransaction(
      id: null,
      balanceId: null,
      accountId: 1,
      value: -25.50,
    );
    final originalResult = await repository.addTransfer(
      origin: origin,
      destinationAccountId: 2,
    );
    await database.execute('''
      CREATE TRIGGER fail_transfer_update
      BEFORE INSERT ON $transactionsTable
      WHEN NEW.$transDescription = 'invalid transfer update'
      BEGIN
        SELECT RAISE(ABORT, 'transfer update failure');
      END
    ''');
    origin
      ..transDescription = 'invalid transfer update'
      ..transValue = -40;

    await expectLater(
      () => repository.updateTransfer(
        transaction: origin,
        destinationAccountId: 2,
      ),
      throwsA(anything),
    );

    final transfers = await database.query(transfersTable);
    expect(transfers, hasLength(1));
    expect(transfers.single[transferId], originalResult.transferId);
    final transactions = await database.query(
      transactionsTable,
      orderBy: transValue,
    );
    expect(transactions, hasLength(2));
    expect(transactions[0][transValue], -25.5);
    expect(transactions[1][transValue], 25.5);
    expect(
      transactions.every(
        (item) => item[transDescription] == 'Test transaction',
      ),
      isTrue,
    );
  });
}

int _toCents(num value) => (value.toDouble() * 100).round();

Future<int> _count(Database database, String table) async {
  final result =
      await database.rawQuery('SELECT COUNT(*) AS count FROM $table');
  return result.single['count'] as int;
}
