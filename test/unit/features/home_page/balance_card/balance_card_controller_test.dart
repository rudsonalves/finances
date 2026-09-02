import 'package:finances/common/current_models/current_balance.dart';
import 'package:finances/common/models/card_balance_model.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:finances/features/home_page/balance_card/balance_card_controller.dart';
import 'package:finances/features/home_page/balance_card/balance_cart_state.dart';
import 'package:finances/features/home_page/home_page_controller.dart';
import 'package:finances/locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_setup.dart';

class MockCurrentBalance extends Mock implements CurrentBalance {}

class MockHomePageController extends Mock implements HomePageController {}

void main() {
  late MockAbstractTransactionRepository transactionRepository;
  late MockAbstractAccountRepository accountRepository;
  late MockCurrentBalance currentBalance;
  late MockHomePageController homePageController;
  late BalanceCardController controller;

  setUpAll(() {
    registerFallbackValue(CardBalanceModel(incomes: 0, expanses: 0));
    registerFallbackValue(ExtendedDate(2000));
  });

  setUp(() async {
    transactionRepository = MockAbstractTransactionRepository();
    accountRepository = MockAbstractAccountRepository();
    currentBalance = MockCurrentBalance();
    homePageController = MockHomePageController();

    await setupTestLocator(
      dependencies: TestDependencies(
        transactionRepository: transactionRepository,
        accountRepository: accountRepository,
      ),
    );
    locator
      ..registerSingleton<CurrentBalance>(currentBalance)
      ..registerSingleton<HomePageController>(homePageController);

    when(() => currentBalance.start()).thenAnswer((_) async {});
    when(() => homePageController.getTransactions()).thenAnswer((_) async {});
    when(() => accountRepository.accountsList).thenReturn([]);
    when(() => accountRepository.accountsMap).thenReturn({});
    when(
      () => transactionRepository.getCardBalance(
        cardBalance: any(named: 'cardBalance'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async {});

    controller = BalanceCardController();
  });

  tearDown(() async {
    controller.dispose();
    await tearDownTestLocator();
  });

  group('BalanceCardController', () {
    testWidgets('carrega o saldo e termina em sucesso', (tester) async {
      when(
        () => transactionRepository.getCardBalance(
          cardBalance: any(named: 'cardBalance'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((invocation) async {
        final balance = invocation.namedArguments[#cardBalance]
            as CardBalanceModel;
        balance.incomes = 250;
        balance.expanses = 80;
      });

      await controller.getBalance();
      await tester.pump();

      expect(controller.state, isA<BalanceCardStateSuccess>());
      expect(controller.balance.incomes, 250);
      expect(controller.balance.expanses, 80);
      verify(() => currentBalance.start()).called(1);
    });

    testWidgets('falha ao carregar termina em erro', (tester) async {
      when(
        () => transactionRepository.getCardBalance(
          cardBalance: any(named: 'cardBalance'),
          date: any(named: 'date'),
        ),
      ).thenThrow(Exception('Falha ao calcular saldo'));

      await controller.getBalance();
      await tester.pump();

      expect(controller.state, isA<BalanceCardStateError>());
      verifyNever(() => currentBalance.start());
    });

    testWidgets('troca o mês e aguarda o recarregamento', (tester) async {
      final initialDate = controller.balanceDate;

      await controller.nextMonth();
      await tester.pump();

      expect(controller.balanceDate.year, initialDate.nextMonth().year);
      expect(controller.balanceDate.month, initialDate.nextMonth().month);
      verify(
        () => transactionRepository.getCardBalance(
          cardBalance: any(named: 'cardBalance'),
          date: any(named: 'date'),
        ),
      ).called(1);
    });

    testWidgets('alterna a exibição dos valores', (tester) async {
      expect(controller.transStatusCheck, isFalse);

      final future = controller.toggleTransStatusCheck();
      await tester.pump(const Duration(milliseconds: 50));
      await future;
      await tester.pump();

      expect(controller.transStatusCheck, isTrue);
      expect(controller.state, isA<BalanceCardStateSuccess>());
    });

    testWidgets('troca o período de transações futuras e recarrega a Home',
        (tester) async {
      final future =
          controller.changeFutureTransactions(FutureTrans.month);
      await tester.pump(const Duration(milliseconds: 50));
      await future;
      await tester.pump();

      expect(controller.futureTransactions, FutureTrans.month);
      expect(controller.isFutureTrans(FutureTrans.month), isTrue);
      expect(controller.state, isA<BalanceCardStateSuccess>());
      verify(() => homePageController.getTransactions()).called(1);
    });

    testWidgets('setBalanceDate preserva a data escolhida', (tester) async {
      final date = ExtendedDate(2026, 2, 15);

      await controller.setBalanceDate(date);
      await tester.pump();

      expect(controller.balanceDate, same(date));
      expect(controller.state, isA<BalanceCardStateSuccess>());
    });
  });
}
