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

import '../../common/models/user_db_model.dart';

abstract class AbstractUserRepository {
  Future<void> init();
  Future<void> restart();
  Map<String, UserDbModel> get users;
  Future<void> addUser(UserDbModel user);
  Map<String, dynamic> getUserMapById(String id);
  Future<void> updateUser(UserDbModel user);
  Future<void> updateUserBudgetRef(UserDbModel user);
  Future<void> updateUserGrpShowGrid(UserDbModel user);
  Future<void> updateUserGrpShowDots(UserDbModel user);
  Future<void> updateUserGrpIsCurved(UserDbModel user);
  Future<void> updateUserGrpAreaChart(UserDbModel user);
  Future<void> updateUserLanguage(UserDbModel user);
  Future<void> updateUserTheme(UserDbModel user);
  Future<void> updateUserMaxTransactions(UserDbModel user);
}
