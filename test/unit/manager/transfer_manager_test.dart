import 'dart:async';

import 'package:finances/manager/transfer_manager.dart';
import 'package:finances/repositories/financial_operation/abstract_financial_operation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures/model_fixtures.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  late MockAbstractFinancialOperationRepository operationRepository;
  late MockAbstractTransferRepository transferRepository;

  setUp(() async {
    operationRepository = MockAbstractFinancialOperationRepository();
    transferRepository = MockAbstractTransferRepository();
    await setupTestLocator(
      dependencies: TestDependencies(
        financialOperationRepository: operationRepository,
        transferRepository: transferRepository,
      ),
    );
  });

  tearDown(tearDownTestLocator);

  test('adiciona uma transferência entre contas diferentes', () async {
    final origin = createFakeTransaction(
      id: null,
      balanceId: null,
      accountId: 1,
      value: -50,
    );
    const operationResult = TransferOperationResult(
      transferId: 10,
      originTransactionId: 20,
      destinationTransactionId: 21,
    );
    when(
      () => operationRepository.addTransfer(
        origin: origin,
        destinationAccountId: 2,
      ),
    ).thenAnswer((_) async => operationResult);

    await TransferManager.add(
      transOrigin: origin,
      accountDestinyId: 2,
    );

    verify(
      () => operationRepository.addTransfer(
        origin: origin,
        destinationAccountId: 2,
      ),
    ).called(1);
  });

  test('rejeita transferência para a mesma conta', () async {
    final origin = createFakeTransaction(id: null, accountId: 1);

    await expectLater(
      () => TransferManager.add(
        transOrigin: origin,
        accountDestinyId: 1,
      ),
      throwsArgumentError,
    );
    verifyZeroInteractions(operationRepository);
  });

  test('propaga falha da operação financeira', () async {
    final origin = createFakeTransaction(id: null, accountId: 1);
    when(
      () => operationRepository.addTransfer(
        origin: origin,
        destinationAccountId: 2,
      ),
    ).thenThrow(Exception('write failed'));

    await expectLater(
      () => TransferManager.add(
        transOrigin: origin,
        accountDestinyId: 2,
      ),
      throwsException,
    );
  });

  test('rejeita nova gravação de uma transferência já persistida', () async {
    final origin = createFakeTransaction(
      id: 20,
      transferId: 10,
      accountId: 1,
    );

    await expectLater(
      () => TransferManager.add(
        transOrigin: origin,
        accountDestinyId: 2,
      ),
      throwsStateError,
    );
    verifyZeroInteractions(operationRepository);
  });

  test('bloqueia duas gravações simultâneas do mesmo objeto', () async {
    final origin = createFakeTransaction(id: null, accountId: 1);
    final pendingOperation = Completer<TransferOperationResult>();
    when(
      () => operationRepository.addTransfer(
        origin: origin,
        destinationAccountId: 2,
      ),
    ).thenAnswer((_) => pendingOperation.future);

    final firstCall = TransferManager.add(
      transOrigin: origin,
      accountDestinyId: 2,
    );
    await Future<void>.delayed(Duration.zero);

    await expectLater(
      () => TransferManager.add(
        transOrigin: origin,
        accountDestinyId: 2,
      ),
      throwsStateError,
    );

    pendingOperation.complete(
      const TransferOperationResult(
        transferId: 10,
        originTransactionId: 20,
        destinationTransactionId: 21,
      ),
    );
    await firstCall;
  });

  test('remove por meio da operação atômica', () async {
    final origin = createFakeTransaction(transferId: 10);
    when(() => operationRepository.removeTransfer(transferId: 10))
        .thenAnswer((_) async => 1);

    final result = await TransferManager.remove(origin);

    expect(result, 1);
    verify(() => operationRepository.removeTransfer(transferId: 10)).called(1);
  });

  test('atualiza por meio da operação atômica', () async {
    final transaction = createFakeTransaction(
      id: 20,
      transferId: 10,
      accountId: 1,
    );
    when(
      () => operationRepository.updateTransfer(
        transaction: transaction,
        destinationAccountId: 2,
      ),
    ).thenAnswer(
      (_) async => const TransferOperationResult(
        transferId: 11,
        originTransactionId: 22,
        destinationTransactionId: 23,
      ),
    );

    await TransferManager.update(
      newTransaction: transaction,
      accountDestinyId: 2,
    );

    verify(
      () => operationRepository.updateTransfer(
        transaction: transaction,
        destinationAccountId: 2,
      ),
    ).called(1);
  });
}
