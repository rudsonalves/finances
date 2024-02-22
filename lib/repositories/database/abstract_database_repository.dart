abstract class AbstractDatabaseRepository {
  Future<void> init();
  Future<void> deleteDatabase();
  Future<void> updateAppVersion(String appVersion);
  Future<String> queryAppVersion();
  Future<void> dispose();
}
