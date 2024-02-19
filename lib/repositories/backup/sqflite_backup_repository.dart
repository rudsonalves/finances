import '../../locator.dart';
import '../../store/database_helper.dart';
import '../user/user_repository.dart';
import 'backup_repository.dart';

class SqfliteBackupRepository extends BackupRepository {
  final helper = locator<DatabaseHelper>();

  @override
  Future<String?> createBackup([String? destinyPath]) async {
    String? result = await helper.backupDatabase(destinyPath);
    return result;
  }

  @override
  Future<bool> restoreBackup(String restorePath) async {
    bool result = await helper.restoreDatabase(restorePath);
    await locator<UserRepository>().restart();
    return result;
  }
}
