import 'package:sqflite/sqflite.dart';

import '../../locator.dart';
import '../../store/constants/constants.dart';
import '../../store/database/database_manager.dart';
import 'abstract_ofx_import_repository.dart';

class OfxImportRepository implements AbstractOfxImportRepository {
  OfxImportRepository({Future<Database> Function()? databaseLoader})
      : _databaseLoader = databaseLoader;

  final Future<Database> Function()? _databaseLoader;

  Future<Database> get _database async {
    return _databaseLoader?.call() ?? locator<DatabaseManager>().database;
  }

  @override
  Future<bool> isImported({
    required String institutionId,
    required String bankAccountId,
    required String fitId,
  }) async {
    final database = await _database;
    final result = await database.query(
      ofxImportedTransactionsTable,
      columns: [ofxImportedTransactionId],
      where: '$ofxImportedTransactionInstitutionId = ? AND '
          '$ofxImportedTransactionBankAccountId = ? AND '
          '$ofxImportedTransactionFitId = ?',
      whereArgs: [institutionId, bankAccountId, fitId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  @override
  Future<bool> claim({
    required int ofxAccountId,
    required String institutionId,
    required String bankAccountId,
    required String fitId,
  }) async {
    final database = await _database;
    final id = await database.insert(
      ofxImportedTransactionsTable,
      {
        ofxImportedTransactionOfxAccountId: ofxAccountId,
        ofxImportedTransactionInstitutionId: institutionId,
        ofxImportedTransactionBankAccountId: bankAccountId,
        ofxImportedTransactionFitId: fitId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return id > 0;
  }

  @override
  Future<void> release({
    required String institutionId,
    required String bankAccountId,
    required String fitId,
  }) async {
    final database = await _database;
    await database.delete(
      ofxImportedTransactionsTable,
      where: '$ofxImportedTransactionInstitutionId = ? AND '
          '$ofxImportedTransactionBankAccountId = ? AND '
          '$ofxImportedTransactionFitId = ?',
      whereArgs: [institutionId, bankAccountId, fitId],
    );
  }
}
