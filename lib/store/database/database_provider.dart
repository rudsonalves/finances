import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../locator.dart';
import '../constants/constants.dart';
import 'database_backup.dart';
import 'database_manager.dart';
import 'database_migrations.dart';

/// Provides high-level database operations and lifecycle management.
///
/// This class encapsulates the initialization of the database,
/// application of schema migrations, backup operations, and version management.
/// It relies on [DatabaseManager] for database connection management,
/// [DatabaseMigrations] for schema versioning and migrations, and
/// [DatabaseBackuper] for backup and restore functionality.
abstract class DatabaseProvider {
  /// Initializes the database, applies necessary migrations, and updates the
  /// schema version.
  ///
  /// This method checks the current schema version of the database and applies
  /// any pending migrations to bring the database up to the latest schema version.
  /// It also backs up the database before applying migrations as a safety measure.
  Future<void> init();

  /// Deletes the current database file from the device.
  ///
  /// This method is useful for resetting the database or during uninstallation processes.
  /// It ensures that the database file is completely removed from the device's storage.
  Future<void> deleteDatabase();

  /// Updates the application version stored in the appControl table.
  ///
  /// This method can be used to keep track of the application version that last modified the database.
  /// It helps in troubleshooting and migrations tied to specific app versions.
  ///
  /// Parameters:
  ///   - appVersion: The current version of the application to be recorded.
  Future<void> updateAppVersion(String appVersion);

  /// Queries the current application version stored in the database.
  ///
  /// This method retrieves the app version from the appControl table, which reflects
  /// the version of the application that last interacted with the database.
  ///
  /// Returns the application version as a string.
  Future<String> queryAppVersion();

  /// Closes the database connection when the DatabaseProvider is being disposed.
  ///
  /// This method ensures that the database connection is cleanly closed to prevent
  /// any potential resource leaks or locking issues.
  Future<void> dispose();
}

class DatabaseProvide implements DatabaseProvider {
  final _databaseManager = locator<DatabaseManager>();

  @override
  Future<void> init() async {
    final database = await _databaseManager.database;

    final backupDatabase = await DatabaseBackup().backupDatabase();
    try {
      int currentVersion = await _getCurrentDatabaseSchemeVersion();
      if (DatabaseMigrations.databaseSchemeVersion > currentVersion) {
        await DatabaseMigrations.applyMigrations(
          db: database,
          currentVersion: currentVersion,
          targetVersion: DatabaseMigrations.databaseSchemeVersion,
        );
        await _recordUpdateMigration(DatabaseMigrations.databaseSchemeVersion);
      }
    } catch (err) {
      if (backupDatabase != null) {
        await DatabaseBackup().restoreDatabase(backupDatabase);
      }
      log('DatabaseProvider.init: $err');
      await database.execute('PRAGMA foreign_keys=ON');
    }
  }

  /// Records the completion of a database schema migration in the appControl table.
  ///
  /// This method updates the appControl table with the latest schema version
  /// after successful migration. It ensures that the application is aware of
  /// the current schema version of the database.
  ///
  /// Parameters:
  ///   - targetVersion: The version number of the latest database schema.
  Future<void> _recordUpdateMigration(int targetVersion) async {
    final database = await _databaseManager.database;

    await database.update(
      appControlTable,
      {
        appControlVersion: targetVersion,
      },
      where: '$appControlId = 1',
    );
  }

  /// Retrieves the current schema version of the database.
  ///
  /// This method queries the appControl table to find the current version of the database schema.
  /// If no version is recorded, it assumes the database is at the latest version and records it.
  ///
  /// Returns the current schema version as an integer.
  Future<int> _getCurrentDatabaseSchemeVersion() async {
    final database = await _databaseManager.database;

    final List<Map<String, dynamic>> results = await database.query(
      appControlTable,
      where: '$appControlId = 1',
    );

    if (results.isEmpty) {
      await _recordMigration(DatabaseMigrations.databaseSchemeVersion);
      return DatabaseMigrations.databaseSchemeVersion;
    }

    return results.first[appControlVersion] as int;
  }

  /// Inserts the initial schema version into the appControl table.
  ///
  /// This method is called if no current schema version is found, indicating
  /// that the database is new. It records the latest schema version as the starting version.
  ///
  /// Parameters:
  ///   - targetVersion: The version number to be recorded as the initial database schema version.
  Future<void> _recordMigration(int targetVersion) async {
    final database = await _databaseManager.database;

    await database.insert(
      appControlTable,
      {
        appControlId: 1,
        appControlVersion: targetVersion,
        appControlApp: '',
      },
    );
  }

  @override
  Future<void> deleteDatabase() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, dbName);
    final database = await _databaseManager.database;

    if (database.isOpen) {
      await database.close();
    }

    await databaseFactory.deleteDatabase(path);
  }

  @override
  Future<void> updateAppVersion(String appVersion) async {
    final database = await _databaseManager.database;

    try {
      await database.update(
        appControlTable,
        {
          appControlApp: appVersion,
        },
        where: '$appControlId = 1',
      );
    } catch (err) {
      log('updateAppVersion: $err');
    }
  }

  @override
  Future<String> queryAppVersion() async {
    final database = await _databaseManager.database;

    try {
      final result = await database.query(
        appControlTable,
        where: '$appControlId = 1',
      );
      return result.first[appControlApp] as String;
    } catch (err) {
      log('queryAppVersion: $err');
      return '';
    }
  }

  @override
  Future<void> dispose() async {
    await _databaseManager.databaseClose();
  }
}
