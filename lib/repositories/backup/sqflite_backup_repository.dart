import '../../locator.dart';
import '../../services/database/database_helper.dart';
import '../user/user_repository.dart';
import 'backup_repository.dart';

class SqfliteBackupRepository extends BackupRepository {
  final helper = locator.get<DatabaseHelper>();

  @override
  Future<String?> createBackup([String? destinyPath]) async {
    String? result = await helper.backupDatabase(destinyPath);
    return result;
  }

  @override
  Future<bool> restoreBackup(String restorePath) async {
    bool result = await helper.restoreDatabase(restorePath);
    await locator.get<UserRepository>().restart();
    return result;
  }
}
