import 'package:finances/common/constants/themes/app_icons.dart';
import 'package:finances/common/current_models/current_account.dart';
import 'package:finances/common/current_models/current_user.dart';
import 'package:finances/common/models/account_db_model.dart';
import 'package:finances/common/models/balance_db_model.dart';
import 'package:finances/common/models/category_db_model.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:finances/common/models/icons_model.dart';
import 'package:finances/common/models/transaction_db_model.dart';
import 'package:finances/common/models/transfer_db_model.dart';
import 'package:finances/features/transaction/transaction_controller.dart';
import 'package:finances/features/transaction/transaction_state.dart';
import 'package:finances/locator.dart';
import 'package:finances/repositories/financial_operation/abstract_financial_operation_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_setup.dart';

void main() {
  late MockAbstractAccountRepository accountRepository;
  late MockAbstractCategoryRepository categoryRepository;
  late MockAbstractTransferRepository transferRepository;
  late MockAbstractBalanceRepository balanceRepository;
  late MockAbstractTransactionRepository transactionRepository;
  late MockAbstractFinancialOperationRepository financialOperationRepository;
  late AccountDbModel account;
  late AccountDbModel secondAccount;
  late CategoryDbModel category;
  late TransactionController controller;

  setUpAll(() {
    registerFallbackValue(ExtendedDate(2000));

    registerFallbackValue(
      TransactionDbModel(
        transAccountId: 1,
        transDescription: 'Fallback',
        transCategoryId: 2,
        transValue: 1,
        transDate: ExtendedDate(2000),
      ),
    );
  });

  setUp(() async {
    accountRepository = MockAbstractAccountRepository();
    categoryRepository = MockAbstractCategoryRepository();
    transferRepository = MockAbstractTransferRepository();
    balanceRepository = MockAbstractBalanceRepository();
    transactionRepository = MockAbstractTransactionRepository();
    financialOperationRepository = MockAbstractFinancialOperationRepository();

    final IconModel icon = IconModel(
      iconId: 1,
      iconName: 'wallet',
      iconFontFamily: IconsFontFamily.MaterialIcons,
    );

    account = AccountDbModel(
      accountId: 1,
      accountName: 'Conta principal',
      accountUserId: 'user-1',
      accountIcon: icon,
    );

    secondAccount = AccountDbModel(
      accountId: 2,
      accountName: 'Conta secundária',
      accountUserId: 'user-1',
      accountIcon: icon,
    );

    category = CategoryDbModel(
      categoryId: 2,
      categoryName: 'Alimentação',
      categoryIcon: icon,
    );

    when(() => accountRepository.accountsMap).thenReturn({
      account.accountId!: account,
      secondAccount.accountId!: secondAccount,
    });
    when(() => categoryRepository.categories).thenReturn([category]);
    when(() => categoryRepository.categoriesMap).thenReturn({
      category.categoryName: category,
    });
    when(() => categoryRepository.categoriesIdMap).thenReturn({
      category.categoryId!: category,
    });
    when(categoryRepository.init).thenAnswer((_) async {});

    await setupTestLocator(
      dependencies: TestDependencies(
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        transferRepository: transferRepository,
        balanceRepository: balanceRepository,
        transactionRepository: transactionRepository,
        financialOperationRepository: financialOperationRepository,
      ),
    );

    locator.registerSingleton<CurrentUser>(
      CurrentUser()..userLanguage = 'pt_BR',
    );
    locator.registerSingleton<CurrentAccount>(
      CurrentAccount.fromAccountDbModel(account),
    );

    controller = TransactionController();
  });

  tearDown(() async {
    controller.dispose();
    await tearDownTestLocator();
  });

  group('TransactionController.init', () {
    test('começa no estado inicial', () {
      expect(controller.state, isA<TransactionStateInitial>());
      expect(controller.originAccountId, 1);
      expect(controller.originAccount, same(account));
    });

    test('carrega categorias e transita de loading para success', () async {
      final List<Type> notifiedStates = [];

      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.init(null);

      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );
      expect(controller.state, isA<TransactionStateSuccess>());
      expect(controller.categories, [category]);
      expect(controller.categoriesNames, ['Alimentação']);
      expect(
        controller.accountsMap,
        {
          1: account,
          2: secondAccount,
        },
      );

      verify(categoryRepository.init).called(1);
    });

    test('restaura a conta de destino de uma transferência existente',
        () async {
      final TransactionDbModel transaction = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 1,
        transDescription: 'Transferência',
        transCategoryId: 1,
        transValue: -200,
        transStatus: TransStatus.transactionChecked,
        transTransferId: 50,
        transDate: ExtendedDate(2026, 8, 31, 10),
      );
      final TransferDbModel transfer = TransferDbModel(
        transferId: 50,
        transferTransId0: 10,
        transferTransId1: 11,
        transferAccount0: 1,
        transferAccount1: 2,
      );
      final CategoryDbModel transferCategory = CategoryDbModel(
        categoryId: 1,
        categoryName: 'Transferência',
        categoryIcon: category.categoryIcon,
      );

      when(() => transferRepository.getId(50))
          .thenAnswer((_) async => transfer);
      when(() => categoryRepository.getCategoryId(1))
          .thenReturn(transferCategory);

      await controller.init(transaction);

      expect(controller.categoryId, 1);
      expect(controller.isTransfer, isTrue);
      expect(controller.originAccountId, 1);
      expect(controller.destinyAccountId, 2);
      expect(controller.destinyAccount, same(secondAccount));
      expect(controller.state, isA<TransactionStateSuccess>());

      verify(() => transferRepository.getId(50)).called(1);
    });

    test('captura falha ao carregar categorias e termina em erro', () async {
      when(categoryRepository.init)
          .thenThrow(Exception('Falha ao carregar categorias'));

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.init(null);

      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );

      verify(categoryRepository.init).called(1);
    });

    test('termina em erro quando a transferência associada não existe',
        () async {
      final TransactionDbModel transaction = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 1,
        transDescription: 'Transferência inconsistente',
        transCategoryId: 1,
        transValue: -200,
        transStatus: TransStatus.transactionChecked,
        transTransferId: 999,
        transDate: ExtendedDate(2026, 8, 31, 10),
      );

      when(() => transferRepository.getId(999)).thenAnswer((_) async => null);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.init(transaction);

      expect(controller.state, isA<TransactionStateError>());
      expect(controller.destinyAccountId, isNull);
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );

      verify(() => transferRepository.getId(999)).called(1);
    });

    test('restaura a conta de origem da transação existente', () async {
      final TransactionDbModel transaction = TransactionDbModel(
        transId: 12,
        transBalanceId: 22,
        transAccountId: 2,
        transDescription: 'Compra na conta secundária',
        transCategoryId: 2,
        transValue: -50,
        transStatus: TransStatus.transactionChecked,
        transDate: ExtendedDate(2026, 8, 31, 10),
      );

      when(() => categoryRepository.getCategoryId(2)).thenReturn(category);

      expect(controller.originAccountId, 1);

      await controller.init(transaction);

      expect(controller.originAccountId, 2);
      expect(controller.originAccount, same(secondAccount));
      expect(controller.state, isA<TransactionStateSuccess>());
    });

    test('termina em erro quando a conta de origem não existe', () async {
      final TransactionDbModel transaction = TransactionDbModel(
        transId: 13,
        transBalanceId: 23,
        transAccountId: 999,
        transDescription: 'Transação inconsistente',
        transCategoryId: 2,
        transValue: -50,
        transStatus: TransStatus.transactionChecked,
        transDate: ExtendedDate(2026, 8, 31, 10),
      );

      when(() => categoryRepository.getCategoryId(2)).thenReturn(category);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.init(transaction);

      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );
    });
  });

  group('TransactionController tipo da transação', () {
    test('altera uma despesa para receita', () {
      final List<Type> notifiedStates = [];

      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      expect(controller.income, isFalse);

      controller.setIncome(true);

      expect(controller.income, isTrue);
      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );
    });

    test('alterna entre receita e despesa', () {
      expect(controller.income, isFalse);

      controller.toogleIncome();
      expect(controller.income, isTrue);

      controller.toogleIncome();
      expect(controller.income, isFalse);
    });

    test('selecionar categoria de receita atualiza categoria e tipo', () {
      final CategoryDbModel incomeCategory = CategoryDbModel(
        categoryId: 3,
        categoryName: 'Salário',
        categoryIcon: category.categoryIcon,
        categoryIsIncome: true,
      );

      controller.setCategoryByModel(incomeCategory);

      expect(controller.categoryId, 3);
      expect(controller.category.text, 'Salário');
      expect(controller.income, isTrue);
      expect(controller.isTransfer, isFalse);
      expect(controller.state, isA<TransactionStateSuccess>());
    });

    test('selecionar categoria de despesa atualiza categoria e tipo', () {
      controller.setCategoryByModel(category);

      expect(controller.categoryId, 2);
      expect(controller.category.text, 'Alimentação');
      expect(controller.income, isFalse);
      expect(controller.isTransfer, isFalse);
    });

    test('identifica a categoria reservada de transferência', () {
      final CategoryDbModel transferCategory = CategoryDbModel(
        categoryId: 1,
        categoryName: 'Transferência',
        categoryIcon: category.categoryIcon,
      );

      controller.setCategoryByModel(transferCategory);

      expect(controller.categoryId, 1);
      expect(controller.category.text, 'Transferência');
      expect(controller.isTransfer, isTrue);
    });

    test('alternar repetição notifica loading e success', () {
      final List<Type> notifiedStates = [];

      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      controller.toogleRepeat();

      expect(controller.repeat, isTrue);
      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );
    });
  });

  group('TransactionController contas da transferência', () {
    test('seleciona uma conta de destino diferente da origem', () {
      final List<Type> notifiedStates = [];

      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      controller.setDestinyAccountId(2);

      expect(controller.originAccountId, 1);
      expect(controller.destinyAccountId, 2);
      expect(controller.destinyAccount, same(secondAccount));
      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );
    });

    test('não permite usar a conta de origem como destino', () {
      controller.setDestinyAccountId(1);

      expect(controller.originAccountId, 1);
      expect(controller.destinyAccountId, isNull);
      expect(controller.state, isA<TransactionStateSuccess>());
    });

    test('limpa o destino quando ele passa a ser a conta de origem', () {
      controller.setDestinyAccountId(2);
      expect(controller.destinyAccountId, 2);

      controller.setOriginAccountId(2);

      expect(controller.originAccountId, 2);
      expect(controller.originAccount, same(secondAccount));
      expect(controller.destinyAccountId, isNull);
      expect(controller.state, isA<TransactionStateSuccess>());
    });

    test('permite limpar explicitamente a conta de destino', () {
      controller.setDestinyAccountId(2);
      expect(controller.destinyAccountId, 2);

      controller.setDestinyAccountId(null);

      expect(controller.destinyAccountId, isNull);
      expect(controller.destinyAccount, isNull);
    });
  });

  group('TransactionController seleção de categoria', () {
    test('seleciona categoria por identificador', () {
      when(() => categoryRepository.getCategoryId(2)).thenReturn(category);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      controller.setCategoryById(2);

      expect(controller.categoryId, 2);
      expect(controller.category.text, 'Alimentação');
      expect(controller.income, isFalse);
      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );

      verify(() => categoryRepository.getCategoryId(2)).called(1);
    });

    test('seleciona categoria por nome', () {
      controller.setCategoryByName('Alimentação');

      expect(controller.categoryId, 2);
      expect(controller.category.text, 'Alimentação');
      expect(controller.income, isFalse);
      expect(controller.state, isA<TransactionStateSuccess>());
    });

    test('ignora nome nulo sem notificar listeners', () {
      int notifications = 0;
      controller.addListener(() {
        notifications++;
      });

      controller.setCategoryByName(null);

      expect(controller.categoryId, isNull);
      expect(controller.state, isA<TransactionStateInitial>());
      expect(notifications, 0);
    });

    test('entra em estado de erro para nome inexistente', () {
      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      controller.setCategoryByName('Categoria inexistente');

      expect(controller.categoryId, isNull);
      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );
    });

    test('entra em estado de erro para identificador inexistente', () {
      when(() => categoryRepository.getCategoryId(999))
          .thenThrow(StateError('Categoria inexistente'));

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      controller.setCategoryById(999);

      expect(controller.categoryId, isNull);
      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );
    });
  });

  group('TransactionController.addCategory', () {
    test('adiciona categoria e termina em sucesso', () async {
      when(() => categoryRepository.addCategory(category))
          .thenAnswer((_) async {});

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addCategory(category);

      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );

      verify(() => categoryRepository.addCategory(category)).called(1);
    });

    test('captura erro do repositório e termina em erro', () async {
      when(() => categoryRepository.addCategory(category))
          .thenThrow(Exception('Falha ao adicionar categoria'));

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addCategory(category);

      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );

      verify(() => categoryRepository.addCategory(category)).called(1);
    });
  });

  group('TransactionController.init com transação existente', () {
    test('preenche os campos de uma despesa existente', () async {
      final TransactionDbModel transaction = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 1,
        transDescription: 'Compra no mercado',
        transCategoryId: 2,
        transValue: -123.45,
        transStatus: TransStatus.transactionChecked,
        transDate: ExtendedDate(2026, 8, 31, 10, 20),
      );

      when(() => categoryRepository.getCategoryId(2)).thenReturn(category);

      await controller.init(transaction);

      expect(controller.amount.numberValue, 123.45);
      expect(controller.description.text, 'Compra no mercado');
      expect(
        controller.date.text,
        transaction.transDate.toIso8601String(),
      );
      expect(controller.categoryId, 2);
      expect(controller.category.text, 'Alimentação');
      expect(controller.income, isFalse);
      expect(controller.state, isA<TransactionStateSuccess>());

      verify(categoryRepository.init).called(1);
      verify(() => categoryRepository.getCategoryId(2)).called(1);
    });

    test('restaura o tipo de uma receita existente', () async {
      final CategoryDbModel incomeCategory = CategoryDbModel(
        categoryId: 3,
        categoryName: 'Salário',
        categoryIcon: category.categoryIcon,
        categoryIsIncome: true,
      );
      final TransactionDbModel transaction = TransactionDbModel(
        transId: 11,
        transBalanceId: 21,
        transAccountId: 1,
        transDescription: 'Salário',
        transCategoryId: 3,
        transValue: 5000,
        transStatus: TransStatus.transactionChecked,
        transDate: ExtendedDate(2026, 8, 31, 8),
      );

      when(() => categoryRepository.getCategoryId(3))
          .thenReturn(incomeCategory);

      await controller.init(transaction);

      expect(controller.amount.numberValue, 5000);
      expect(controller.categoryId, 3);
      expect(controller.category.text, 'Salário');
      expect(controller.income, isTrue);
      expect(controller.state, isA<TransactionStateSuccess>());
    });
  });

  group('TransactionController.addTransactionsAction', () {
    testWidgets('salva uma nova despesa e fecha a tela com sucesso', (
      WidgetTester tester,
    ) async {
      final BalanceDbModel balance = BalanceDbModel(
        balanceId: 20,
        balanceAccountId: 1,
        balanceDate: ExtendedDate(2026, 8, 31),
      );
      TransactionDbModel? insertedTransaction;

      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenAnswer((_) async => balance);
      when(
        () => transactionRepository.insert(any()),
      ).thenAnswer((Invocation invocation) async {
        insertedTransaction =
            invocation.positionalArguments.first as TransactionDbModel;
        return 30;
      });
      when(() => categoryRepository.getIdByName('Alimentação')).thenReturn(2);

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const SizedBox(),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            pageContext = context;
            return const SizedBox(
              key: ValueKey<String>('transaction-page'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      controller.amount.updateValue(123.45);
      controller.description.text = 'Compra no mercado';
      controller.date.text = '2026-08-31T10:20:00.000000';
      controller.setCategoryByModel(category);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addTransactionsAction(
        pageContext,
        income: false,
        repeat: false,
      );
      await tester.pumpAndSettle();

      expect(insertedTransaction, isNotNull);
      expect(insertedTransaction!.transId, isNull);
      expect(insertedTransaction!.transBalanceId, 20);
      expect(insertedTransaction!.transAccountId, 1);
      expect(insertedTransaction!.transDescription, 'Compra no mercado');
      expect(insertedTransaction!.transCategoryId, 2);
      expect(insertedTransaction!.transValue, -123.45);
      expect(
        insertedTransaction!.transDate,
        ExtendedDate(2026, 8, 31, 10, 20),
      );
      expect(
        insertedTransaction!.transStatus,
        TransStatus.transactionNotChecked,
      );

      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );
      expect(
        find.byKey(const ValueKey<String>('transaction-page')),
        findsNothing,
      );

      verify(() => transactionRepository.insert(any())).called(1);
    });

    testWidgets('mantém a tela aberta quando o salvamento falha', (
      WidgetTester tester,
    ) async {
      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenThrow(Exception('Falha ao carregar saldo'));
      when(() => categoryRepository.getIdByName('Alimentação')).thenReturn(2);

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const SizedBox(),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            pageContext = context;
            return const SizedBox(
              key: ValueKey<String>('transaction-page'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      controller.amount.updateValue(123.45);
      controller.description.text = 'Compra no mercado';
      controller.date.text = '2026-08-31T10:20:00.000000';
      controller.setCategoryByModel(category);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addTransactionsAction(
        pageContext,
        income: false,
        repeat: false,
      );
      await tester.pumpAndSettle();

      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );
      expect(
        find.byKey(const ValueKey<String>('transaction-page')),
        findsOneWidget,
      );

      verifyNever(() => transactionRepository.insert(any()));
    });

    testWidgets('atualiza uma transação existente e fecha a tela', (
      WidgetTester tester,
    ) async {
      final TransactionDbModel existingTransaction = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 1,
        transDescription: 'Descrição antiga',
        transCategoryId: 2,
        transValue: -50,
        transStatus: TransStatus.transactionChecked,
        transDate: ExtendedDate(2026, 8, 30, 9),
      );
      TransactionDbModel? updatedTransaction;

      when(() => categoryRepository.getCategoryId(2)).thenReturn(category);
      when(() => categoryRepository.getIdByName('Alimentação')).thenReturn(2);
      when(
        () => financialOperationRepository.updateTransaction(any()),
      ).thenAnswer((Invocation invocation) async {
        updatedTransaction =
            invocation.positionalArguments.first as TransactionDbModel;
        return 30;
      });

      await controller.init(existingTransaction);

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const SizedBox(),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            pageContext = context;
            return const SizedBox(
              key: ValueKey<String>('transaction-page'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      controller.amount.updateValue(75.50);
      controller.description.text = 'Descrição atualizada';
      controller.date.text = '2026-09-01T11:30:00.000000';

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addTransactionsAction(
        pageContext,
        income: false,
        repeat: false,
      );
      await tester.pumpAndSettle();

      expect(updatedTransaction, isNotNull);
      expect(updatedTransaction!.transId, 10);
      expect(updatedTransaction!.transAccountId, 1);
      expect(updatedTransaction!.transDescription, 'Descrição atualizada');
      expect(updatedTransaction!.transCategoryId, 2);
      expect(updatedTransaction!.transValue, -75.50);
      expect(
        updatedTransaction!.transDate,
        ExtendedDate(2026, 9, 1, 11, 30),
      );
      expect(
        updatedTransaction!.transStatus,
        TransStatus.transactionNotChecked,
      );

      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );
      expect(
        find.byKey(const ValueKey<String>('transaction-page')),
        findsNothing,
      );

      verify(
        () => financialOperationRepository.updateTransaction(any()),
      ).called(1);
      verifyNever(() => transactionRepository.insert(any()));
    });

    testWidgets('salva uma nova transferência entre contas diferentes', (
      WidgetTester tester,
    ) async {
      final CategoryDbModel transferCategory = CategoryDbModel(
        categoryId: 1,
        categoryName: 'Transferência',
        categoryIcon: category.categoryIcon,
      );
      TransactionDbModel? transferOrigin;

      when(() => categoryRepository.getIdByName('Transferência')).thenReturn(1);
      when(
        () => financialOperationRepository.addTransfer(
          origin: any(named: 'origin'),
          destinationAccountId: 2,
        ),
      ).thenAnswer((Invocation invocation) async {
        transferOrigin =
            invocation.namedArguments[#origin] as TransactionDbModel;

        return const TransferOperationResult(
          transferId: 50,
          originTransactionId: 60,
          destinationTransactionId: 61,
        );
      });

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const SizedBox(),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            pageContext = context;
            return const SizedBox(
              key: ValueKey<String>('transaction-page'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      controller.amount.updateValue(200);
      controller.description.text = 'Transferência entre contas';
      controller.date.text = '2026-09-01T11:30:00.000000';
      controller.setCategoryByModel(transferCategory);
      controller.setDestinyAccountId(2);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addTransactionsAction(
        pageContext,
        income: false,
        repeat: false,
      );
      await tester.pumpAndSettle();

      expect(transferOrigin, isNotNull);
      expect(transferOrigin!.transId, isNull);
      expect(transferOrigin!.transAccountId, 1);
      expect(transferOrigin!.transCategoryId, 1);
      expect(transferOrigin!.transValue, -200);
      expect(transferOrigin!.transTransferId, isNull);
      expect(controller.destinyAccountId, 2);
      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateSuccess,
        ],
      );
      expect(
        find.byKey(const ValueKey<String>('transaction-page')),
        findsNothing,
      );

      verify(
        () => financialOperationRepository.addTransfer(
          origin: any(named: 'origin'),
          destinationAccountId: 2,
        ),
      ).called(1);
      verifyNever(() => transactionRepository.insert(any()));
    });

    testWidgets('cria todas as parcelas mensais de uma transação recorrente', (
      WidgetTester tester,
    ) async {
      final List<TransactionDbModel> insertedTransactions = [];

      when(
        () => balanceRepository.getInDate(
          date: any(named: 'date'),
          accountId: 1,
        ),
      ).thenAnswer((Invocation invocation) async {
        final ExtendedDate date =
            invocation.namedArguments[#date] as ExtendedDate;

        return BalanceDbModel(
          balanceId: date.month,
          balanceAccountId: 1,
          balanceDate: date,
        );
      });
      when(
        () => transactionRepository.insert(any()),
      ).thenAnswer((Invocation invocation) async {
        final TransactionDbModel transaction =
            invocation.positionalArguments.first as TransactionDbModel;
        insertedTransactions.add(transaction);
        return insertedTransactions.length;
      });
      when(() => categoryRepository.getIdByName('Alimentação')).thenReturn(2);

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const SizedBox(),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            pageContext = context;
            return const SizedBox(
              key: ValueKey<String>('transaction-page'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      controller.amount.updateValue(100);
      controller.description.text = 'Assinatura';
      controller.date.text = '2026-09-01T10:00:00.000000';
      controller.installments.text = 'x 3';
      controller.setCategoryByModel(category);
      controller.toogleRepeat();

      await controller.addTransactionsAction(
        pageContext,
        income: false,
        repeat: true,
      );
      await tester.pumpAndSettle();

      expect(insertedTransactions, hasLength(3));

      expect(insertedTransactions[0].transDescription, 'Assinatura (1/3)');
      expect(insertedTransactions[1].transDescription, 'Assinatura (2/3)');
      expect(insertedTransactions[2].transDescription, 'Assinatura (3/3)');

      expect(
        insertedTransactions[0].transDate,
        ExtendedDate(2026, 9, 1, 10),
      );
      expect(
        insertedTransactions[1].transDate,
        ExtendedDate(2026, 10, 1, 10),
      );
      expect(
        insertedTransactions[2].transDate,
        ExtendedDate(2026, 11, 1, 10),
      );

      expect(
        insertedTransactions.map((transaction) => transaction.transValue),
        [-100, -100, -100],
      );
      expect(controller.state, isA<TransactionStateSuccess>());
      expect(
        find.byKey(const ValueKey<String>('transaction-page')),
        findsNothing,
      );

      verify(() => transactionRepository.insert(any())).called(3);
    });

    testWidgets('rejeita uma recorrência com zero parcelas', (
      WidgetTester tester,
    ) async {
      when(() => categoryRepository.getIdByName('Alimentação')).thenReturn(2);

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const SizedBox(),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            pageContext = context;
            return const SizedBox(
              key: ValueKey<String>('transaction-page'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      controller.amount.updateValue(100);
      controller.description.text = 'Assinatura';
      controller.date.text = '2026-09-01T10:00:00.000000';
      controller.installments.text = 'x 0';
      controller.setCategoryByModel(category);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addTransactionsAction(
        pageContext,
        income: false,
        repeat: true,
      );
      await tester.pumpAndSettle();

      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );
      expect(
        find.byKey(const ValueKey<String>('transaction-page')),
        findsOneWidget,
      );

      verifyNever(() => balanceRepository.getInDate(
            date: any(named: 'date'),
            accountId: any(named: 'accountId'),
          ));
      verifyNever(() => transactionRepository.insert(any()));
    });

    testWidgets('rejeita texto de parcelas inválido', (
      WidgetTester tester,
    ) async {
      when(() => categoryRepository.getIdByName('Alimentação')).thenReturn(2);

      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              pageContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      controller.amount.updateValue(100);
      controller.description.text = 'Assinatura';
      controller.date.text = '2026-09-01T10:00:00.000000';
      controller.installments.text = 'valor inválido';
      controller.setCategoryByModel(category);

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.addTransactionsAction(
        pageContext,
        income: false,
        repeat: true,
      );

      expect(controller.state, isA<TransactionStateError>());
      expect(
        notifiedStates,
        [
          TransactionStateLoading,
          TransactionStateError,
        ],
      );

      verifyNever(() => balanceRepository.getInDate(
            date: any(named: 'date'),
            accountId: any(named: 'accountId'),
          ));
      verifyNever(() => transactionRepository.insert(any()));
    });
  });
}
