import '../../store/database_provider.dart';
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
