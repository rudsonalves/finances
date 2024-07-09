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

import '../../locator.dart';
import '../models/user_db_model.dart';
import 'current_language.dart';
import 'current_theme.dart';

class CurrentUser extends UserDbModel {
  Future<void> init() async {
    await userRepository.init();
  }

  Future<void> addUser() async {
    await userRepository.addUser(this);
  }

  Future<void> setUserTheme(String themeName) async {
    userTheme = themeName;
    await updateUserTheme();
  }

  Future<void> setUserLanguage(String languageCode) async {
    userLanguage = languageCode;
    await updateUserLanguage();
  }

  void applyCurrentUserSettings() {
    locator<CurrentTheme>().setThemeFromThemeName(userTheme);
    locator<CurrentLanguage>().setFromLocaleCode(userLanguage);
  }

  Future<void> setMaxTransactions(int maxTransactions) async {
    userMaxTransactions = maxTransactions;
    await updateUserMaxTransactions();
  }
}
