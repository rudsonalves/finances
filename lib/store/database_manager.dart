import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';
import 'database_migrations.dart';
import 'tables_creators.dart';

/// Manages all database operations for the application.
///
/// This class implements a singleton pattern to ensure that only one
/// instance of the database is created and used throughout the application.
/// It is responsible for initializing the database, executing migrations,
/// and creating tables as defined in `TablesCreators`.
class DatabaseManager {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Gets the single instance of the database, initializing it if necessary.
  ///
  /// Returns the [Database] instance for use in database operations.
  Future<void> databaseClose() async {
    if (_database != null) {
      await _database!.close();
    }
    _database = null;
  }

  /// Retrieves the current database schema version as a string.
  ///
  /// The version is derived from `DatabaseMigrations.dbSchemeVersion`.
  String get dbSchemeVersion => DatabaseMigrations.dbSchemeVersion;

  /// Closes the database connection and sets the instance to null.
  ///
  /// This method should be called when the database is no longer needed,
  /// for example, when the application is being closed.
  Future<Database> _initDatabase() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, dbName);

    // Only to reset database
    // databaseFactory.deleteDatabase(path);

    _database = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfiguration,
    );

    return _database!;
  }

  /// Callback for creating the database tables.
  ///
  /// This method is called the first time the database is created and
  /// utilizes `TablesCreators` to set up the initial database schema.
  Future<void> _onCreate(Database db, int version) async {
    try {
      Batch batch = db.batch();
      // Tables
      TablesCreators.createAppControlTable(batch);
      TablesCreators.createUsersTable(batch);
      TablesCreators.createIconsTable(batch);
      TablesCreators.createAccountsTable(batch);
      TablesCreators.createBalanceTable(batch);
      TablesCreators.createCategoryTable(batch);
      TablesCreators.createTransactionsTable(batch);
      TablesCreators.createTransDayTable(batch);
      TablesCreators.createTransfersTable(batch);
      TablesCreators.createTriggers(batch);
      await batch.commit();
    } catch (err) {
      log('Error: $err');
    }
  }

  /// Configures the database upon opening.
  ///
  /// Currently, this method enables foreign key support to ensure
  /// referential integrity.
  Future<void> _onConfiguration(Database db) async {
    // Add support for cascade delete
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
