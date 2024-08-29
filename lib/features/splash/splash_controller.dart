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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../common/current_models/current_account.dart';
import '../../common/current_models/current_balance.dart';
import './splash_state.dart';
import '../../locator.dart';
import '../../common/current_models/current_user.dart';
import '../../repositories/user/abstract_user_repository.dart';
import '../../services/authentication/auth_service.dart';
import '../../common/models/user_db_model.dart';

class SplashController extends ChangeNotifier {
  SplashController();

  SplashState _state = SplashStateInitial();

  SplashState get state => _state;

  void _changeState(SplashState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> isUserLogged() async {
    _changeState(SplashStateLoading());
    await Future.delayed(const Duration(seconds: 2));
    var userRepository = locator<AbstractUserRepository>();
    await userRepository.init();

    UserDbModel? loggedUser;
    for (var user in userRepository.users.values) {
      if (user.userLogged) {
        loggedUser = user;
      }
    }

    if (loggedUser != null) {
      var user = locator<AuthService>().currentUser;
      String email = user?.email ?? '';
      if (email.isEmpty) {
        _changeState(SplashStateError());
        throw Exception('User isn\'t logged in splash_controller 1...');
      }

      try {
        if (loggedUser.userEmail == email) {
          final currentUser = locator<CurrentUser>();
          currentUser.copyFromUser(loggedUser);
          currentUser.applyCurrentUserSettings();
          // start current account
          await locator<CurrentAccount>().init();
          // start current balance
          await locator<CurrentBalance>().start();
        }
        _changeState(SplashStateSuccess());
        return;
      } catch (err) {
        log('Error: $err');
        _changeState(SplashStateError());
        return;
      }
    } else {
      _changeState(SplashStateError());
    }
  }
}
