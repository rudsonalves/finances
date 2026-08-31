import 'package:finances/common/models/extends_date.dart';
import 'package:finances/common/models/ofx_account_model.dart';
import 'package:finances/manager/ofx_account_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAbstractOfxAccountRepository repository;

  OfxAccountModel account({int? id, String bankAccountId = '123-4'}) {
    return OfxAccountModel(
      id: id,
      accountId: 7,
      bankAccountId: bankAccountId,
      bankName: 'Banco Teste',
      accountType: 'CHECKING',
      nTrans: 2,
      startDate: ExtendedDate(2026, 8, 1),
      endDate: ExtendedDate(2026, 8, 31),
    );
  }

  setUpAll(() {
    registerFallbackValue(account());
  });

  setUp(() {
    repository = MockAbstractOfxAccountRepository();
  });

  group('OfxAccountManager.add', () {
    test('insere um extrato ainda não importado', () async {
      final model = account();
      when(
        () => repository.queryBankAccountIdStartDate(
          model.bankAccountId,
          model.startDate,
        ),
      ).thenAnswer((_) async => null);
      when(() => repository.insert(model)).thenAnswer((_) async {
        model.id = 10;
        return 10;
      });

      final inserted = await OfxAccountManager.add(
        model,
        repository: repository,
      );

      expect(inserted, isTrue);
      expect(model.id, 10);
      verify(() => repository.insert(model)).called(1);
    });

    test('rejeita o mesmo extrato e recupera o registro existente', () async {
      final model = account();
      final existing = account(id: 10);
      when(
        () => repository.queryBankAccountIdStartDate(
          model.bankAccountId,
          model.startDate,
        ),
      ).thenAnswer((_) async => existing);

      final inserted = await OfxAccountManager.add(
        model,
        repository: repository,
      );

      expect(inserted, isFalse);
      expect(model.id, 10);
      verifyNever(() => repository.insert(any()));
    });

    test('não informa sucesso quando o repositório falha', () async {
      final model = account();
      when(
        () => repository.queryBankAccountIdStartDate(
          model.bankAccountId,
          model.startDate,
        ),
      ).thenThrow(Exception('database unavailable'));

      final inserted = await OfxAccountManager.add(
        model,
        repository: repository,
      );

      expect(inserted, isFalse);
      verifyNever(() => repository.insert(any()));
    });
  });

  test('getAll substitui a lista pelo conteúdo do repositório', () async {
    final previous = account(id: 1);
    final first = account(id: 2, bankAccountId: 'first');
    final second = account(id: 3, bankAccountId: 'second');
    final target = [previous];
    when(() => repository.queryAll(20)).thenAnswer(
      (_) async => [first, second],
    );

    await OfxAccountManager.getAll(
      target,
      limit: 20,
      repository: repository,
    );

    expect(target, [first, second]);
  });
}
