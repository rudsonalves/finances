import 'package:finances/common/constants/themes/app_icons.dart';
import 'package:finances/common/models/category_db_model.dart';
import 'package:finances/common/models/icons_model.dart';
import 'package:finances/locator.dart';
import 'package:finances/repositories/icons/abstract_icons_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIconRepository extends Mock implements AbstractIconRepository {}

void main() {
  late MockIconRepository iconRepository;
  late IconModel icon;

  setUp(() {
    iconRepository = MockIconRepository();
    icon = IconModel(
      iconId: 7,
      iconName: 'restaurant',
      iconFontFamily: IconsFontFamily.MaterialIcons,
      iconColor: 0xFF123456,
    );

    locator.registerSingleton<AbstractIconRepository>(iconRepository);

    when(() => iconRepository.getIconId(7)).thenAnswer((_) async => icon);
  });

  tearDown(() async {
    await locator.reset(dispose: true);
  });

  group('CategoryDbModel serialização', () {
    test('reconstrói todos os campos produzidos por toMap', () async {
      final CategoryDbModel source = CategoryDbModel(
        categoryId: 10,
        categoryName: 'Alimentação',
        categoryIcon: icon,
        categoryBudget: 500.75,
        categoryIsIncome: false,
      );

      final CategoryDbModel result =
          await CategoryDbModel.fromMap(source.toMap());

      expect(result.categoryId, source.categoryId);
      expect(result.categoryName, source.categoryName);
      expect(result.categoryIcon, same(icon));
      expect(result.categoryBudget, source.categoryBudget);
      expect(result.categoryIsIncome, source.categoryIsIncome);

      verify(() => iconRepository.getIconId(7)).called(1);
    });

    test('preserva identificador nulo em uma nova categoria', () async {
      final CategoryDbModel source = CategoryDbModel(
        categoryName: 'Alimentação',
        categoryIcon: icon,
      );

      final CategoryDbModel result =
          await CategoryDbModel.fromMap(source.toMap());

      expect(result.categoryId, isNull);
    });

    test('aceita orçamento representado como inteiro', () async {
      final Map<String, dynamic> map = {
        'categoryId': 10,
        'categoryName': 'Alimentação',
        'categoryIcon': 7,
        'categoryBudget': 500,
        'categoryIsIncome': 0,
      };

      final CategoryDbModel result = await CategoryDbModel.fromMap(map);

      expect(result.categoryBudget, 500.0);
    });

    test('serializa categoria de receita como um', () {
      final CategoryDbModel category = CategoryDbModel(
        categoryName: 'Salário',
        categoryIcon: icon,
        categoryIsIncome: true,
      );

      expect(category.toMap()['categoryIsIncome'], 1);
    });

    test('serializa categoria de despesa como zero', () {
      final CategoryDbModel category = CategoryDbModel(
        categoryName: 'Alimentação',
        categoryIcon: icon,
        categoryIsIncome: false,
      );

      expect(category.toMap()['categoryIsIncome'], 0);
    });

    test('reconstrói o modelo produzido por toJson', () async {
      final CategoryDbModel source = CategoryDbModel(
        categoryId: 10,
        categoryName: 'Alimentação',
        categoryIcon: icon,
        categoryBudget: 500.75,
        categoryIsIncome: false,
      );

      final CategoryDbModel result =
          await CategoryDbModel.fromJson(source.toJson());

      expect(result.categoryId, source.categoryId);
      expect(result.categoryName, source.categoryName);
      expect(result.categoryIcon, same(icon));
      expect(result.categoryBudget, source.categoryBudget);
      expect(result.categoryIsIncome, source.categoryIsIncome);
    });
  });

  group('CategoryDbModel.toMap', () {
    test('rejeita ícone que ainda não possui identificador', () {
      final CategoryDbModel category = CategoryDbModel(
        categoryName: 'Alimentação',
        categoryIcon: IconModel(
          iconName: 'restaurant',
          iconFontFamily: IconsFontFamily.MaterialIcons,
        ),
      );

      expect(
        category.toMap,
        throwsA(isA<StateError>()),
      );
    });
  });
}
