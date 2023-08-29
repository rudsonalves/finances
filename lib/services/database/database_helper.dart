import 'package:sqflite/sqflite.dart';

abstract class DatabaseHelper {
  Database get db;
  Future<void> init();
  Future<void> restartTables();
  Future<void> restartTestTables();

  Future<int> insertUser(Map<String, dynamic> userMap);
  Future<Map<String, Object?>?> queryUserId(String id);
  Future<List<Map<String, dynamic>>> queryAllUsers();
  Future<void> updateUser(Map<String, dynamic> userMap);

  Future<int> insertIcon(Map<String, dynamic> iconMap);
  Future<int> updateIcon(Map<String, dynamic> iconMap);
  Future<Map<String, dynamic>?> queryIconId(int id);
  Future<void> deleteIconId(int id);

  Future<int> insertAccount(Map<String, dynamic> accountMap);
  Future<List<Map<String, dynamic>>> queryUserAccounts(String id);
  Future<void> deleteAccountId(int id);
  Future<void> updateAccount(Map<String, dynamic> accountMap);
  Future<void> deleteTransactionsByAccountId(int id);
  Future<void> deleteBalancesByAccountId(int id);

  Future<int> insertCategory(Map<String, dynamic> categoryMap);
  Future<List<Map<String, dynamic>>> queryAllCategories();
  Future<void> updateCategory(Map<String, dynamic> categoryMap);
  Future<void> deleteCategoryId(int id);

  Future<int> insertBalance(Map<String, dynamic> balanceMap);
  Future<Map<String, dynamic>?> queryBalanceId(int id);
  Future<Map<String, dynamic>?> queryBalanceDate({
    required int account,
    required int date,
  });
  Future<void> updateBalance(Map<String, dynamic> balanceMap);
  Future<void> deleteBalance(int id);

  Future<int> insertTransaction(Map<String, dynamic> transactionMap);
  Future<int> updateTransaction(Map<String, dynamic> transMap);
  Future<int> deleteTransactionId(int id);
  Future<Map<String, Object?>?> queryTransactionAtId(int id);
  Future<List<Map<String, dynamic>>> rawQueryTransForBalanceId(int id);

  Future<double> getIncomeBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  });
  Future<double> getExpenseBetweenDates({
    required int startDate,
    required int endDate,
    required int accountId,
  });

  Future<int> insertTransDay(Map<String, dynamic> transDayMap);
  Future<int> deleteTransDay(int id);
  Future<Map<String, Object?>?> queryTransDayId(int id);

  Future<int> insertTransfer(Map<String, dynamic> transferMap);
  Future<int> deleteTransferId(int id);
  Future<Map<String, Object?>?> queryTranferId(int id);
  Future<int> updateTransfer(Map<String, dynamic> transferMap);
  Future<int> updateTransactionStatus(int id, int newStatus);

  Future<void> logSchema();
  Future<void> logTables();
  Future<void> logTransactions();
  Future<void> logBalances();
  Future<void> logTransDay();
  Future<void> logTransfers();
  Future<void> logCategories();

  Future<int> countUsers();
  Future<int> countIcons();
  Future<int> countAccountsForUserId(String id);
  Future<int> countBalancesForAccountId(int id);
  Future<int> countTransactionsForAccountId(int id);

  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
  });

  String get dbSchemeVersion;
  Future<String?> backupDatabase([String? destinyDir]);
  Future<bool> restoreDatabase(String newDbPath);
}
