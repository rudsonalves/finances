import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/constants.dart';
import '../tables_creators.dart';
import 'database_migrations.dart';

class DatabaseManager {
  DatabaseManager({
    DatabaseFactory? factory,
    Future<String> Function()? databasePathProvider,
  })  : _databaseFactory = factory ?? databaseFactory,
        _databasePathProvider = databasePathProvider ?? _defaultDatabasePath;

  final DatabaseFactory _databaseFactory;
  final Future<String> Function() _databasePathProvider;

  Database? _database;

  static Future<String> _defaultDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, dbName);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> databaseClose() async {
    if (_database != null) {
      await _database!.close();
    }
    _database = null;
  }

  String get dbSchemeVersion => DatabaseMigrations.dbSchemeVersion;

  Future<Database> _initDatabase() async {
    final path = await _databasePathProvider();

    _database = await _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: dbVersion,
        onCreate: _onCreate,
        onConfigure: _onConfiguration,
      ),
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    TablesCreators.createAppControlTable(batch);
    TablesCreators.createUsersTable(batch);
    TablesCreators.createIconsTable(batch);
    TablesCreators.createAccountsTable(batch);
    TablesCreators.createBalanceTable(batch);
    TablesCreators.createCategoryTable(batch);
    TablesCreators.createTransactionsTable(batch);
    TablesCreators.createTransfersTable(batch);
    TablesCreators.createOfxAccuntTable(batch);
    TablesCreators.createOfxRelationshipTable(batch);
    TablesCreators.createOfxTransactionsTable(batch);
    TablesCreators.createOfxImportedTransactionsTable(batch);
    TablesCreators.createTriggers(batch);

    await batch.commit(noResult: true);
  }

  Future<void> _onConfiguration(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
