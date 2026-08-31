import 'package:finances/common/current_models/current_account.dart';
import 'package:finances/common/current_models/current_user.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:finances/features/home_page/balance_card/balance_card_controller.dart';
import 'package:finances/features/home_page/home_page_controller.dart';
import 'package:finances/features/home_page/home_page_state.dart';
import 'package:finances/locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/model_fixtures.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/test_setup.dart';

class MockCurrentAccount extends Mock implements CurrentAccount {}

class MockCurrentUser extends Mock implements CurrentUser {}

class MockBalanceCardController extends Mock
    implements BalanceCardController {}

void main() {
  late MockAbstractTransactionRepository transactionRepository;
  late MockAbstractCategoryRepository categoryRepository;
  late MockCurrentAccount currentAccount;
  late MockCurrentUser currentUser;
  late MockBalanceCardController balanceCardController;
  late HomePageController controller;

  setUpAll(() {
    registerFallbackValue(ExtendedDate(2000));
  });

  setUp(() async {
    transactionRepository = MockAbstractTransactionRepository();
    categoryRepository = MockAbstractCategoryRepository();
    currentAccount = MockCurrentAccount();
    currentUser = MockCurrentUser();
    balanceCardController = MockBalanceCardController();

    await setupTestLocator(
      dependencies: TestDependencies(
        transactionRepository: transactionRepository,
        categoryRepository: categoryRepository,
      ),
    );
    locator
      ..registerSingleton<CurrentAccount>(currentAccount)
      ..registerSingleton<CurrentUser>(currentUser)
      ..registerSingleton<BalanceCardController>(balanceCardController);

    when(() => currentAccount.accountId).thenReturn(1);
    when(() => currentUser.userMaxTransactions).thenReturn(35);
    when(() => balanceCardController.futureTransactions)
        .thenReturn(FutureTrans.hide);
    when(() => categoryRepository.init()).thenAnswer((_) async {});
    when(
      () => transactionRepository.getNFromDate(
        startDate: any(named: 'startDate'),
        accountId: any(named: 'accountId'),
        maxTransactions: any(named: 'maxTransactions'),
      ),
    ).thenAnswer((_) async => []);
    when(() => balanceCardController.getBalance()).thenAnswer((_) async {});

    controller = HomePageController();
  });

  tearDown(() async {
    controller.dispose();
    await tearDownTestLocator();
  });

  group('HomePageController', () {
    test('init carrega transações e termina em sucesso', () async {
      final transaction = createFakeTransaction(id: 1, accountId: 1);
      when(
        () => transactionRepository.getNFromDate(
          startDate: any(named: 'startDate'),
          accountId: 1,
          maxTransactions: 35,
        ),
      ).thenAnswer((_) async => [transaction]);

      await controller.init();

      expect(controller.transactions, [transaction]);
      expect(controller.state, isA<HomePageStateSuccess>());
      expect(controller.haveMoreTransactions, isFalse);
    });

    test('erro no repositório termina em estado de erro', () async {
      when(
        () => transactionRepository.getNFromDate(
          startDate: any(named: 'startDate'),
          accountId: 1,
          maxTransactions: 35,
        ),
      ).thenThrow(Exception('Falha ao carregar transações'));

      await controller.getTransactions();

      expect(controller.transactions, isEmpty);
      expect(controller.state, isA<HomePageStateError>());
    });

    test('troca de conta recarrega saldo e transações', () async {
      final account = createFakeAccount(id: 2);

      await controller.changeCurrentAccount(account);

      verify(() => currentAccount.changeCurrenteAccount(account)).called(1);
      verify(() => balanceCardController.getBalance()).called(1);
      verify(
        () => transactionRepository.getNFromDate(
          startDate: any(named: 'startDate'),
          accountId: 1,
          maxTransactions: 35,
        ),
      ).called(1);
    });

    test('filtro por descrição seleciona somente itens compatíveis',
        () async {
      final market = createFakeTransaction(
        id: 1,
        description: 'Supermercado',
      );
      final salary = createFakeTransaction(
        id: 2,
        description: 'Salário',
      );
      when(
        () => transactionRepository.getNFromDate(
          startDate: any(named: 'startDate'),
          accountId: 1,
          maxTransactions: 35,
        ),
      ).thenAnswer((_) async => [market, salary]);
      await controller.getTransactions();

      await controller.setFilterValues(
        text: 'mercado',
        isDescription: true,
      );

      expect(controller.isFiltred, isTrue);
      expect(controller.filterTransactions(), [market]);
    });

    test('paginação mantém transações já carregadas', () async {
      final first = createFakeTransaction(id: 1);
      final second = createFakeTransaction(id: 2);
      int calls = 0;
      when(
        () => transactionRepository.getNFromDate(
          startDate: any(named: 'startDate'),
          accountId: 1,
          maxTransactions: 35,
        ),
      ).thenAnswer((_) async {
        calls++;
        return calls == 1 ? [first] : [second];
      });

      await controller.getTransactions();
      await controller.getTransactions(true);

      expect(controller.transactions, [first, second]);
    });
  });
}
