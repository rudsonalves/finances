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

import '../../locator.dart';
import '../current_models/current_user.dart';
import 'user_db_model.dart';

class UserNameNotifier extends ChangeNotifier {
  UserDbModel currentUser = CurrentUser();
  String _userName = '';

  String get userName => _userName;

  Future<void> changeName(String name) async {
    if (name.isNotEmpty) {
      _userName = name;
      currentUser.userName = name;
      await currentUser.updateUser();
      notifyListeners();
    }
  }

  void init() {
    currentUser = locator<CurrentUser>();
    _userName = currentUser.userName ?? '';
  }
}
