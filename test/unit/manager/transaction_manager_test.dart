import 'package:finances/common/models/extends_date.dart';
import 'package:finances/manager/transaction_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures/model_fixtures.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  late MockAbstractBalanceRepository balanceRepository;
  late MockAbstractTransactionRepository transactionRepository;

  setUpAll(() {
    registerFallbackValue(ExtendedDate(2000));
  });

  setUp(() async {
    balanceRepository = MockAbstractBalanceRepository();
    transactionRepository = MockAbstractTransactionRepository();

    await setupTestLocator(
      dependencies: TestDependencies(
        balanceRepository: balanceRepository,
        transactionRepository: transactionRepository,
      ),
    );
  });

  tearDown(tearDownTestLocator);

  group('TransactionManager.addNew', () {
    for (final value in [100.0, -100.0]) {
      test('associa o balanço e insere valor $value', () async {
        final transaction = createFakeTransaction(
          id: null,
          balanceId: null,
          accountId: 2,
          value: value,
          date: ExtendedDate(2026, 8, 31, 14),
        );

        final balance = createFakeBalance(
          id: 20,
          accountId: 2,
          date: ExtendedDate(2026, 8, 31),
        );

        when(
          () => balanceRepository.getInDate(
            date: any(named: 'date'),
            accountId: 2,
          ),
        ).thenAnswer((_) async => balance);

        when(
          () => transactionRepository.insert(transaction),
        ).thenAnswer((_) async {
          transaction.transId = 30;
          return 30;
        });

        await TransactionManager.addNew(transaction);

        expect(transaction.transBalanceId, 20);
        expect(transaction.transId, 30);
        expect(transaction.transValue, value);
        verify(() => transactionRepository.insert(transaction)).called(1);
      });
    }
  });

  group('TransactionManager.removeByValues', () {
    test('remove a transação e depois o balanço vazio', () async {
      when(() => transactionRepository.deleteById(30))
          .thenAnswer((_) async => 1);
      when(() => balanceRepository.deleteEmptyBalance(20))
          .thenAnswer((_) async {});

      final result = await TransactionManager.removeByValues(
        id: 30,
        balanceId: 20,
      );

      expect(result, 1);
      verifyInOrder([
        () => transactionRepository.deleteById(30),
        () => balanceRepository.deleteEmptyBalance(20),
      ]);
    });

    test('não remove o balanço quando a exclusão falha', () async {
      when(() => transactionRepository.deleteById(30))
          .thenThrow(Exception('delete failed'));

      await expectLater(
        () => TransactionManager.removeByValues(
          id: 30,
          balanceId: 20,
        ),
        throwsException,
      );

      verifyNever(() => balanceRepository.deleteEmptyBalance(any()));
    });
  });

  test('updateTransaction delega para a operação atômica', () async {
    final operationRepository = MockAbstractFinancialOperationRepository();
    await setupTestLocator(
      dependencies: TestDependencies(
        balanceRepository: balanceRepository,
        transactionRepository: transactionRepository,
        financialOperationRepository: operationRepository,
      ),
    );
    final transaction = createFakeTransaction(id: 30);
    when(() => operationRepository.updateTransaction(transaction))
        .thenAnswer((_) async => 31);

    final result = await TransactionManager.updateTransaction(transaction);

    expect(result, 31);
    verify(() => operationRepository.updateTransaction(transaction)).called(1);
  });
}
