import 'package:finances/common/current_models/current_account.dart';
import 'package:finances/common/models/card_balance_model.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:finances/locator.dart';
import 'package:finances/repositories/balance/balance_repository.dart';
import 'package:finances/repositories/statistic/statistic_repository.dart';
import 'package:finances/repositories/transaction/transaction_repository.dart';
import 'package:finances/store/constants/constants.dart';
import 'package:finances/store/database/database_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_setup.dart';

class MockCurrentAccount extends Mock implements CurrentAccount {}

void main() {
  late DatabaseManager databaseManager;
  late Database database;
  late MockCurrentAccount currentAccount;
  late TransactionRepository repository;
  late BalanceRepository balanceRepository;
  late StatisticRepository statisticRepository;

  setUp(() async {
    await tearDownTestLocator();

    final factory = initializeFfiDatabase();

    databaseManager = DatabaseManager(
      factory: factory,
      databasePathProvider: () async => inMemoryDatabasePath,
    );

    currentAccount = MockCurrentAccount();

    when(() => currentAccount.accountId).thenReturn(1);

    locator
      ..registerSingleton<DatabaseManager>(databaseManager)
      ..registerSingleton<CurrentAccount>(currentAccount);

    database = await databaseManager.database;
    repository = TransactionRepository();
    balanceRepository = BalanceRepository();
    statisticRepository = StatisticRepository();

    final iconKey = await database.insert(
      iconsTable,
      <String, Object?>{
        iconName: 'wallet',
        iconFontFamily: 'MaterialIcons',
        iconColor: 0,
      },
    );

    await database.insert(
      usersTable,
      <String, Object?>{
        userId: 'user-1',
        userName: 'Test User',
        userEmail: 'user@example.com',
        userLogged: 1,
        userTheme: 'system',
        userLanguage: 'pt_BR',
      },
    );

    await database.insert(
      accountTable,
      <String, Object?>{
        accountId: 1,
        accountName: 'Conta principal',
        accountUserId: 'user-1',
        accountIcon: iconKey,
      },
    );

    await database.insert(
      accountTable,
      <String, Object?>{
        accountId: 2,
        accountName: 'Conta secundária',
        accountUserId: 'user-1',
        accountIcon: iconKey,
      },
    );

    await database.insert(
      categoriesTable,
      <String, Object?>{
        categoryId: 1,
        categoryName: 'Categoria de teste',
        categoryIcon: iconKey,
        categoryBudget: 0.0,
        categoryIsIncome: 0,
      },
    );

    await database.insert(
      balanceTable,
      <String, Object?>{
        balanceId: 1,
        balanceAccountId: 1,
        balanceDate: ExtendedDate(2026, 8, 1).millisecondsSinceEpoch,
        balanceTransCount: 0,
        balanceOpen: 0.0,
        balanceClose: 0.0,
      },
    );

    await database.insert(
      balanceTable,
      <String, Object?>{
        balanceId: 2,
        balanceAccountId: 2,
        balanceDate: ExtendedDate(2026, 8, 1).millisecondsSinceEpoch,
        balanceTransCount: 0,
        balanceOpen: 0.0,
        balanceClose: 0.0,
      },
    );
  });

  tearDown(() async {
    await databaseManager.databaseClose();
    await tearDownTestLocator();
  });

  group('TransactionRepository', () {
    test('pagina por data e retorna somente a conta solicitada', () async {
      Future<void> insertTransaction({
        required int id,
        required int account,
        required int balance,
        required int day,
        required String description,
      }) {
        return database.insert(
          transactionsTable,
          <String, Object?>{
            transId: id,
            transBalanceId: balance,
            transAccountId: account,
            transDescription: description,
            transCategoryId: 1,
            transValue: -10.0,
            transStatus: 1,
            transDate: ExtendedDate(2026, 8, day).millisecondsSinceEpoch,
          },
        ).then((_) {});
      }

      await insertTransaction(
        id: 1,
        account: 1,
        balance: 1,
        day: 10,
        description: 'Mais antiga',
      );

      await insertTransaction(
        id: 2,
        account: 1,
        balance: 1,
        day: 20,
        description: 'Intermediária',
      );

      await insertTransaction(
        id: 3,
        account: 1,
        balance: 1,
        day: 30,
        description: 'Mais recente',
      );

      await insertTransaction(
        id: 4,
        account: 2,
        balance: 2,
        day: 31,
        description: 'Outra conta',
      );

      await insertTransaction(
        id: 5,
        account: 1,
        balance: 1,
        day: 31,
        description: 'Na data inicial',
      );

      final transactions = await repository.getNFromDate(
        startDate: ExtendedDate(2026, 8, 31),
        accountId: 1,
        maxTransactions: 2,
      );

      expect(transactions, hasLength(2));

      expect(
        transactions.map((transaction) => transaction.transDescription),
        <String>[
          'Mais recente',
          'Intermediária',
        ],
      );

      expect(
        transactions.every(
          (transaction) => transaction.transAccountId == 1,
        ),
        isTrue,
      );
    });

    test('calcula receitas e despesas do mês para a conta atual', () async {
      Future<int> insertTransaction({
        required int id,
        required int account,
        required int balance,
        required ExtendedDate date,
        required double value,
        required String description,
      }) {
        return database.insert(
          transactionsTable,
          <String, Object?>{
            transId: id,
            transBalanceId: balance,
            transAccountId: account,
            transDescription: description,
            transCategoryId: 1,
            transValue: value,
            transStatus: 1,
            transDate: date.millisecondsSinceEpoch,
          },
        );
      }

      await insertTransaction(
        id: 10,
        account: 1,
        balance: 1,
        date: ExtendedDate(2026, 8, 5),
        value: 100.0,
        description: 'Receita de agosto',
      );

      await insertTransaction(
        id: 11,
        account: 1,
        balance: 1,
        date: ExtendedDate(2026, 8, 10),
        value: -20.0,
        description: 'Primeira despesa de agosto',
      );

      await insertTransaction(
        id: 12,
        account: 1,
        balance: 1,
        date: ExtendedDate(2026, 8, 20),
        value: -10.0,
        description: 'Segunda despesa de agosto',
      );

      await insertTransaction(
        id: 13,
        account: 1,
        balance: 1,
        date: ExtendedDate(2026, 9, 1),
        value: 500.0,
        description: 'Receita de setembro',
      );

      await insertTransaction(
        id: 14,
        account: 2,
        balance: 2,
        date: ExtendedDate(2026, 8, 15),
        value: 900.0,
        description: 'Receita de outra conta',
      );

      final cardBalance = CardBalanceModel(
        incomes: 0.0,
        expanses: 0.0,
      );

      await repository.getCardBalance(
        cardBalance: cardBalance,
        date: ExtendedDate(2026, 8, 15),
      );

      expect(cardBalance.incomes, 100.0);
      expect(cardBalance.expanses, -30.0);
    });

    group('BalanceRepository', () {
      test('busca o saldo mais recente até a data informada', () async {
        await database.insert(
          balanceTable,
          <String, Object?>{
            balanceId: 10,
            balanceAccountId: 1,
            balanceDate: ExtendedDate(2026, 8, 10).millisecondsSinceEpoch,
            balanceTransCount: 0,
            balanceOpen: 100.0,
            balanceClose: 110.0,
          },
        );

        await database.insert(
          balanceTable,
          <String, Object?>{
            balanceId: 11,
            balanceAccountId: 1,
            balanceDate: ExtendedDate(2026, 8, 20).millisecondsSinceEpoch,
            balanceTransCount: 0,
            balanceOpen: 110.0,
            balanceClose: 120.0,
          },
        );

        await database.insert(
          balanceTable,
          <String, Object?>{
            balanceId: 12,
            balanceAccountId: 2,
            balanceDate: ExtendedDate(2026, 8, 15).millisecondsSinceEpoch,
            balanceTransCount: 0,
            balanceOpen: 900.0,
            balanceClose: 950.0,
          },
        );

        final balance = await balanceRepository.getInDate(
          date: ExtendedDate(2026, 8, 15),
          accountId: 1,
        );

        expect(balance, isNotNull);
        expect(balance!.balanceId, 10);
        expect(balance.balanceAccountId, 1);
        expect(balance.balanceDate, ExtendedDate(2026, 8, 10));
        expect(balance.balanceOpen, 100.0);
        expect(balance.balanceClose, 110.0);
      });

      test('retorna saldos posteriores em ordem cronológica e por conta',
          () async {
        await database.insert(
          balanceTable,
          <String, Object?>{
            balanceId: 20,
            balanceAccountId: 1,
            balanceDate: ExtendedDate(2026, 8, 20).millisecondsSinceEpoch,
            balanceTransCount: 0,
            balanceOpen: 110.0,
            balanceClose: 120.0,
          },
        );

        await database.insert(
          balanceTable,
          <String, Object?>{
            balanceId: 21,
            balanceAccountId: 1,
            balanceDate: ExtendedDate(2026, 8, 10).millisecondsSinceEpoch,
            balanceTransCount: 0,
            balanceOpen: 100.0,
            balanceClose: 110.0,
          },
        );

        await database.insert(
          balanceTable,
          <String, Object?>{
            balanceId: 22,
            balanceAccountId: 2,
            balanceDate: ExtendedDate(2026, 8, 15).millisecondsSinceEpoch,
            balanceTransCount: 0,
            balanceOpen: 900.0,
            balanceClose: 950.0,
          },
        );

        final balances = await balanceRepository.getAllAfterDate(
          date: ExtendedDate(2026, 8, 5),
          accountId: 1,
        );

        expect(balances, hasLength(2));

        expect(
          balances.map((balance) => balance.balanceId),
          <int?>[21, 20],
        );

        expect(
          balances.map((balance) => balance.balanceDate),
          <ExtendedDate>[
            ExtendedDate(2026, 8, 10),
            ExtendedDate(2026, 8, 20),
          ],
        );

        expect(
          balances.every(
            (balance) => balance.balanceAccountId == 1,
          ),
          isTrue,
        );
      });
    });

    group('StatisticRepository', () {
      test('agrupa valores por categoria, período e conta atual', () async {
        final icon = (await database.query(iconsTable)).single;
        final iconKey = icon[iconId] as int;

        await database.insert(
          categoriesTable,
          <String, Object?>{
            categoryId: 2,
            categoryName: 'Salário',
            categoryIcon: iconKey,
            categoryBudget: 0.0,
            categoryIsIncome: 1,
          },
        );

        Future<int> insertTransaction({
          required int id,
          required int account,
          required int balance,
          required int category,
          required ExtendedDate date,
          required double value,
          required String description,
        }) {
          return database.insert(
            transactionsTable,
            <String, Object?>{
              transId: id,
              transBalanceId: balance,
              transAccountId: account,
              transDescription: description,
              transCategoryId: category,
              transValue: value,
              transStatus: 1,
              transDate: date.millisecondsSinceEpoch,
            },
          );
        }

        await insertTransaction(
          id: 30,
          account: 1,
          balance: 1,
          category: 1,
          date: ExtendedDate(2026, 8, 5),
          value: -20.0,
          description: 'Primeira despesa',
        );

        await insertTransaction(
          id: 31,
          account: 1,
          balance: 1,
          category: 1,
          date: ExtendedDate(2026, 8, 10),
          value: -10.0,
          description: 'Segunda despesa',
        );

        await insertTransaction(
          id: 32,
          account: 1,
          balance: 1,
          category: 2,
          date: ExtendedDate(2026, 8, 15),
          value: 100.0,
          description: 'Receita',
        );

        await insertTransaction(
          id: 33,
          account: 1,
          balance: 1,
          category: 1,
          date: ExtendedDate(2026, 9, 1),
          value: -500.0,
          description: 'Fora do período',
        );

        await insertTransaction(
          id: 34,
          account: 2,
          balance: 2,
          category: 1,
          date: ExtendedDate(2026, 8, 20),
          value: -999.0,
          description: 'Outra conta',
        );

        final startDate = ExtendedDate(2026, 8, 1).millisecondsSinceEpoch;
        final endDate =
            ExtendedDate(2026, 8, 31, 23, 59, 59, 999).millisecondsSinceEpoch;

        final result = await statisticRepository.getTransactionSumsByCategory(
          startDate: startDate,
          endDate: endDate,
        );

        expect(result, isNotNull);
        expect(result, hasLength(2));

        expect(
          result,
          <Map<String, Object?>>[
            <String, Object?>{
              categoryName: 'Categoria de teste',
              'totalSum': -30.0,
            },
            <String, Object?>{
              categoryName: 'Salário',
              'totalSum': 100.0,
            },
          ],
        );
      });
    });
  });
}
