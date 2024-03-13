import 'package:sqflite/sqflite.dart';

import 'constants.dart';

/// Provides methods to create database tables and associated indices.
///
/// This class encapsulates the SQL commands for creating tables and indices
/// necessary for the application's database schema. It also includes
/// the creation of triggers for maintaining data integrity.
class TablesCreators {
  /// Creates the AppControl table using predefined SQL commands.
  ///
  /// The AppControl table stores key application settings and version
  /// information.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createAppControlTable(Batch batch) {
    batch.execute(createAppControlSQL);
  }

  /// Creates the Users table using predefined SQL commands.
  ///
  /// The Users table stores user information including user credentials and
  /// preferences.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createUsersTable(Batch batch) {
    batch.execute(createUsersSQL);
  }

  /// Creates the Icons table using predefined SQL commands.
  ///
  /// The Icons table stores icon information used throughout the application.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createIconsTable(Batch batch) {
    batch.execute(createIconsSQL);
  }

  /// Creates the Accounts table and an index for user IDs using predefined SQL
  /// commands.
  ///
  /// The Accounts table stores account information for users. An index on user
  /// IDs is also created for faster query performance.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createAccountsTable(Batch batch) {
    batch.execute(createAccountsSQL);
    batch.execute(createAccountUserIndexSQL);
  }

  /// Creates the Balance table and associated indices using predefined SQL
  /// commands.
  ///
  /// The Balance table stores balance information for accounts. Indices on date
  /// and account ID are created for improved query performance.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createBalanceTable(Batch batch) {
    batch.execute(createBalanceSQL);
    batch.execute(createBalanceDateIndexSQL);
    batch.execute(createBalanceAccountIndexSQL);
  }

  /// Creates the Category table and a name index using predefined SQL commands.
  ///
  /// The Category table stores transaction category information. A name index
  /// is created to enhance lookup speeds.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createCategoryTable(Batch batch) {
    batch.execute(createCategorySQL);
    batch.execute(createCategoriesNameIndexSQL);
  }

  /// Creates the Transactions table and associated indices using predefined SQL
  /// commands.
  ///
  /// The Transactions table stores transaction details. Date and category
  /// indices are created for faster sorting and querying.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createTransactionsTable(Batch batch) {
    batch.execute(createTransactionsSQL);
    batch.execute(createTransactionsDateIndexSQL);
    batch.execute(createTransactionsCategoryIndexSQL);
  }

  /// Creates the OfxAccuntTable table and associated indices using predefined
  /// SQL commands.
  ///
  /// The OfxAccunt table stores the relationship between ofx ACCTIDs and user
  /// accounts.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createOfxAccuntTable(Batch batch) {
    batch.execute(createOfxACCSQL);
    batch.execute(createOfxACCBankIndexSQL);
  }

  /// Creates the ofxRelationshipTable table and associated indices using
  /// predefined SQL commands.
  ///
  /// The ofxRelationship table stores ofx accounts relationship between and
  /// user accounts.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createOfxRelationshipTable(Batch batch) {
    batch.execute(createOfxRelationshipTableSQL);
    batch.execute(createOfxRelationshipIndexSQL);
  }

  /// Creates the OfxTransactionsTable table and associated indices using
  /// predefined SQL commands.
  ///
  /// The OfxTransactions table stores ofx transaction relationship between and
  /// user transactions.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createOfxTransactionsTable(Batch batch) {
    batch.execute(createOfxTransactionsSQL);
    batch.execute(createOfxTransMemoIndexSQL);
    batch.execute(createOfxTransAccountIndexSQL);
  }

  /// Creates the Transfers table using predefined SQL commands.
  ///
  /// The Transfers table stores information about transfers between accounts.
  /// - Parameter batch: The database batch in which the SQL command is to be
  ///   executed.
  static void createTransfersTable(Batch batch) {
    batch.execute(createTransfersSQL);
  }

  /// Creates database triggers to update ballanceTable balanceClose
  /// using predefined SQL commands.
  ///
  /// This includes triggers for update balanceClose in insert/delete/update
  /// transactions
  /// - Parameter batch: The database batch in which the SQL commands are to be
  ///   executed.
  static void createTriggers(Batch batch) {
    batch.execute(createTriggerAfterInsertTransaction);
    batch.execute(createTriggerAfterDeleteTransaction);
  }
}
