import 'package:finances/common/current_models/current_account.dart';
import 'package:finances/common/current_models/current_balance.dart';
import 'package:finances/common/current_models/current_language.dart';
import 'package:finances/common/current_models/current_user.dart';
import 'package:finances/common/models/user_model.dart';
import 'package:finances/features/sign_up/sign_up_controller.dart';
import 'package:finances/features/sign_up/sign_up_state.dart';
import 'package:finances/l10n/app_localizations.dart';
import 'package:finances/locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_setup.dart';

class MockCurrentLanguage extends Mock implements CurrentLanguage {}

class MockCurrentUser extends Mock implements CurrentUser {}

class MockCurrentAccount extends Mock implements CurrentAccount {}

class MockCurrentBalance extends Mock implements CurrentBalance {}

void main() {
  late MockAuthService authService;
  late MockAbstractCategoryRepository categoryRepository;
  late MockCurrentLanguage currentLanguage;
  late MockCurrentUser currentUser;
  late MockCurrentAccount currentAccount;
  late MockCurrentBalance currentBalance;
  late AppLocalizations locale;
  late SignUpController controller;

  setUp(() async {
    authService = MockAuthService();
    categoryRepository = MockAbstractCategoryRepository();
    currentLanguage = MockCurrentLanguage();
    currentUser = MockCurrentUser();
    currentAccount = MockCurrentAccount();
    currentBalance = MockCurrentBalance();
    locale = await AppLocalizations.delegate.load(const Locale('pt', 'BR'));

    await setupTestLocator(
      dependencies: TestDependencies(
        authService: authService,
        categoryRepository: categoryRepository,
      ),
    );
    locator
      ..registerSingleton<CurrentLanguage>(currentLanguage)
      ..registerSingleton<CurrentUser>(currentUser)
      ..registerSingleton<CurrentAccount>(currentAccount)
      ..registerSingleton<CurrentBalance>(currentBalance);

    when(() => currentLanguage.locale).thenReturn(const Locale('pt', 'BR'));
    when(() => currentUser.addUser()).thenAnswer((_) async {});
    when(() => currentAccount.init()).thenAnswer((_) async {});
    when(() => currentBalance.start()).thenAnswer((_) async {});
    when(() => categoryRepository.firstCategory(locale))
        .thenAnswer((_) async {});

    controller = SignUpController(authService);
  });

  tearDown(() async {
    controller.dispose();
    await tearDownTestLocator();
  });

  group('SignUpController', () {
    test('começa no estado inicial', () {
      expect(controller.state, isA<SignUpStateInitial>());
    });

    test('cadastro bem-sucedido inicializa os dados locais', () async {
      final credentials = UserModel(
        name: 'Test User',
        email: 'user@example.com',
        password: 'Password1',
      );
      final createdUser = UserModel(
        id: 'user-id',
        name: 'Test User',
        email: 'user@example.com',
      );
      when(
        () => authService.signUp(
          name: 'Test User',
          email: 'user@example.com',
          password: 'Password1',
        ),
      ).thenAnswer((_) async => createdUser);

      final notifiedStates = <Type>[];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.doSignUp(credentials, locale);

      expect(controller.state, isA<SignUpStateSuccess>());
      expect(notifiedStates, [SignUpStateLoading, SignUpStateSuccess]);
      verify(() => currentUser.setFromUserModel(createdUser)).called(1);
      verify(() => currentUser.addUser()).called(1);
      verify(() => currentAccount.init()).called(1);
      verify(() => currentBalance.start()).called(1);
      verify(() => categoryRepository.firstCategory(locale)).called(1);
    });

    test('cadastro sem identificador termina em erro', () async {
      final credentials = UserModel(
        name: 'Test User',
        email: 'user@example.com',
        password: 'Password1',
      );
      when(
        () => authService.signUp(
          name: 'Test User',
          email: 'user@example.com',
          password: 'Password1',
        ),
      ).thenAnswer((_) async => UserModel(email: 'user@example.com'));

      await controller.doSignUp(credentials, locale);

      expect(controller.state, isA<SignUpStateError>());
      verifyNever(() => currentUser.addUser());
    });

    test('erro do Firebase termina em estado de erro', () async {
      final credentials = UserModel(
        name: 'Test User',
        email: 'user@example.com',
        password: 'Password1',
      );
      when(
        () => authService.signUp(
          name: 'Test User',
          email: 'user@example.com',
          password: 'Password1',
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'E-mail já utilizado',
        ),
      );

      await controller.doSignUp(credentials, locale);

      expect(controller.state, isA<SignUpStateError>());
      expect(
        (controller.state as SignUpStateError).message,
        contains('email-already-in-use'),
      );
    });

    test('erro ao inicializar dados locais termina em estado de erro', () async {
      final credentials = UserModel(
        name: 'Test User',
        email: 'user@example.com',
        password: 'Password1',
      );
      when(
        () => authService.signUp(
          name: 'Test User',
          email: 'user@example.com',
          password: 'Password1',
        ),
      ).thenAnswer(
        (_) async => UserModel(
          id: 'user-id',
          email: 'user@example.com',
        ),
      );
      when(() => currentAccount.init())
          .thenThrow(Exception('Falha ao criar conta'));

      await controller.doSignUp(credentials, locale);

      expect(controller.state, isA<SignUpStateError>());
      expect(
        (controller.state as SignUpStateError).message,
        contains('Falha ao criar conta'),
      );
    });
  });
}
