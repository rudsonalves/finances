import 'package:finances/common/models/ofx_trans_template_model.dart';
import 'package:finances/manager/ofx_trans_template_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAbstractOfxTransTemplateRepository repository;

  OfxTransTemplateModel template({int? id, int accountId = 7}) {
    return OfxTransTemplateModel(
      id: id,
      memo: 'SUPERMERCADO',
      accountId: accountId,
      categoryId: 3,
      description: 'Mercado',
    );
  }

  setUpAll(() {
    registerFallbackValue(template());
  });

  setUp(() {
    repository = MockAbstractOfxTransTemplateRepository();
  });

  test('consulta o template no escopo da conta interna', () async {
    final expected = template(id: 5);
    when(() => repository.queryMemo('SUPERMERCADO', 7))
        .thenAnswer((_) async => expected);

    final result = await OfxTransTemplateManager.getByMemo(
      memo: 'SUPERMERCADO',
      accountId: 7,
      repository: repository,
    );

    expect(result, same(expected));
    verify(() => repository.queryMemo('SUPERMERCADO', 7)).called(1);
  });

  test('não reutiliza implicitamente template de outra conta', () async {
    when(() => repository.queryMemo('SUPERMERCADO', 8))
        .thenAnswer((_) async => null);

    final result = await OfxTransTemplateManager.getByMemo(
      memo: 'SUPERMERCADO',
      accountId: 8,
      repository: repository,
    );

    expect(result, isNull);
  });

  test('adiciona template e copia o identificador persistido', () async {
    final model = template();
    when(() => repository.insert(model)).thenAnswer((_) async {
      model.id = 12;
      return model;
    });

    await OfxTransTemplateManager.add(model, repository: repository);

    expect(model.id, 12);
  });

  test('atualiza template existente', () async {
    final model = template(id: 12);
    when(() => repository.update(model)).thenAnswer((_) async => 1);

    await OfxTransTemplateManager.update(model, repository: repository);

    verify(() => repository.update(model)).called(1);
  });
}
