import 'dart:developer';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../locator.dart';
import '../constants/constants.dart';
import 'database_manager.dart';
import 'database_migrations.dart';

abstract class DatabaseBackuper {
  Future<bool> restoreDatabase(String newDbPath);
  Future<String?> backupDatabase([String? destinyDir]);
}

class DatabaseBackup implements DatabaseBackuper {
  final DatabaseManager _databaseManager;
  final Future<String> Function() _databasePathProvider;
  final DatabaseFactory _databaseFactory;
  final DateTime Function() _now;

  DatabaseBackup({
    DatabaseManager? databaseManager,
    DatabaseFactory? factory,
    Future<String> Function()? databasePathProvider,
    DateTime Function()? now,
  })  : _databaseManager = databaseManager ?? locator<DatabaseManager>(),
        _databaseFactory = factory ?? databaseFactory,
        _databasePathProvider = databasePathProvider ?? _defaultDatabasePath,
        _now = now ?? DateTime.now;

  @override
  Future<bool> restoreDatabase(String newDbPath) async {
    if (!await _isValidBackup(newDbPath)) {
      return false;
    }

    final database = await _databaseManager.database;

    final originalPath = await _databasePathProvider();
    final backupPath = '$originalPath.bkp';

    try {
      final File backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      final File originalFile = File(originalPath);
      await originalFile.copy(backupPath);

      await _databaseManager.databaseClose();

      if (await originalFile.exists()) {
        await originalFile.delete();
      }

      await File(newDbPath).copy(originalPath);
      await _databaseManager.database;

      await backupFile.delete();

      return true;
    } catch (err) {
      log('Error backupDatabase: ${err.toString()}');
      final File backupFile = File(backupPath);

      if (await backupFile.exists()) {
        if (database.isOpen) await _databaseManager.databaseClose();

        await backupFile.copy(originalPath);

        await _databaseManager.database;

        await backupFile.delete();
      }
      return false;
    }
  }

  @override
  Future<String?> backupDatabase([String? destinyDir]) async {
    try {
      await _databaseManager.database;

      final dbPath = await _databasePathProvider();
      final strDate = DateFormat('yyyy_MM_dd_HHmm').format(_now());

      String dbBackupPath;
      if (destinyDir == null) {
        dbBackupPath = '${dbPath}_bkp';
      } else {
        dbBackupPath = join(destinyDir, '${dbName}_bkp_$strDate');
      }

      final dbBackupFile = File(dbBackupPath);
      final temporaryBackupFile = File('$dbBackupPath.tmp');
      final previousBackupFile = File('$dbBackupPath.previous');

      if (await temporaryBackupFile.exists()) {
        await temporaryBackupFile.delete();
      }

      if (await previousBackupFile.exists()) {
        await previousBackupFile.delete();
      }

      final dbFile = File(dbPath);

      await dbFile.copy(temporaryBackupFile.path);

      var previousBackupWasMoved = false;

      try {
        if (await dbBackupFile.exists()) {
          await dbBackupFile.rename(previousBackupFile.path);
          previousBackupWasMoved = true;
        }

        await temporaryBackupFile.rename(dbBackupFile.path);

        if (previousBackupWasMoved && await previousBackupFile.exists()) {
          await previousBackupFile.delete();
        }
      } catch (_) {
        if (await dbBackupFile.exists()) {
          await dbBackupFile.delete();
        }

        if (previousBackupWasMoved && await previousBackupFile.exists()) {
          await previousBackupFile.rename(dbBackupFile.path);
        }

        rethrow;
      }

      return dbBackupPath;
    } catch (err) {
      final dbPath = await _databasePathProvider();
      final strDate = DateFormat('yyyy_MM_dd_HHmm').format(_now());

      final backupPath = destinyDir == null
          ? '${dbPath}_bkp'
          : join(destinyDir, '${dbName}_bkp_$strDate');

      final temporaryBackupFile = File('$backupPath.tmp');

      if (await temporaryBackupFile.exists()) {
        await temporaryBackupFile.delete();
      }

      log('Error backupDatabase: ${err.toString()}');
      return null;
    }
  }

  static Future<String> _defaultDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, dbName);
  }

  Future<bool> _isValidBackup(String path) async {
    Database? candidate;

    try {
      candidate = await _databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          singleInstance: false,
          readOnly: true,
        ),
      );

      final integrity = await candidate.rawQuery(
        'PRAGMA integrity_check',
      );

      if (integrity.isEmpty ||
          integrity.single.values.single.toString().toLowerCase() != 'ok') {
        return false;
      }

      final rows = await candidate.rawQuery(
        '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      ''',
      );

      final tableNames = rows.map((row) => row['name'] as String).toSet();

      final hasBaseTables = tableNames.containsAll(<String>{
        appControlTable,
        usersTable,
        accountTable,
        balanceTable,
        categoriesTable,
      });

      if (!hasBaseTables) {
        return false;
      }

      final versionRows = await candidate.query(
        appControlTable,
        columns: <String>[appControlVersion],
        where: '$appControlId = ?',
        whereArgs: <Object?>[1],
        limit: 1,
      );

      if (versionRows.isEmpty) {
        return tableNames.contains(transactionsTable);
      }

      final storedVersion = versionRows.single[appControlVersion];

      if (storedVersion is! num) {
        return false;
      }

      final version = storedVersion.toInt();

      if (version < 1000 ||
          version > DatabaseMigrations.databaseSchemeVersion) {
        return false;
      }

      if (version <= 1007) {
        return tableNames.containsAll(<String>{
          transfersTable,
          'transactonsTable',
          'transDayTable',
        });
      }

      return tableNames.contains(transactionsTable);
    } catch (err) {
      log('Invalid database backup: ${err.toString()}');
      return false;
    } finally {
      if (candidate != null && candidate.isOpen) {
        await candidate.close();
      }
    }
  }
}
