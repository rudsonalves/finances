// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

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
