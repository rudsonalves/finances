import 'package:sqflite/sqflite.dart';

import 'constants/constants.dart';

sealed class TablesCreators {
  TablesCreators._();

  static void createAppControlTable(Batch batch) {
    batch.execute(createAppControlSQL);
  }

  static void createUsersTable(Batch batch) {
    batch.execute(createUsersSQL);
  }

  static void createIconsTable(Batch batch) {
    batch.execute(createIconsSQL);
  }

  static void createAccountsTable(Batch batch) {
    batch.execute(createAccountsSQL);
    batch.execute(createAccountUserIndexSQL);
  }

  static void createBalanceTable(Batch batch) {
    batch.execute(createBalanceSQL);
    batch.execute(createBalanceDateIndexSQL);
    batch.execute(createBalanceAccountIndexSQL);
  }

  static void createCategoryTable(Batch batch) {
    batch.execute(createCategorySQL);
    batch.execute(createCategoriesNameIndexSQL);
  }

  static void createTransactionsTable(Batch batch) {
    batch.execute(createTransactionsSQL);
    batch.execute(createTransactionsDateIndexSQL);
    batch.execute(createTransactionsCategoryIndexSQL);
    batch.execute(createTransactionsAccountDateIndexSQL);
  }

  static void createOfxAccuntTable(Batch batch) {
    batch.execute(createOfxACCSQL);
    batch.execute(createOfxACCBankIndexSQL);
  }

  static void createOfxRelationshipTable(Batch batch) {
    batch.execute(createOfxRelationshipTableSQL);
    batch.execute(createOfxRelationshipIndexSQL);
  }

  static void createOfxTransactionsTable(Batch batch) {
    batch.execute(createOfxTransactionsSQL);
    batch.execute(createOfxTransMemoIndexSQL);
    batch.execute(createOfxTransAccountIndexSQL);
  }

  static void createOfxImportedTransactionsTable(Batch batch) {
    batch.execute(createOfxImportedTransactionsSQL);
    batch.execute(createOfxImportedTransactionUniqueIndexSQL);
  }

  static void createTransfersTable(Batch batch) {
    batch.execute(createTransfersSQL);
  }

  static void createTriggers(Batch batch) {
    batch.execute(createTriggerAfterInsertTransaction);
    batch.execute(createTriggerAfterDeleteTransaction);
  }
}
