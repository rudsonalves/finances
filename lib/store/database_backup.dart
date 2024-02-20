import 'dart:developer';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';
import 'database_manager.dart';

abstract class DatabaseBackuper {
  Future<bool> restoreDatabase(String newDbPath);
  Future<String?> backupDatabase([String? destinyDir]);
}

/// Defines the interface for database backup and restoration operations.
class DatabaseBackup implements DatabaseBackuper {
  final _databaseManager = DatabaseManager();

  /// Restores the database from a backup located at [newDbPath].
  ///
  /// Returns `true` if the restoration is successful, `false` otherwise.
  @override
  Future<bool> restoreDatabase(String newDbPath) async {
    final database = await _databaseManager.database;

    final Directory directory = await getApplicationDocumentsDirectory();
    final String originalPath = join(directory.path, dbName);
    final backupPath = join(directory.path, '$dbName.bkp');

    try {
      final File backupFile = File(backupPath);
      if (await backupFile.exists()) {
        // Checks whether a backup file exists in backup path. If exists, remove it.
        await backupFile.delete();
      }

      // Copy original file to backup path
      final File originalFile = File(originalPath);
      await originalFile.copy(backupPath);

      // Close database before replace it
      await _databaseManager.databaseClose();

      if (await originalFile.exists()) {
        // Remove original database file
        await originalFile.delete();
      }

      // Copy new database fale do original database path
      await File(newDbPath).copy(originalPath);
      await _databaseManager.database;

      // Reopen database
      await backupFile.delete();

      return true;
    } catch (err) {
      log('Error backupDatabase: ${err.toString()}');
      final File backupFile = File(backupPath);
      // if error restore backup file
      if (await backupFile.exists()) {
        // Close database before restore database backup
        if (database.isOpen) _databaseManager.databaseClose();
        // Copy backup file to original original database file
        await backupFile.copy(originalPath);
        // Reopen database file.
        await _databaseManager.database;
        // Remove backup file
        await backupFile.delete();
      }
      return false;
    }
  }

  /// Creates a backup of the current database.
  ///
  /// Optionally, a [destinyDir] can be specified to store the backup.
  /// Returns the path to the backup file if successful, `null` otherwise.
  @override
  Future<String?> backupDatabase([String? destinyDir]) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String dbPath = join(directory.path, dbName);
      final strDate = DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now());

      String dbBackupPath;
      if (destinyDir == null) {
        dbBackupPath = join(directory.path, '${dbName}_bkp');
      } else {
        dbBackupPath = join(destinyDir, '${dbName}_bkp_$strDate');
      }

      final dbBackupFile = File(dbBackupPath);
      if (await dbBackupFile.exists()) {
        await dbBackupFile.delete();
      }

      final File dbFile = File(dbPath);
      await dbFile.copy(dbBackupPath);

      return dbBackupPath;
    } catch (err) {
      log('Error backupDatabase: ${err.toString()}');
      return null;
    }
  }
}
