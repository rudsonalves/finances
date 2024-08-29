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

import '../../store/database/database_provider.dart';
import 'abstract_database_repository.dart';

class DatabaseRepository implements AbstractDatabaseRepository {
  final DatabaseProvider _helper = DatabaseProvide();

  @override
  Future<void> init() async {
    await _helper.init();
  }

  @override
  Future<void> deleteDatabase() async {
    await _helper.deleteDatabase();
  }

  @override
  Future<void> updateAppVersion(String version) async {
    await _helper.updateAppVersion(version);
  }

  @override
  Future<String> queryAppVersion() async {
    return await _helper.queryAppVersion();
  }

  @override
  Future<void> dispose() async {
    await _helper.dispose();
  }
}
