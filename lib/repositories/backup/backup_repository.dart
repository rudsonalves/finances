abstract class BackupRepository {
  Future<String?> createBackup([String? destinyPath]);
  Future<bool> restoreBackup(String restorePath);
}
