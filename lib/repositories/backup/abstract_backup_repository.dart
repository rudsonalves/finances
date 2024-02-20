abstract class AbstractBackupRepository {
  Future<String?> createBackup([String? destinyPath]);
  Future<bool> restoreBackup(String restorePath);
}
