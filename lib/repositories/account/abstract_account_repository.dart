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

import '../../common/models/account_db_model.dart';

abstract class AbstractAccountRepository {
  Map<int, AccountDbModel> get accountsMap;
  int? accountIdByName(String name);
  List<AccountDbModel> get accountsList;
  Future<void> init();
  Future<void> restart();
  Future<int> addAccount(AccountDbModel account);
  Future<void> updateAccount(AccountDbModel account);
  Future<void> deleteAccount(AccountDbModel account);
  AccountDbModel? getAccount(int accountId);
}
