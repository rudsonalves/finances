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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/laguage_constants.dart';
import '../../common/current_models/current_language.dart';
import '../../locator.dart';
import '../../repositories/category/abstract_category_repository.dart';
import './sign_in_state.dart';
import '../../common/models/user_model.dart';
import '../../repositories/user/abstract_user_repository.dart';
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
        final userRepository = locator<AbstractUserRepository>();
        await userRepository.init();
        final users = userRepository.users;
        if (!users.containsKey(user.id!)) {
          throw Exception('Local data don\'t have this user.');
        }
        // get currentUser informations
        final currentUser = locator<CurrentUser>();
        currentUser.copyFromUser(users[user.id!]!);
        currentUser.userLogged = true;
        await currentUser.updateUser();
        currentUser.applyCurrentUserSettings();
        // start current account in main account;
        await locator<CurrentAccount>().init();
        // start curretn balance
        await locator<CurrentBalance>().start();

        _changeState(SignInStateSuccess());
      } else {
        throw Exception('Sorry! An unexpected error occurred.');
      }
    } catch (err) {
      _changeState(SignInStateError(err.toString()));
    }
  }

  Future<void> createLocalUser(
    UserModel userModel,
    AppLocalizations locale,
  ) async {
    _changeState(SignInStateLoading());
    final currentLanguage = locator<CurrentLanguage>();
    final String langCode = currentLanguage.locale.toString();
    final language =
        languageAttributes.containsKey(langCode) ? langCode : 'en_US';

    try {
      final UserModel user = await _service.signIn(
        email: userModel.email!,
        password: userModel.password!,
      );

      if (user.id != null) {
        final currentUser = locator<CurrentUser>();
        currentUser.setFromUserModel(user);
        currentUser.userLogged = true;
        currentUser.userLanguage = language;
        await currentUser.addUser();
        await locator<CurrentAccount>().init();
        await locator<CurrentBalance>().start();
        await locator<AbstractCategoryRepository>().firstCategory(locale);
        _changeState(SignInStateSuccess());
      } else {
        throw Exception('Sorry! An unexpected error occurred.');
      }
    } catch (err) {
      _changeState(SignInStateError(err.toString()));
    }
  }
}
