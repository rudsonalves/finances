import 'package:finances/common/constants/themes/app_icons.dart';
import 'package:finances/common/models/account_db_model.dart';
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
      iconName: 'account_balance',
      iconFontFamily: IconsFontFamily.MaterialIcons,
      iconColor: 0xFF123456,
    );

    locator.registerSingleton<AbstractIconRepository>(iconRepository);

    when(() => iconRepository.getIconId(7)).thenAnswer((_) async => icon);
  });

  tearDown(() async {
    await locator.reset(dispose: true);
  });

  group('AccountDbModel serialização', () {
    test('reconstrói todos os campos produzidos por toMap', () async {
      final AccountDbModel source = AccountDbModel(
        accountId: 10,
        accountName: 'Conta corrente',
        accountUserId: 'user-1',
        accountIcon: icon,
        accountDescription: 'Conta principal',
      );

      final AccountDbModel result =
          await AccountDbModel.fromMap(source.toMap());

      expect(result.accountId, source.accountId);
      expect(result.accountName, source.accountName);
      expect(result.accountUserId, source.accountUserId);
      expect(result.accountIcon, same(icon));
      expect(result.accountDescription, source.accountDescription);

      verify(() => iconRepository.getIconId(7)).called(1);
    });

    test('preserva identificador e descrição nulos', () async {
      final AccountDbModel source = AccountDbModel(
        accountName: 'Carteira',
        accountUserId: 'user-1',
        accountIcon: icon,
      );

      final AccountDbModel result =
          await AccountDbModel.fromMap(source.toMap());

      expect(result.accountId, isNull);
      expect(result.accountDescription, isNull);
    });

    test('reconstrói o modelo produzido por toJson', () async {
      final AccountDbModel source = AccountDbModel(
        accountId: 10,
        accountName: 'Conta corrente',
        accountUserId: 'user-1',
        accountIcon: icon,
        accountDescription: 'Conta principal',
      );

      final AccountDbModel result =
          await AccountDbModel.fromJson(source.toJson());

      expect(result.accountId, source.accountId);
      expect(result.accountName, source.accountName);
      expect(result.accountUserId, source.accountUserId);
      expect(result.accountIcon, same(icon));
      expect(result.accountDescription, source.accountDescription);
    });
  });

  group('AccountDbModel.toMap', () {
    test('rejeita ícone que ainda não possui identificador', () {
      final AccountDbModel account = AccountDbModel(
        accountName: 'Conta corrente',
        accountUserId: 'user-1',
        accountIcon: IconModel(
          iconName: 'account_balance',
          iconFontFamily: IconsFontFamily.MaterialIcons,
        ),
      );

      expect(
        account.toMap,
        throwsA(isA<StateError>()),
      );
    });
  });
}
