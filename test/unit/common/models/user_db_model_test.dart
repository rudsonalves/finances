import 'package:finances/common/constants/app_constants.dart';
import 'package:finances/common/models/user_db_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserDbModel serialização', () {
    test('reconstrói todos os campos produzidos por toMap', () {
      final UserDbModel source = UserDbModel(
        userId: 'user-1',
        userName: 'Maria',
        userEmail: 'maria@example.com',
        userLogged: true,
        userMainAccountId: 10,
        userTheme: 'dark',
        userLanguage: 'pt_BR',
        userGrpShowGrid: false,
        userGrpIsCurved: true,
        userGrpShowDots: true,
        userGrpAreaChart: true,
        userBudgetRef: StatisticMedium.medium12,
        userCategoryList: ['Alimentação', 'Transporte'],
        userMaxTransactions: 50,
        userOfxStopCategories: [1, 4, 7],
      );

      final UserDbModel result = UserDbModel.fromMap(source.toMap());

      expect(result.userId, source.userId);
      expect(result.userName, source.userName);
      expect(result.userEmail, source.userEmail);
      expect(result.userLogged, source.userLogged);
      expect(result.userMainAccountId, source.userMainAccountId);
      expect(result.userTheme, source.userTheme);
      expect(result.userLanguage, source.userLanguage);
      expect(result.userGrpShowGrid, source.userGrpShowGrid);
      expect(result.userGrpIsCurved, source.userGrpIsCurved);
      expect(result.userGrpShowDots, source.userGrpShowDots);
      expect(result.userGrpAreaChart, source.userGrpAreaChart);
      expect(result.userBudgetRef, source.userBudgetRef);
      expect(result.userCategoryList, source.userCategoryList);
      expect(result.userMaxTransactions, source.userMaxTransactions);
      expect(result.userOfxStopCategories, source.userOfxStopCategories);
    });

    test('serializa booleanos como zero e um para SQLite', () {
      final UserDbModel user = UserDbModel(
        userId: 'user-1',
        userLogged: true,
        userGrpShowGrid: false,
        userGrpIsCurved: true,
        userGrpShowDots: false,
        userGrpAreaChart: true,
      );

      final Map<String, dynamic> map = user.toMap();

      expect(map['userLogged'], 1);
      expect(map['userGrpShowGrid'], 0);
      expect(map['userGrpIsCurved'], 1);
      expect(map['userGrpShowDots'], 0);
      expect(map['userGrpAreaChart'], 1);
    });

    test('reconstrói booleanos armazenados como zero e um', () {
      final Map<String, dynamic> map = UserDbModel(
        userId: 'user-1',
      ).toMap()
        ..['userLogged'] = 0
        ..['userGrpShowGrid'] = 1
        ..['userGrpIsCurved'] = 0
        ..['userGrpShowDots'] = 1
        ..['userGrpAreaChart'] = 0;

      final UserDbModel result = UserDbModel.fromMap(map);

      expect(result.userLogged, isFalse);
      expect(result.userGrpShowGrid, isTrue);
      expect(result.userGrpIsCurved, isFalse);
      expect(result.userGrpShowDots, isTrue);
      expect(result.userGrpAreaChart, isFalse);
    });

    test('preserva campos opcionais nulos', () {
      final UserDbModel source = UserDbModel(
        userName: null,
        userEmail: null,
        userMainAccountId: null,
      );

      final UserDbModel result = UserDbModel.fromMap(source.toMap());

      expect(result.userId, isNull);
      expect(result.userName, isNull);
      expect(result.userEmail, isNull);
      expect(result.userMainAccountId, isNull);
    });

    test('usa padrões para colunas opcionais ausentes', () {
      final Map<String, dynamic> map = UserDbModel(
        userId: 'user-1',
      ).toMap()
        ..remove('userMaxTransactions')
        ..remove('userOfxStopCategories');

      final UserDbModel result = UserDbModel.fromMap(map);

      expect(result.userMaxTransactions, 35);
      expect(result.userOfxStopCategories, [1]);
    });

    test('reconstrói o modelo produzido por toJson', () {
      final UserDbModel source = UserDbModel(
        userId: 'user-1',
        userName: 'Maria',
        userEmail: 'maria@example.com',
        userLogged: true,
        userMainAccountId: 10,
        userTheme: 'dark',
        userLanguage: 'pt_BR',
        userCategoryList: ['Alimentação'],
        userOfxStopCategories: [1, 4],
      );

      final UserDbModel result = UserDbModel.fromJson(source.toJson());

      expect(result.userId, source.userId);
      expect(result.userName, source.userName);
      expect(result.userEmail, source.userEmail);
      expect(result.userLogged, source.userLogged);
      expect(result.userMainAccountId, source.userMainAccountId);
      expect(result.userTheme, source.userTheme);
      expect(result.userLanguage, source.userLanguage);
      expect(result.userCategoryList, source.userCategoryList);
      expect(result.userOfxStopCategories, source.userOfxStopCategories);
    });
  });

  group('UserDbModel.copyFromUser', () {
    test('copia todos os campos do usuário de origem', () {
      final UserDbModel source = UserDbModel(
        userId: 'source-id',
        userName: 'Maria',
        userEmail: 'maria@example.com',
        userLogged: true,
        userMainAccountId: 10,
        userTheme: 'dark',
        userLanguage: 'pt_BR',
        userGrpShowGrid: false,
        userGrpIsCurved: true,
        userGrpShowDots: true,
        userGrpAreaChart: true,
        userBudgetRef: StatisticMedium.medium12,
        userCategoryList: ['Alimentação', 'Transporte'],
        userMaxTransactions: 50,
        userOfxStopCategories: [1, 4],
      );
      final UserDbModel target = UserDbModel();

      target.copyFromUser(source);

      expect(target.userId, source.userId);
      expect(target.userName, source.userName);
      expect(target.userEmail, source.userEmail);
      expect(target.userLogged, source.userLogged);
      expect(target.userMainAccountId, source.userMainAccountId);
      expect(target.userTheme, source.userTheme);
      expect(target.userLanguage, source.userLanguage);
      expect(target.userGrpShowGrid, source.userGrpShowGrid);
      expect(target.userGrpIsCurved, source.userGrpIsCurved);
      expect(target.userGrpShowDots, source.userGrpShowDots);
      expect(target.userGrpAreaChart, source.userGrpAreaChart);
      expect(target.userBudgetRef, source.userBudgetRef);
      expect(target.userCategoryList, source.userCategoryList);
      expect(target.userMaxTransactions, source.userMaxTransactions);
      expect(target.userOfxStopCategories, source.userOfxStopCategories);
    });

    test('cria uma cópia independente da lista de categorias', () {
      final UserDbModel source = UserDbModel(
        userCategoryList: ['Alimentação'],
      );
      final UserDbModel target = UserDbModel();

      target.copyFromUser(source);
      target.userCategoryList.add('Transporte');

      expect(source.userCategoryList, ['Alimentação']);
      expect(target.userCategoryList, ['Alimentação', 'Transporte']);
    });

    test('cria uma cópia independente das categorias ignoradas no OFX', () {
      final UserDbModel source = UserDbModel(
        userOfxStopCategories: [1, 4],
      );
      final UserDbModel target = UserDbModel();

      target.copyFromUser(source);
      target.userOfxStopCategories.add(7);

      expect(source.userOfxStopCategories, [1, 4]);
      expect(target.userOfxStopCategories, [1, 4, 7]);
    });
  });
}
