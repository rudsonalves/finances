import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import '../../common/models/user_model.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return UserModel(
          id: _auth.currentUser?.uid,
          name: _auth.currentUser?.displayName,
          email: _auth.currentUser?.email,
        );
      } else {
        throw Exception('Unknow Firebase Auth error!');
      }
    } on FirebaseAuthException catch (err) {
      throw err.message ?? 'null';
    } catch (err) {
      rethrow;
    }
  }

  Future<String> get userToken async {
    try {
      final token = await _auth.currentUser?.getIdToken(true);
      if (token != null) {
        return token;
      } else {
        throw Exception('user not found');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<bool> recoverPassword(String email) async {
    bool success = false;
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => success = true)
        .catchError((e) => success = false);

    return success;
  }

  @override
  Future<UserModel> signUp({
    String? name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await result.user!.updateDisplayName(name);

        return UserModel(
          id: _auth.currentUser?.uid,
          name: _auth.currentUser?.displayName,
          email: _auth.currentUser?.email,
        );
      } else {
        throw Exception('Unknow Firebase Auth error!');
      }
    } on FirebaseAuthException catch (err) {
      throw err.message ?? 'null';
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> removeAccount() async {
    await _auth.currentUser!.delete();
  }
}
