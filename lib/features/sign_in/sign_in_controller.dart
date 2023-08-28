import 'package:flutter/material.dart';

import '../../locator.dart';
import './sign_in_state.dart';
import '../../common/models/user_model.dart';
import '../../repositories/user/user_repository.dart';
import '../../common/current_models/current_user.dart';
import '../../common/current_models/current_account.dart';
import '../../services/authentication/auth_service.dart';
import '../../common/current_models/current_balance.dart';

class SignInController extends ChangeNotifier {
  SignInState _state = SignInStateInitial();
  final AuthService _service;

  SignInController(this._service);

  SignInState get state => _state;

  void _changeState(SignInState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<bool> recoverPassword(String email) async {
    bool success = await _service.recoverPassword(email);
    return success;
  }

  Future<void> doSignIn(UserModel userModel) async {
    _changeState(SignInStateLoading());

    try {
      final UserModel user = await _service.signIn(
        email: userModel.email!,
        password: userModel.password!,
      );

      if (user.id != null) {
        // read currentUser informations in local database
        final userRepository = locator.get<UserRepository>();
        await userRepository.init();
        final users = userRepository.users;
        if (!users.containsKey(user.id!)) {
          throw Exception('Local data don\'t have this user.');
        }
        // get currentUser informations
        final currentUser = locator.get<CurrentUser>();
        currentUser.copyFromUser(users[user.id!]!);
        currentUser.userLogged = true;
        await currentUser.updateUser();
        currentUser.applyCurrentUserSettings();
        // start current account in main account;
        await locator.get<CurrentAccount>().init();
        // start curretn balance
        await locator.get<CurrentBalance>().start();

        _changeState(SignInStateSuccess());
      } else {
        throw Exception('Sorry! An unexpected error occurred.');
      }
    } catch (err) {
      _changeState(SignInStateError(err.toString()));
    }
  }
}
