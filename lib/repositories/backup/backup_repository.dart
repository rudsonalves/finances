import 'package:finances/store/database_backup.dart';

import '../../locator.dart';
import '../user/abstract_user_repository.dart';
import 'abstract_backup_repository.dart';

class BackupRepository extends AbstractBackupRepository {
  final _helper = locator<DatabaseBackuper>();

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
