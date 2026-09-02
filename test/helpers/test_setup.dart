import 'package:finances/locator.dart';
import 'package:finances/repositories/account/abstract_account_repository.dart';
import 'package:finances/repositories/balance/abstract_balance_repository.dart';
import 'package:finances/repositories/category/abstract_category_repository.dart';
import 'package:finances/repositories/financial_operation/abstract_financial_operation_repository.dart';
import 'package:finances/repositories/transaction/abstract_transaction_repository.dart';
import 'package:finances/repositories/transfer/abstract_transfer_repository.dart';
import 'package:finances/repositories/user/abstract_user_repository.dart';
import 'package:finances/services/authentication/auth_service.dart';
import 'package:finances/store/database/database_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'mocks.dart';

class TestDependencies {
  TestDependencies({
    AbstractBalanceRepository? balanceRepository,
    AbstractTransactionRepository? transactionRepository,
    AbstractAccountRepository? accountRepository,
    AbstractTransferRepository? transferRepository,
    AbstractCategoryRepository? categoryRepository,
    AbstractUserRepository? userRepository,
    AuthService? authService,
    DatabaseManager? databaseManager,
    AbstractFinancialOperationRepository? financialOperationRepository,
  })  : balanceRepository =
            balanceRepository ?? MockAbstractBalanceRepository(),
        transactionRepository =
            transactionRepository ?? MockAbstractTransactionRepository(),
        accountRepository =
            accountRepository ?? MockAbstractAccountRepository(),
        transferRepository =
            transferRepository ?? MockAbstractTransferRepository(),
        categoryRepository =
            categoryRepository ?? MockAbstractCategoryRepository(),
        userRepository = userRepository ?? MockAbstractUserRepository(),
        authService = authService ?? MockAuthService(),
        databaseManager = databaseManager ?? MockDatabaseManager(),
        financialOperationRepository = financialOperationRepository ??
            MockAbstractFinancialOperationRepository();

  final AbstractBalanceRepository balanceRepository;
  final AbstractTransactionRepository transactionRepository;
  final AbstractAccountRepository accountRepository;
  final AbstractTransferRepository transferRepository;
  final AbstractCategoryRepository categoryRepository;
  final AbstractUserRepository userRepository;
  final AuthService authService;
  final DatabaseManager databaseManager;
  final AbstractFinancialOperationRepository financialOperationRepository;
}

Future<TestDependencies> setupTestLocator({
  TestDependencies? dependencies,
}) async {
  await tearDownTestLocator();
  final testDependencies = dependencies ?? TestDependencies();

  locator
    ..registerSingleton<AbstractBalanceRepository>(
      testDependencies.balanceRepository,
    )
    ..registerSingleton<AbstractTransactionRepository>(
      testDependencies.transactionRepository,
    )
    ..registerSingleton<AbstractAccountRepository>(
      testDependencies.accountRepository,
    )
    ..registerSingleton<AbstractTransferRepository>(
      testDependencies.transferRepository,
    )
    ..registerSingleton<AbstractCategoryRepository>(
      testDependencies.categoryRepository,
    )
    ..registerSingleton<AbstractUserRepository>(
      testDependencies.userRepository,
    )
    ..registerSingleton<AuthService>(testDependencies.authService)
    ..registerSingleton<DatabaseManager>(testDependencies.databaseManager)
    ..registerSingleton<AbstractFinancialOperationRepository>(
      testDependencies.financialOperationRepository,
    );

  return testDependencies;
}

Future<void> tearDownTestLocator() async {
  await locator.reset(dispose: true);
}

DatabaseFactory initializeFfiDatabase() {
  sqfliteFfiInit();
  return databaseFactoryFfi;
}
