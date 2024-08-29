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

import '../../store/stores/user_store.dart';
import 'abstract_user_repository.dart';
import '../../common/models/user_db_model.dart';

class UserRepository implements AbstractUserRepository {
  final _store = UserStore();
  final Map<String, UserDbModel> _users = {};
  bool isStarting = true;

  @override
  Map<String, UserDbModel> get users => _users;

  @override
  Future<void> init() async {
    if (isStarting) {
      await _getUsers();
      isStarting = false;
    }
  }

  @override
  Future<void> restart() async {
    isStarting = true;
    await init();
  }

  Future<void> _getUsers() async {
    List<Map<String, dynamic>> users = await _store.queryAllUsers();
    _users.clear();
    _users.addEntries(
      users.map(
        (userMap) {
          final user = UserDbModel.fromMap(userMap);
          return MapEntry(user.userId!, user);
        },
      ),
    );
  }

  @override
  Future<void> addUser(UserDbModel user) async {
    user.userName ??= '';
    int result = await _store.insertUser(user.toMap());
    if (result < 0) {
      throw Exception('addUser return id $result');
    }
    await _getUsers();
  }

  @override
  Future<void> updateUser(UserDbModel user) async {
    await _store.updateUser(user.toMap());
    await _getUsers();
  }

  @override
  Future<void> updateUserBudgetRef(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserBudgetRef(user.userId!, user.userBudgetRef.index);
    } else {
      throw Exception('Unregistered user');
    }
  }

  @override
  Future<void> updateUserGrpShowGrid(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserGrpShowGrid(
          user.userId!, user.userGrpShowGrid ? 1 : 0);
    } else {
      throw Exception('Unregistered user');
    }
  }

  @override
  Future<void> updateUserGrpShowDots(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserGrpShowDots(
          user.userId!, user.userGrpShowDots ? 1 : 0);
    } else {
      throw Exception('Unregistered user');
    }
  }

  @override
  Future<void> updateUserGrpIsCurved(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserGrpIsCurved(
          user.userId!, user.userGrpIsCurved ? 1 : 0);
    } else {
      throw Exception('Unregistered user');
    }
  }

  @override
  Future<void> updateUserGrpAreaChart(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserGrpAreaChart(
          user.userId!, user.userGrpAreaChart ? 1 : 0);
    } else {
      throw Exception('Unregistered user');
    }
  }

  @override
  Future<void> updateUserLanguage(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserLanguage(user.userId!, user.userLanguage);
    } else {
      throw Exception('Unregistered user');
    }
  }

  @override
  Future<void> updateUserTheme(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserTheme(user.userId!, user.userTheme);
    } else {
      throw Exception('Unregistered user');
    }
  }

  @override
  Map<String, dynamic> getUserMapById(String id) {
    return _users[id]!.toMap();
  }

  @override
  Future<void> updateUserMaxTransactions(UserDbModel user) async {
    if (user.userId != null) {
      await _store.updateUserMaxTransactions(
        user.userId!,
        user.userMaxTransactions,
      );
    } else {
      throw Exception('Unregistered user');
    }
  }
}
