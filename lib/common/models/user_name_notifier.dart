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
    currentUser = locator.get<CurrentUser>();
    _userName = currentUser.userName ?? '';
  }
}
