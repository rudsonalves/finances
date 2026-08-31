import 'package:finances/common/current_models/current_account.dart';
import 'package:finances/common/current_models/current_balance.dart';
import 'package:finances/common/current_models/current_user.dart';
import 'package:finances/common/models/user_model.dart';
import 'package:finances/features/sign_in/sign_in_controller.dart';
import 'package:finances/features/sign_in/sign_in_state.dart';
import 'package:finances/locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures/model_fixtures.dart';
import '../../../helpers/test_setup.dart';

class MockCurrentUser extends Mock implements CurrentUser {}

class MockCurrentAccount extends Mock implements CurrentAccount {}

class MockCurrentBalance extends Mock implements CurrentBalance {}

void main() {
  late MockAuthService authService;
  late MockAbstractUserRepository userRepository;
  late MockCurrentUser currentUser;
  late MockCurrentAccount currentAccount;
  late MockCurrentBalance currentBalance;
  late SignInController controller;

  setUp(() async {
    authService = MockAuthService();
    userRepository = MockAbstractUserRepository();
    currentUser = MockCurrentUser();
    currentAccount = MockCurrentAccount();
    currentBalance = MockCurrentBalance();

    await setupTestLocator(
      dependencies: TestDependencies(
        authService: authService,
        userRepository: userRepository,
      ),
    );
    locator
      ..registerSingleton<CurrentUser>(currentUser)
      ..registerSingleton<CurrentAccount>(currentAccount)
      ..registerSingleton<CurrentBalance>(currentBalance);

    when(() => currentUser.updateUser()).thenAnswer((_) async => 1);
    when(() => currentAccount.init()).thenAnswer((_) async {});
    when(() => currentBalance.start()).thenAnswer((_) async {});
    controller = SignInController(authService);
  });

  tearDown(() async {
    controller.dispose();
    await tearDownTestLocator();
  });

  group('SignInController', () {
    test('começa no estado inicial', () {
      expect(controller.state, isA<SignInStateInitial>());
    });

    test('encaminha recuperação de senha bem-sucedida', () async {
      when(() => authService.recoverPassword('user@example.com'))
          .thenAnswer((_) async => true);

      final bool result = await controller.recoverPassword('user@example.com');

      expect(result, isTrue);
      expect(controller.state, isA<SignInStatePasswordRecoveryFinished>());
      verify(
        () => authService.recoverPassword('user@example.com'),
      ).called(1);
    });

    test('encaminha falha informada pela recuperação de senha', () async {
      when(() => authService.recoverPassword('user@example.com'))
          .thenAnswer((_) async => false);

      final bool result = await controller.recoverPassword('user@example.com');

      expect(result, isFalse);
      expect(controller.state, isA<SignInStatePasswordRecoveryFinished>());
    });

    test('login com erro do Firebase termina em estado de erro', () async {
      final UserModel credentials = UserModel(
        email: 'user@example.com',
        password: 'Password1',
      );

      when(
        () => authService.signIn(
          email: 'user@example.com',
          password: 'Password1',
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuário não encontrado',
        ),
      );

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.doSignIn(credentials);

      expect(controller.state, isA<SignInStateError>());
      expect(
        (controller.state as SignInStateError).message,
        contains('user-not-found'),
      );
      expect(
        notifiedStates,
        [
          SignInStateLoading,
          SignInStateError,
        ],
      );
    });

    test('login bem-sucedido inicializa o usuário e os saldos locais',
        () async {
      final credentials = UserModel(
        email: 'user@example.com',
        password: 'Password1',
      );
      final authenticatedUser = UserModel(
        id: 'user-id',
        email: 'user@example.com',
      );
      final localUser = createFakeUser(
        id: 'user-id',
        email: 'user@example.com',
      );
      when(
        () => authService.signIn(
          email: 'user@example.com',
          password: 'Password1',
        ),
      ).thenAnswer((_) async => authenticatedUser);
      when(() => userRepository.init()).thenAnswer((_) async {});
      when(() => userRepository.users).thenReturn({'user-id': localUser});

      final notifiedStates = <Type>[];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      await controller.doSignIn(credentials);

      expect(controller.state, isA<SignInStateSuccess>());
      expect(notifiedStates, [SignInStateLoading, SignInStateSuccess]);
      verify(() => currentUser.copyFromUser(localUser)).called(1);
      verify(() => currentUser.updateUser()).called(1);
      verify(() => currentUser.applyCurrentUserSettings()).called(1);
      verify(() => currentAccount.init()).called(1);
      verify(() => currentBalance.start()).called(1);
    });

    test('login sem identificador termina em estado de erro', () async {
      final UserModel credentials = UserModel(
        email: 'user@example.com',
        password: 'Password1',
      );

      when(
        () => authService.signIn(
          email: 'user@example.com',
          password: 'Password1',
        ),
      ).thenAnswer(
        (_) async => UserModel(
          email: 'user@example.com',
        ),
      );

      await controller.doSignIn(credentials);

      expect(controller.state, isA<SignInStateError>());
      expect(
        (controller.state as SignInStateError).message,
        contains('unexpected error'),
      );
    });

    test('recuperação de senha captura exceção e termina em erro', () async {
      when(() => authService.recoverPassword('user@example.com')).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Falha de rede',
        ),
      );

      final List<Type> notifiedStates = [];
      controller.addListener(() {
        notifiedStates.add(controller.state.runtimeType);
      });

      final bool result = await controller.recoverPassword('user@example.com');

      expect(result, isFalse);
      expect(controller.state, isA<SignInStateError>());
      expect(
        (controller.state as SignInStateError).message,
        contains('network-request-failed'),
      );
      expect(
        notifiedStates,
        [
          SignInStateLoading,
          SignInStateError,
        ],
      );
    });
  });
}
