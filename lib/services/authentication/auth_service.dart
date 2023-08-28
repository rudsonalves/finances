import 'package:firebase_auth/firebase_auth.dart';

import '../../common/models/user_model.dart';

abstract class AuthService {
  User? get currentUser;

  Future<UserModel> signUp({
    String? name,
    required String email,
    required String password,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<bool> recoverPassword(String email);
}
