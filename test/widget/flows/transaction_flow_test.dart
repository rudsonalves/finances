import 'package:finances/common/constants/themes/app_icons.dart';
import 'package:finances/common/constants/themes/colors/custom_color.g.dart';
import 'package:finances/common/extensions/money_masked_text_controller.dart';
import 'package:finances/common/models/account_db_model.dart';
import 'package:finances/common/models/category_db_model.dart';
import 'package:finances/common/models/icons_model.dart';
import 'package:finances/features/categories/categories_controller.dart';
import 'package:finances/features/home_page/home_page_controller.dart';
import 'package:finances/features/transaction/transaction_controller.dart';
import 'package:finances/features/transaction/transaction_dialog.dart';
import 'package:finances/features/transaction/transaction_state.dart';
import 'package:finances/l10n/app_localizations.dart';
import 'package:finances/locator.dart';
import 'package:finances/repositories/category/abstract_category_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

class MockTransactionController extends Mock implements TransactionController {}

class MockHomePageController extends Mock implements HomePageController {}

class MockCategoriesController extends Mock implements CategoriesController {}

class FakeBuildContext extends Fake implements BuildContext {}

class TransactionFlowHost extends StatefulWidget {
  final TransactionController transactionController;
  final HomePageController homePageController;
  final CategoriesController categoriesController;

  const TransactionFlowHost({
    super.key,
    required this.transactionController,
    required this.homePageController,
    required this.categoriesController,
  });

  @override
  State<TransactionFlowHost> createState() => _TransactionFlowHostState();
}

class _TransactionFlowHostState extends State<TransactionFlowHost> {
  int transactionCount = 0;
  double balance = 0;

  Future<void> addTransaction() async {
    final added = await TransactionDialog.showTransactionDialog(
      context,
      controller: widget.transactionController,
      homePageController: widget.homePageController,
      categoriesController: widget.categoriesController,
    );

    if (!added || !mounted) return;

    setState(() {
      transactionCount++;
      balance -= 42.90;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            'Saldo: ${balance.toStringAsFixed(2)}',
            key: const Key('balance'),
          ),
          Text(
            'Transações: $transactionCount',
            key: const Key('transaction-count'),
          ),
          ElevatedButton(
            key: const Key('new-transaction'),
            onPressed: addTransaction,
            child: const Text('Nova transação'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockTransactionController transactionController;
  late MockHomePageController homePageController;
  late MockCategoriesController categoriesController;
  late MockAbstractCategoryRepository categoryRepository;

  late MoneyMaskedTextController amountController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController dateController;

  late AccountDbModel account;
  late CategoryDbModel category;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    transactionController = MockTransactionController();
    homePageController = MockHomePageController();
    categoriesController = MockCategoriesController();
    categoryRepository = MockAbstractCategoryRepository();

    amountController = MoneyMaskedTextController(initialValue: 0);
    descriptionController = TextEditingController();
    categoryController = TextEditingController();
    dateController = TextEditingController();

    final accountIcon = IconModel(
      iconId: 1,
      iconName: 'account_balance_wallet',
      iconFontFamily: IconsFontFamily.MaterialIcons,
    );

    account = AccountDbModel(
      accountId: 1,
      accountName: 'Conta principal',
      accountUserId: 'user-1',
      accountIcon: accountIcon,
    );

    category = CategoryDbModel(
      categoryId: 2,
      categoryName: 'Alimentação',
      categoryIcon: IconModel(
        iconId: 2,
        iconName: 'restaurant',
        iconFontFamily: IconsFontFamily.MaterialIcons,
      ),
    );

    when(() => categoryRepository.categoriesMap).thenReturn({
      category.categoryName: category,
    });

    locator.registerSingleton<AbstractCategoryRepository>(
      categoryRepository,
    );

    when(() => transactionController.init(null)).thenAnswer((_) async {});
    when(() => categoriesController.init()).thenAnswer((_) async {});

    when(() => transactionController.state)
        .thenReturn(TransactionStateSuccess());
    when(() => transactionController.accountsMap).thenReturn({1: account});
    when(() => transactionController.originAccount).thenReturn(account);
    when(() => transactionController.originAccountId).thenReturn(1);
    when(() => transactionController.destinyAccountId).thenReturn(null);
    when(() => transactionController.income).thenReturn(false);
    when(() => transactionController.repeat).thenReturn(false);
    when(() => transactionController.isTransfer).thenReturn(false);

    when(() => transactionController.amount).thenReturn(amountController);
    when(() => transactionController.description)
        .thenReturn(descriptionController);
    when(() => transactionController.category).thenReturn(categoryController);
    when(() => transactionController.date).thenReturn(dateController);

    when(() => homePageController.cacheDescriptions)
        .thenReturn(<String, int>{});

    when(
      () => transactionController.addTransactionsAction(
        any(),
        income: any(named: 'income'),
        repeat: any(named: 'repeat'),
      ),
    ).thenAnswer((invocation) async {
      final context = invocation.positionalArguments.first as BuildContext;

      Navigator.of(context).pop(true);
    });
  });

  tearDown(() async {
    amountController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    dateController.dispose();

    await locator.reset();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        extensions: [lightCustomColors],
      ),
      home: TransactionFlowHost(
        transactionController: transactionController,
        homePageController: homePageController,
        categoriesController: categoriesController,
      ),
    );
  }

  testWidgets(
    'abre o formulário, salva uma despesa e atualiza a tela inicial',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Saldo: 0.00'), findsOneWidget);
      expect(find.text('Transações: 0'), findsOneWidget);
      expect(find.byType(TransactionDialog), findsNothing);

      await tester.tap(find.byKey(const Key('new-transaction')));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDialog), findsOneWidget);

      final amountField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.controller == amountController,
      );
      final descriptionField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.controller == descriptionController,
      );

      await tester.enterText(amountField, '4290');
      await tester.enterText(descriptionField, 'Supermercado');

      final categoryDropdown = find.byType(DropdownButtonFormField<String>);

      await tester.ensureVisible(categoryDropdown);
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text(category.categoryName));
      await tester.pumpAndSettle();

      expect(categoryController.text, category.categoryName);
      expect(dateController.text, isNotEmpty);

      final dialogContext = tester.element(find.byType(TransactionDialog));
      final locale = AppLocalizations.of(dialogContext)!;
      final addButton = find.text(locale.transPageButtonAdd);

      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDialog), findsNothing);
      expect(find.text('Saldo: -42.90'), findsOneWidget);
      expect(find.text('Transações: 1'), findsOneWidget);

      verify(
        () => transactionController.addTransactionsAction(
          any(),
          income: false,
          repeat: false,
        ),
      ).called(1);
    },
  );
}
