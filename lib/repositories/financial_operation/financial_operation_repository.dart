import 'package:sqflite/sqflite.dart';

import '../../common/models/transaction_db_model.dart';
import '../../common/models/transfer_db_model.dart';
import '../../locator.dart';
import '../../store/constants/constants.dart';
import '../../store/database/database_manager.dart';
import 'abstract_financial_operation_repository.dart';

typedef DatabaseLoader = Future<Database> Function();

class FinancialOperationRepository
    implements AbstractFinancialOperationRepository {
  FinancialOperationRepository({DatabaseLoader? databaseLoader})
      : _databaseLoader =
            databaseLoader ?? (() => locator<DatabaseManager>().database);

  final DatabaseLoader _databaseLoader;

  @override
  Future<TransferOperationResult> addTransfer({
    required TransactionDbModel origin,
    required int destinationAccountId,
  }) async {
    final database = await _databaseLoader();
    final result = await database.transaction(
      (transaction) => _insertTransfer(
        transaction,
        origin: origin,
        destinationAccountId: destinationAccountId,
      ),
    );

    origin
      ..transId = result.originTransactionId
      ..transTransferId = result.transferId;
    return result;
  }

  @override
  Future<int> removeTransfer({required int transferId}) async {
    final database = await _databaseLoader();
    return database.transaction(
      (transaction) => _removeTransfer(transaction, transferId),
    );
  }

  @override
  Future<TransferOperationResult> updateTransfer({
    required TransactionDbModel transaction,
    required int destinationAccountId,
  }) async {
    final transferIdToRemove = transaction.transTransferId;
    if (transferIdToRemove == null) {
      throw ArgumentError('The transaction is not associated with a transfer');
    }

    final database = await _databaseLoader();
    final result = await database.transaction((databaseTransaction) async {
      await _removeTransfer(databaseTransaction, transferIdToRemove);
      return _insertTransfer(
        databaseTransaction,
        origin: transaction,
        destinationAccountId: destinationAccountId,
      );
    });

    transaction
      ..transId = result.originTransactionId
      ..transTransferId = result.transferId;
    return result;
  }

  @override
  Future<int> updateTransaction(TransactionDbModel transaction) async {
    final transactionId = transaction.transId;
    if (transactionId == null) {
      throw ArgumentError('The transaction must have an id');
    }

    final database = await _databaseLoader();
    final newId = await database.transaction((databaseTransaction) async {
      final originalMaps = await databaseTransaction.query(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: [transactionId],
        limit: 1,
      );
      if (originalMaps.isEmpty) {
        throw StateError('Transaction $transactionId not found');
      }

      final original = TransactionDbModel.fromMap(originalMaps.single);
      final deleted = await databaseTransaction.delete(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: [transactionId],
      );
      if (deleted != 1) {
        throw StateError('Unable to delete transaction $transactionId');
      }
      await _deleteEmptyBalance(
        databaseTransaction,
        original.transBalanceId!,
      );

      final newBalanceId = await _getOrCreateBalance(
        databaseTransaction,
        accountId: transaction.transAccountId,
        date: transaction.transDate.millisecondsSinceEpoch,
      );

      final transactionMap = transaction.toMap()
        ..[transId] = null
        ..[transBalanceId] = newBalanceId;
      return databaseTransaction.insert(
        transactionsTable,
        transactionMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });

    transaction.transId = newId;
    return newId;
  }

  Future<TransferOperationResult> _insertTransfer(
    Transaction databaseTransaction, {
    required TransactionDbModel origin,
    required int destinationAccountId,
  }) async {
    if (origin.transAccountId == destinationAccountId) {
      throw ArgumentError('Origin and destination accounts must be different');
    }

    final originBalanceId = await _getOrCreateBalance(
      databaseTransaction,
      accountId: origin.transAccountId,
      date: origin.transDate.millisecondsSinceEpoch,
    );
    final destinationBalanceId = await _getOrCreateBalance(
      databaseTransaction,
      accountId: destinationAccountId,
      date: origin.transDate.millisecondsSinceEpoch,
    );

    final transferIdValue = await databaseTransaction.insert(
      transfersTable,
      TransferDbModel().toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    final originMap = origin.toMap()
      ..[transId] = null
      ..[transBalanceId] = originBalanceId
      ..[transTransferId] = transferIdValue;
    final originId = await databaseTransaction.insert(
      transactionsTable,
      originMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    final destination = origin.copyToTransfer(destinationAccountId);
    final destinationMap = destination.toMap()
      ..[transId] = null
      ..[transBalanceId] = destinationBalanceId
      ..[transTransferId] = transferIdValue;
    final destinationId = await databaseTransaction.insert(
      transactionsTable,
      destinationMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    final updated = await databaseTransaction.update(
      transfersTable,
      {
        transferTransId0: originId,
        transferTransId1: destinationId,
        transferAccount0: origin.transAccountId,
        transferAccount1: destinationAccountId,
      },
      where: '$transferId = ?',
      whereArgs: [transferIdValue],
    );
    if (updated != 1) {
      throw StateError('Unable to complete transfer $transferIdValue');
    }

    return TransferOperationResult(
      transferId: transferIdValue,
      originTransactionId: originId,
      destinationTransactionId: destinationId,
    );
  }

  Future<int> _removeTransfer(
    Transaction databaseTransaction,
    int transferIdValue,
  ) async {
    final transferMaps = await databaseTransaction.query(
      transfersTable,
      where: '$transferId = ?',
      whereArgs: [transferIdValue],
      limit: 1,
    );
    if (transferMaps.isEmpty) {
      throw StateError('Transfer $transferIdValue not found');
    }
    final transfer = TransferDbModel.fromMap(transferMaps.single);

    final transactionMaps = await databaseTransaction.query(
      transactionsTable,
      columns: [transId, transBalanceId],
      where: '$transId IN (?, ?)',
      whereArgs: [transfer.transferTransId0, transfer.transferTransId1],
    );
    if (transactionMaps.length != 2) {
      throw StateError('Transfer $transferIdValue is incomplete');
    }

    await databaseTransaction.update(
      transfersTable,
      {
        transferTransId0: null,
        transferTransId1: null,
        transferAccount0: null,
        transferAccount1: null,
      },
      where: '$transferId = ?',
      whereArgs: [transferIdValue],
    );

    for (final transactionMap in transactionMaps) {
      final deleted = await databaseTransaction.delete(
        transactionsTable,
        where: '$transId = ?',
        whereArgs: [transactionMap[transId]],
      );
      if (deleted != 1) {
        throw StateError('Unable to remove a transfer transaction');
      }
      await _deleteEmptyBalance(
        databaseTransaction,
        transactionMap[transBalanceId] as int,
      );
    }

    final deleted = await databaseTransaction.delete(
      transfersTable,
      where: '$transferId = ?',
      whereArgs: [transferIdValue],
    );
    if (deleted != 1) {
      throw StateError('Unable to remove transfer $transferIdValue');
    }
    return deleted;
  }

  Future<int> _getOrCreateBalance(
    Transaction databaseTransaction, {
    required int accountId,
    required int date,
  }) async {
    final balances = await databaseTransaction.query(
      balanceTable,
      where: '$balanceDate <= ? AND $balanceAccountId = ?',
      whereArgs: [date, accountId],
      orderBy: '$balanceDate DESC',
      limit: 1,
    );
    if (balances.isNotEmpty && balances.single[balanceDate] == date) {
      return balances.single[balanceId] as int;
    }

    final previousClosingBalance = balances.isEmpty
        ? 0.0
        : (balances.single[balanceClose] as num).toDouble();
    return databaseTransaction.insert(
      balanceTable,
      {
        balanceAccountId: accountId,
        balanceDate: date,
        balanceTransCount: 0,
        balanceOpen: previousClosingBalance,
        balanceClose: previousClosingBalance,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> _deleteEmptyBalance(
    Transaction databaseTransaction,
    int balanceIdValue,
  ) async {
    await databaseTransaction.delete(
      balanceTable,
      where: '$balanceId = ? AND IFNULL($balanceTransCount, 0) = 0',
      whereArgs: [balanceIdValue],
    );
  }
}
