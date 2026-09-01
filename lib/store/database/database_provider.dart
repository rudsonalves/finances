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

abstract class DatabaseProvider {
  Future<void> init();

  Future<void> deleteDatabase();

  Future<void> updateAppVersion(String appVersion);

  Future<String> queryAppVersion();

  Future<void> dispose();
}

class DatabaseProvide implements DatabaseProvider {
  DatabaseProvide({
    DatabaseManager? databaseManager,
    DatabaseBackuper? databaseBackuper,
  })  : _databaseManager = databaseManager ?? locator<DatabaseManager>(),
        _databaseBackuper = databaseBackuper ?? DatabaseBackup();

  final DatabaseManager _databaseManager;
  final DatabaseBackuper _databaseBackuper;

  @override
  Future<void> init() async {
    final database = await _databaseManager.database;
    final currentVersion = await _getCurrentDatabaseSchemeVersion();
    final targetVersion = DatabaseMigrations.databaseSchemeVersion;

    if (currentVersion >= targetVersion) {
      return;
    }

    final backupPath = await _databaseBackuper.backupDatabase();

    if (backupPath == null) {
      throw StateError(
        'Database migration aborted because the safety backup failed.',
      );
    }

    try {
      await DatabaseMigrations.applyMigrations(
        db: database,
        currentVersion: currentVersion,
        targetVersion: targetVersion,
      );

      await _recordUpdateMigration(targetVersion);
    } catch (err) {
      final restored = await _databaseBackuper.restoreDatabase(
        backupPath,
      );

      if (!restored) {
        throw StateError(
          'Database migration failed and the safety backup '
          'could not be restored. Original error: $err',
        );
      }

      rethrow;
    }
  }

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
