import '../../locator.dart';
import '../../store/database/database_backup.dart';
import '../../store/database/database_provider.dart';
import '../user/abstract_user_repository.dart';
import 'abstract_backup_repository.dart';

class BackupRepository extends AbstractBackupRepository {
  BackupRepository({
    DatabaseBackuper? databaseBackuper,
    DatabaseProvider? databaseProvider,
    AbstractUserRepository? userRepository,
  })  : _databaseBackuper = databaseBackuper ?? DatabaseBackup(),
        _databaseProvider = databaseProvider ?? DatabaseProvide(),
        _userRepository = userRepository ?? locator<AbstractUserRepository>();

  final DatabaseBackuper _databaseBackuper;
  final DatabaseProvider _databaseProvider;
  final AbstractUserRepository _userRepository;

  @override
  Future<String?> createBackup([String? destinyPath]) {
    return _databaseBackuper.backupDatabase(destinyPath);
  }

  @override
  Future<bool> restoreBackup(String restorePath) async {
    final restored = await _databaseBackuper.restoreDatabase(
      restorePath,
    );

    if (!restored) {
      return false;
    }

    await _databaseProvider.init();
    await _userRepository.restart();

    return true;
  }
}
