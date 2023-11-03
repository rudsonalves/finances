import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../common/current_models/current_account.dart';
import '../../common/current_models/current_balance.dart';
import './splash_state.dart';
import '../../locator.dart';
import '../../common/current_models/current_user.dart';
import '../../repositories/user/user_repository.dart';
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
    var userRepository = locator.get<UserRepository>();
    await userRepository.init();

    UserDbModel? loggedUser;
    for (var user in userRepository.users.values) {
      if (user.userLogged) {
        loggedUser = user;
      }
    }

    if (loggedUser != null) {
      var user = locator.get<AuthService>().currentUser;
      String email = user?.email ?? '';
      if (email.isEmpty) {
        _changeState(SplashStateError());
        throw Exception('User isn\'t logged in splash_controller 1...');
      }

      try {
        if (loggedUser.userEmail == email) {
          final currentUser = locator.get<CurrentUser>();
          currentUser.copyFromUser(loggedUser);
          currentUser.applyCurrentUserSettings();
          // start current account
          await locator.get<CurrentAccount>().init();
          // start current balance
          await locator.get<CurrentBalance>().start();
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
