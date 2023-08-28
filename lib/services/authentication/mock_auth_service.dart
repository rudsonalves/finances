import 'package:firebase_auth/firebase_auth.dart';

import './auth_service.dart';
import '../../common/models/user_model.dart';

class MockAuthService implements AuthService {
  @override
  User? get currentUser => null;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (password.startsWith('123')) {
        throw Exception();
      }
      return UserModel(
        id: '${email.hashCode}',
        email: email,
      );
    } catch (e) {
      if (password.startsWith('123')) {
        throw 'Unable to log in now. Please try again later.';
      }
      throw 'Unable to log in now. Please try again later.';
    }
  }

  @override
  Future<UserModel> signUp({
    String? name,
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (password.startsWith('123')) {
        throw Exception();
      }
      return UserModel(
        id: '${email.hashCode}',
        name: name,
        email: email,
      );
    } catch (e) {
      if (password.startsWith('123')) {
        throw '123 Something went wrong!';
      }
      throw 'Something went wrong!';
    }
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<bool> recoverPassword(String email) {
    // TODO: implement recoverPassword
    throw UnimplementedError();
  }
}
