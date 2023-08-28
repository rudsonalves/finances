import 'dart:developer';

import 'package:flutter/material.dart';

import '../../locator.dart';
import './sign_up_state.dart';
import '../../common/current_models/current_user.dart';
import '../../repositories/category/category_repository.dart';
import '../../common/current_models/current_account.dart';
import '../../common/current_models/current_balance.dart';
import '../../common/models/user_model.dart';
import '../../services/authentication/auth_service.dart';

class SignUpController extends ChangeNotifier {
  SignUpState _state = SignUpStateInitial();
  final AuthService _service;
  // final SecureStorage _secureStorage;

  SignUpController(
    this._service,
    // this._secureStorage,
  );

  SignUpState get state => _state;

  void _changeState(SignUpState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> doSignUp(UserModel userModel) async {
    _changeState(SignUpStateLoading());

    try {
      final UserModel user = await _service.signUp(
        name: userModel.name,
        email: userModel.email!,
        password: userModel.password!,
      );

      if (user.id != null) {
        //
        // Create user in local database.
        //
        // Create user informations
        final currentUser = locator.get<CurrentUser>();
        currentUser.setFromUserModel(user);
        currentUser.userLogged = true;
        currentUser.addUser();
        // Create a first account and set as currentAccount
        await locator.get<CurrentAccount>().init();
        // Create a initial balance
        await locator.get<CurrentBalance>().start();
        // Create the category from transfer between accounts
        await locator.get<CategoryRepository>().firstCategory();
        _changeState(SignUpStateSuccess());
      } else {
        throw Exception();
      }

      // return true;
    } catch (err) {
      log('Error: $err');
      _changeState(SignUpStateError(err.toString()));
      // return false;
    }
  }
}
