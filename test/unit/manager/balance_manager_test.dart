import 'package:finances/common/models/extends_date.dart';
import 'package:finances/manager/balance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures/model_fixtures.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  late MockAbstractBalanceRepository repository;

  setUpAll(() {
    registerFallbackValue(ExtendedDate(2000));
    registerFallbackValue(createFakeBalance());
  });

  setUp(() async {
    repository = MockAbstractBalanceRepository();
    await setupTestLocator(
      dependencies: TestDependencies(balanceRepository: repository),
    );
  });

  tearDown(tearDownTestLocator);

  group('BalanceManager.getBalanceInDate', () {
    test('retorna o balanço existente sem inserir outro', () async {
      final date = ExtendedDate(2026, 8, 31, 18);
      final existing = createFakeBalance(
        id: 10,
        accountId: 2,
        date: ExtendedDate(2026, 8, 31),
      );

      when(
        () => repository.getInDate(
          date: any(named: 'date'),
          accountId: 2,
        ),
      ).thenAnswer((_) async => existing);

      final result = await BalanceManager.getBalanceInDate(
        date: date,
        accountId: 2,
      );

      expect(result, same(existing));
      verifyNever(() => repository.insert(any()));
    });

    test('herda o fechamento do balanço anterior', () async {
      final previous = createFakeBalance(
        id: 10,
        accountId: 2,
        date: ExtendedDate(2026, 8, 30),
        transactionCount: 4,
        openingBalance: 50,
        closingBalance: 175.25,
      );

      when(
        () => repository.getInDate(
          date: any(named: 'date'),
          accountId: 2,
        ),
      ).thenAnswer((_) async => previous);

      when(() => repository.insert(any())).thenAnswer((invocation) async {
        final balance = invocation.positionalArguments.single;
        balance.balanceId = 11;
        return 11;
      });

      final result = await BalanceManager.getBalanceInDate(
        date: ExtendedDate(2026, 8, 31, 18),
        accountId: 2,
      );

      expect(result, isNot(same(previous)));
      expect(result.balanceId, 11);
      expect(result.balanceDate, ExtendedDate(2026, 8, 31));
      expect(result.balanceTransCount, 0);
      expect(result.balanceOpen, 175.25);
      expect(result.balanceClose, 175.25);
      expect(previous.balanceId, 10);
      expect(previous.balanceDate, ExtendedDate(2026, 8, 30));
      expect(previous.balanceTransCount, 4);
      expect(previous.balanceOpen, 50);
      expect(previous.balanceClose, 175.25);
      verify(() => repository.insert(result)).called(1);
    });

    test('inicia com zero quando não existe histórico', () async {
      when(
        () => repository.getInDate(
          date: any(named: 'date'),
          accountId: 2,
        ),
      ).thenAnswer((_) async => null);

      when(() => repository.insert(any())).thenAnswer((invocation) async {
        final balance = invocation.positionalArguments.single;
        balance.balanceId = 1;
        return 1;
      });

      final result = await BalanceManager.getBalanceInDate(
        date: ExtendedDate(2026, 8, 31),
        accountId: 2,
      );

      expect(result.balanceOpen, 0);
      expect(result.balanceClose, 0);
      expect(result.balanceTransCount, 0);
    });

    test('propaga erro do repositório', () async {
      when(
        () => repository.getInDate(
          date: any(named: 'date'),
          accountId: any(named: 'accountId'),
        ),
      ).thenThrow(Exception('database unavailable'));

      await expectLater(
        () => BalanceManager.getBalanceInDate(
          date: ExtendedDate(2026, 8, 31),
          accountId: 2,
        ),
        throwsException,
      );
    });
  });
}
