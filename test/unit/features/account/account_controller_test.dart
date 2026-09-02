import 'dart:async';

import 'package:finances/common/models/balance_db_model.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:finances/features/account/account_controller.dart';
import 'package:finances/features/account/account_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/model_fixtures.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/test_setup.dart';

void main() {
  late MockAbstractAccountRepository accountRepository;
  late MockAbstractBalanceRepository balanceRepository;
  late AccountController controller;

  setUpAll(() {
    registerFallbackValue(ExtendedDate(2000));
  });

  setUp(() async {
    accountRepository = MockAbstractAccountRepository();
    balanceRepository = MockAbstractBalanceRepository();

    await setupTestLocator(
      dependencies: TestDependencies(
        accountRepository: accountRepository,
        balanceRepository: balanceRepository,
      ),
    );

    controller = AccountController();
  });

  tearDown(() async {
    controller.dispose();
    await tearDownTestLocator();
  });

  group('AccountController', () {
    test('começa no estado inicial e sem saldos', () {
      when(() => accountRepository.accountsList).thenReturn([]);

      expect(controller.state, isA<AccountStateInitial>());
      expect(controller.accounts, isEmpty);
      expect(controller.balances, isEmpty);
      expect(controller.totalBalance, 0);
    });

    test('carrega os saldos e calcula o total', () async {
      final firstAccount = createFakeAccount(
        id: 1,
        name: 'Conta principal',
      );
      final secondAccount = createFakeAccount(
        id: 2,
        name: 'Conta secundária',
      );

      when(() => accountRepository.accountsList)
          .thenReturn([firstAccount, secondAccount]);
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenAnswer(
        (_) async => createFakeBalance(
          id: 10,
          accountId: 1,
          closingBalance: 150.25,
        ),
      );
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 2,
        ),
      ).thenAnswer(
        (_) async => createFakeBalance(
          id: 11,
          accountId: 2,
          closingBalance: -50.25,
        ),
      );

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.getAllBalances();

      expect(controller.accounts, [firstAccount, secondAccount]);
      expect(controller.balances, [150.25, -50.25]);
      expect(controller.totalBalance, 100);
      expect(controller.state, isA<AccountStateSuccess>());
      expect(
        notifiedStates,
        [
          AccountStateLoading,
          AccountStateSuccess,
        ],
      );
    });

    test('considera zero quando uma conta ainda não possui saldo', () async {
      final account = createFakeAccount(id: 1);

      when(() => accountRepository.accountsList).thenReturn([account]);
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenAnswer((_) async => null);

      await controller.getAllBalances();

      expect(controller.balances, [0]);
      expect(controller.totalBalance, 0);
      expect(controller.state, isA<AccountStateSuccess>());
    });

    test('init aguarda a conclusão do carregamento', () async {
      final account = createFakeAccount(id: 1);
      final Completer<BalanceDbModel?> balanceCompleter =
          Completer<BalanceDbModel?>();

      when(() => accountRepository.accountsList).thenReturn([account]);
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenAnswer((_) => balanceCompleter.future);

      bool initCompleted = false;
      final Future<void> initFuture = controller.init().then((_) {
        initCompleted = true;
      });

      await Future<void>.delayed(Duration.zero);

      expect(controller.state, isA<AccountStateLoading>());
      expect(initCompleted, isFalse);

      balanceCompleter.complete(
        createFakeBalance(
          id: 10,
          accountId: 1,
          closingBalance: 100,
        ),
      );

      await initFuture;

      expect(initCompleted, isTrue);
      expect(controller.balances, [100]);
      expect(controller.state, isA<AccountStateSuccess>());
    });

    test('descarta saldos parciais quando o carregamento falha', () async {
      final firstAccount = createFakeAccount(
        id: 1,
        name: 'Conta principal',
      );
      final secondAccount = createFakeAccount(
        id: 2,
        name: 'Conta secundária',
      );

      when(() => accountRepository.accountsList)
          .thenReturn([firstAccount, secondAccount]);
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenAnswer(
        (_) async => createFakeBalance(
          id: 10,
          accountId: 1,
          closingBalance: 100,
        ),
      );
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 2,
        ),
      ).thenThrow(Exception('Falha ao carregar o segundo saldo'));

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.getAllBalances();

      expect(controller.balances, isEmpty);
      expect(controller.totalBalance, 0);
      expect(controller.state, isA<AccountStateError>());
      expect(
        notifiedStates,
        [
          AccountStateLoading,
          AccountStateError,
        ],
      );
    });

    test('preserva os últimos saldos válidos quando o refresh falha', () async {
      final account = createFakeAccount(id: 1);

      when(() => accountRepository.accountsList).thenReturn([account]);
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenAnswer(
        (_) async => createFakeBalance(
          id: 10,
          accountId: 1,
          closingBalance: 150,
        ),
      );

      await controller.getAllBalances();

      expect(controller.balances, [150]);
      expect(controller.totalBalance, 150);
      expect(controller.state, isA<AccountStateSuccess>());

      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenThrow(Exception('Falha durante atualização'));

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.getAllBalances();

      expect(controller.balances, [150]);
      expect(controller.totalBalance, 150);
      expect(controller.state, isA<AccountStateError>());
      expect(
        notifiedStates,
        [
          AccountStateLoading,
          AccountStateError,
        ],
      );
    });
  });
}
