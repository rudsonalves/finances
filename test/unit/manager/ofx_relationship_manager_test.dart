import 'package:finances/common/models/ofx_relationship_model.dart';
import 'package:finances/manager/ofx_relationship_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAbstractOfxRelationshipRepository repository;

  OfxRelationshipModel relationship({int? id, int accountId = 7}) {
    return OfxRelationshipModel(
      id: id,
      bankAccountId: '123-4',
      accountId: accountId,
      bankName: 'Banco Teste',
    );
  }

  setUpAll(() {
    registerFallbackValue(relationship());
  });

  setUp(() {
    repository = MockAbstractOfxRelationshipRepository();
  });

  test('adiciona a associação entre conta OFX e conta interna', () async {
    final model = relationship();
    when(() => repository.insert(model)).thenAnswer((_) async {
      model.id = 11;
      return 11;
    });

    await OfxRelationshipManager.add(model, repository: repository);

    expect(model.id, 11);
    verify(() => repository.insert(model)).called(1);
  });

  test('recupera a associação pelo identificador da conta bancária', () async {
    final model = relationship(id: 11);
    when(() => repository.queryBankAccountId('123-4'))
        .thenAnswer((_) async => model);

    final result = await OfxRelationshipManager.getByBankAccountId(
      '123-4',
      repository: repository,
    );

    expect(result, same(model));
  });

  test('atualiza a conta interna associada', () async {
    final model = relationship(id: 11, accountId: 9);
    when(() => repository.update(model)).thenAnswer((_) async => 1);

    final result = await OfxRelationshipManager.update(
      model,
      repository: repository,
    );

    expect(result, 1);
    verify(() => repository.update(model)).called(1);
  });

  test('propaga falha de associação', () async {
    final model = relationship();
    when(() => repository.insert(model)).thenAnswer((_) async => 0);

    await expectLater(
      () => OfxRelationshipManager.add(model, repository: repository),
      throwsException,
    );
  });
}
