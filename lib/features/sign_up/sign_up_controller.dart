import 'dart:developer';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../common/constants/laguage_constants.dart';
import '../../common/current_models/current_language.dart';
import '../../locator.dart';
import './sign_up_state.dart';
import '../../common/current_models/current_user.dart';
import '../../repositories/category/abstract_category_repository.dart';
import '../../common/current_models/current_account.dart';
import '../../common/current_models/current_balance.dart';
import '../../common/models/user_model.dart';
import '../../services/authentication/auth_service.dart';

class SignUpController extends ChangeNotifier {
  SignUpState _state = SignUpStateInitial();
  final AuthService _service;

  SignUpController(
    this._service,
  );

  SignUpState get state => _state;

  void _changeState(SignUpState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> doSignUp(UserModel userModel, AppLocalizations locale) async {
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
        final currentLanguage = locator<CurrentLanguage>();
        final String langCode = currentLanguage.locale.toString();
        final language =
            languageAttributes.containsKey(langCode) ? langCode : 'en_US';

        final currentUser = locator<CurrentUser>();
        currentUser.setFromUserModel(user);
        currentUser.userLogged = true;
        currentUser.userLanguage = language;
        await currentUser.addUser();
        // Create a first account and set as currentAccount
        await locator<CurrentAccount>().init();
        // Create a initial balance
        await locator<CurrentBalance>().start();
        // Create the category from transfer between accounts
        await locator<AbstractCategoryRepository>().firstCategory(locale);
        _changeState(SignUpStateSuccess());
      } else {
        throw Exception();
      }
    } catch (err) {
      log('Error: $err');
      _changeState(SignUpStateError(err.toString()));
    }
  }
}
