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
      // await Future.delayed(const Duration(seconds: 2));
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
      // await Future.delayed(const Duration(seconds: 2));
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
    // await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<bool> recoverPassword(String email) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeAccount() {
    throw UnimplementedError();
  }
}
