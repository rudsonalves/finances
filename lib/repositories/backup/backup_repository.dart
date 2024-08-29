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

import '../../locator.dart';
import '../../store/database/database_backup.dart';
import '../user/abstract_user_repository.dart';
import 'abstract_backup_repository.dart';

class BackupRepository extends AbstractBackupRepository {
  final _helper = DatabaseBackup();

  @override
  Future<String?> createBackup([String? destinyPath]) async {
    String? result = await _helper.backupDatabase(destinyPath);
    return result;
  }

  @override
  Future<bool> restoreBackup(String restorePath) async {
    bool result = await _helper.restoreDatabase(restorePath);
    await locator<AbstractUserRepository>().restart();
    return result;
  }
}
