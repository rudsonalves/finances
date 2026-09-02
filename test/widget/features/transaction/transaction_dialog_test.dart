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

import '../../../helpers/mocks.dart';

class MockTransactionController extends Mock implements TransactionController {}

class MockHomePageController extends Mock implements HomePageController {}

class MockCategoriesController extends Mock implements CategoriesController {}

class FakeBuildContext extends Fake implements BuildContext {}

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
  late bool income;
  VoidCallback? transactionListener;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(() {});
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

    final icon = IconModel(
      iconId: 1,
      iconName: 'account_balance_wallet',
      iconFontFamily: IconsFontFamily.MaterialIcons,
    );

    account = AccountDbModel(
      accountId: 1,
      accountName: 'Conta principal',
      accountUserId: 'user-1',
      accountIcon: icon,
    );

    category = CategoryDbModel(
      categoryId: 2,
      categoryName: 'Alimentação',
      categoryIcon: IconModel(
        iconId: 2,
        iconName: 'restaurant',
        iconFontFamily: IconsFontFamily.MaterialIcons,
        iconColor: 0xFFAA5500,
      ),
    );

    income = false;
    transactionListener = null;

    when(() => categoryRepository.categoriesMap).thenReturn(
      <String, CategoryDbModel>{
        category.categoryName: category,
      },
    );

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
    when(() => transactionController.income).thenAnswer((_) => income);
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
      () => transactionController.addListener(any()),
    ).thenAnswer((invocation) {
      transactionListener =
          invocation.positionalArguments.first as VoidCallback;
    });

    when(
      () => transactionController.removeListener(any()),
    ).thenAnswer((_) {});

    when(
      () => transactionController.setIncome(any()),
    ).thenAnswer((invocation) {
      income = invocation.positionalArguments.first as bool;
      transactionListener?.call();
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
      home: Scaffold(
        body: TransactionDialog(
          controller: transactionController,
          homePageController: homePageController,
          categoriesController: categoriesController,
        ),
      ),
    );
  }

  group('TransactionDialog', () {
    testWidgets(
      'valida os campos obrigatórios e inicializa automaticamente a data',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final dialogFinder = find.byType(TransactionDialog);
        final locale = AppLocalizations.of(
          tester.element(dialogFinder),
        )!;

        final addButton = find.text(locale.transPageButtonAdd);

        await tester.ensureVisible(addButton);
        await tester.tap(addButton);
        await tester.pump();

        expect(find.text(locale.transValidatorAmountGt0), findsOneWidget);
        expect(
          find.text(locale.transValidatorDescriptionEmpty),
          findsOneWidget,
        );
        expect(find.text(locale.transValidatorCategory), findsOneWidget);
        expect(dateController.text, isNotEmpty);
        expect(DateTime.tryParse(dateController.text), isNotNull);
        expect(find.text(locale.transValidatorDateEmpty), findsNothing);
        expect(find.text(locale.transValidatorDateValid), findsNothing);

        verifyNever(
          () => transactionController.addTransactionsAction(
            any(),
            income: any(named: 'income'),
            repeat: any(named: 'repeat'),
          ),
        );
      },
    );

    testWidgets(
      'seleciona uma categoria e apresenta seu ícone',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final dropdown = find.byType(DropdownButtonFormField<String>);

        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        expect(find.text(category.categoryName), findsOneWidget);

        await tester.tap(find.text(category.categoryName));
        await tester.pumpAndSettle();

        expect(categoryController.text, category.categoryName);

        verify(
          () => transactionController.setCategoryByName(
            category.categoryName,
          ),
        ).called(1);

        final categoryIcon = AppIcons.iconData(
          category.categoryIcon.iconName,
          category.categoryIcon.iconFontFamily,
        );

        expect(find.byIcon(categoryIcon!), findsOneWidget);
      },
    );

    testWidgets(
      'alterna entre despesa e receita e atualiza as cores',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(TransactionDialog));
        final locale = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final customColors = theme.extension<CustomColors>()!;

        final incomeButtonFinder = find.widgetWithText(
          TextButton,
          locale.rowOfTwoBottonsIncome,
        );
        final expenseButtonFinder = find.widgetWithText(
          TextButton,
          locale.rowOfTwoBottonsExpense,
        );
        final amountFieldFinder = find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.controller == amountController,
        );

        TextButton incomeButton = tester.widget<TextButton>(incomeButtonFinder);
        TextButton expenseButton =
            tester.widget<TextButton>(expenseButtonFinder);
        TextField amountField = tester.widget<TextField>(amountFieldFinder);

        expect(income, isFalse);
        expect(
          incomeButton.style?.backgroundColor?.resolve({}),
          Colors.transparent,
        );
        expect(
          expenseButton.style?.backgroundColor?.resolve({}),
          theme.colorScheme.secondaryContainer,
        );
        expect(amountField.style?.color, customColors.minusred);
        expect(find.byIcon(Icons.thumb_down), findsOneWidget);

        await tester.tap(incomeButtonFinder);
        await tester.pump();

        expect(income, isTrue);
        verify(() => transactionController.setIncome(true)).called(1);

        incomeButton = tester.widget<TextButton>(incomeButtonFinder);
        expenseButton = tester.widget<TextButton>(expenseButtonFinder);
        amountField = tester.widget<TextField>(amountFieldFinder);

        expect(
          incomeButton.style?.backgroundColor?.resolve({}),
          theme.colorScheme.secondaryContainer,
        );
        expect(
          expenseButton.style?.backgroundColor?.resolve({}),
          Colors.transparent,
        );
        expect(amountField.style?.color, customColors.lowgreen);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      },
    );
  });
}
