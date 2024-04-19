const dbName = 'app_dataBase.db';
const dbVersion = 1;

const appControlTable = 'versionControl';
const appControlId = 'id';
const appControlVersion = 'version';
const appControlApp = 'appVersion';

const usersTable = 'usersTable';
const userId = 'userId';
const userName = 'userName';
const userEmail = 'userEmail';
const userLogged = 'userLogged';
const userMainAccountId = 'userMainAccountId';
const userTheme = 'userTheme';
const userLanguage = 'userLanguage';
const userGrpShowGrid = 'userGrpShowGrid';
const userGrpIsCurved = 'userGrpIsCurved';
const userGrpShowDots = 'userGrpShowDots';
const userGrpAreaChart = 'userGrpAreaChart';
const userBudgetRef = 'userBudgetRef';
const userCategoryList = 'userCategoryList';
const userMaxTransactions = 'userMaxTransactions';
const userOfxStopCategories = 'userOfxStopCategories';

const iconsTable = 'iconsTable';
const iconsNameIndex = 'idxIconsName';
const iconId = 'iconId';
const iconName = 'iconName';
const iconFontFamily = 'iconFontFamily';
const iconColor = 'iconColor';

const accountTable = 'accountTable';
const accountUserIndex = 'idxAccountUserId';
const accountId = 'accountId';
const accountName = 'accountName';
const accountDescription = 'accountDescription';
const accountUserId = 'accountUserId';
const accountIcon = 'accountIcon';

const balanceTable = 'balanceTable';
const balanceDateIndex = 'idxBalanceDate';
const checkBalancePreviousId = 'checkBalancePreviousId';
const checkBalanceNextId = 'checkBalanceNextId';
const balanceAccountIndex = 'idxBalanceAccount';
const balanceId = 'balanceId';
const balanceAccountId = 'balanceAccountId';
const balanceDate = 'balanceDate';
const balanceTransCount = 'balanceTransCount';
const balanceOpen = 'balanceOpen';
const balanceClose = 'balanceClose';

const categoriesTable = 'categoriesTable';
const categoriesNameIndex = 'idxCategoriesName';
const categoryId = 'categoryId';
const categoryName = 'categoryName';
const categoryIcon = 'categoryIcon';
const categoryBudget = 'categoryBudget';
const categoryIsIncome = 'categoryIsIncome';

const transactionsTable = 'transactionsTable';
const transactionsDateIndex = 'idxTransactionsDate';
const transactionsCategoryIndex = 'idxTransactionsCategory';
const transId = 'transId';
const transBalanceId = 'transBalanceId';
const transAccountId = 'transAccountId';
const transDescription = 'transDescription';
const transCategoryId = 'transCategoryId';
const transValue = 'transValue';
const transStatus = 'transStatus';
const transTransferId = 'transTransferId';
const transDate = 'transDate';
const transOfxId = 'transOfxId';

const transfersTable = 'transfersTable';
const transferId = 'transferId';
const transferTransId0 = 'transferTransId0';
const transferTransId1 = 'transferTransId1';
const transferAccount0 = 'transferAccount0';
const transferAccount1 = 'transferAccount1';

const ofxACCTable = 'ofxAccountTable';
const ofxAccountBankIndex = 'idxOfxAccountBank';
const ofxACCId = 'id';
const ofxACCAccountId = 'accountId';
const ofxACCBankAccountId = 'bankAccountId';
const ofxACCBankName = 'bankName';
const ofxACCType = 'accountType';
const ofxACCNTrans = 'nTrans';
const ofxACCStartDate = 'startDate';
const ofxACCEndDate = 'endDate';

const ofxRelationshipTable = 'ofxRelationshipTable';
const ofxRelaltionshipIndex = 'idxOfxRelationship';
const ofxRelId = 'id';
const ofxRelBankAccountId = 'bankAccountId';
const ofxRelBankName = 'bankName';
const ofxRelAccountId = 'accountId';

const ofxTransTemplateTable = 'ofxTransTemplateTable';
const ofxTransMemoIndex = 'idxOfxTransMemo';
const ofxTransAccountIndex = 'idxOfxTransAccount';
const ofxTransId = 'id';
const ofxTransMemo = 'memo';
const ofxTransAccountId = 'accountId';
const ofxTransCategoryId = 'categoryId';
const ofxTransDescription = 'description';
const ofxTransTransferAccountId = 'transferAccountId';

const triggerAfterInsertTransaction = 'tr_after_insert_transaction';
const triggerAfterDeleteTransaction = 'tr_after_delete_transaction';

const createAppControlSQL = 'CREATE TABLE IF NOT EXISTS $appControlTable ('
    ' $appControlId INTEGER PRIMARY KEY,'
    ' $appControlVersion INTEGER NOT NULL,'
    ' $appControlApp TEXT DEFAULT ""'
    ')';
const createUsersSQL = 'CREATE TABLE IF NOT EXISTS $usersTable ('
    ' $userId TEXT PRIMARY KEY NOT NULL,'
    ' $userName TEXT NOT NULL,'
    ' $userEmail TEXT UNIQUE NOT NULL,'
    ' $userLogged INTEGER NOT NULL,'
    ' $userMainAccountId INTEGER,'
    ' $userTheme TEXT NOT NULL,'
    ' $userLanguage TEXT NOT NULL,'
    ' $userGrpShowGrid INTEGER DEFAULT 1,'
    ' $userGrpIsCurved INTEGER DEFAULT 0,'
    ' $userGrpShowDots INTEGER DEFAULT 0,'
    ' $userGrpAreaChart INTEGER DEFAULT 0,'
    ' $userBudgetRef INTEGER DEFAULT 2,'
    ' $userCategoryList TEXT DEFAULT "[]",'
    ' $userMaxTransactions INTEGER DEFAULT 35,'
    ' $userOfxStopCategories TEXT DEFAULT "[1]",'
    ' FOREIGN KEY ($userMainAccountId)'
    '  REFERENCES $accountTable ($accountId)'
    '  ON DELETE CASCADE'
    ')';

const createIconsSQL = 'CREATE TABLE IF NOT EXISTS $iconsTable ('
    ' $iconId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $iconName TEXT NOT NULL,'
    ' $iconFontFamily TEXT NOT NULL,'
    ' $iconColor INTEGER NOT NULL'
    ')';

const createAccountsSQL = 'CREATE TABLE IF NOT EXISTS $accountTable ('
    ' $accountId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $accountName TEXT NOT NULL,'
    ' $accountDescription TEXT,'
    ' $accountUserId TEXT NOT NULL,'
    ' $accountIcon INTEGER,'
    ' FOREIGN KEY ($accountIcon)'
    '  REFERENCES $iconsTable ($iconId)'
    '  ON DELETE CASCADE,'
    ' FOREIGN KEY ($accountUserId)'
    '  REFERENCES $usersTable ($userId)'
    '  ON DELETE RESTRICT'
    ')';

const createAccountUserIndexSQL = 'CREATE INDEX IF NOT EXISTS $accountUserIndex'
    ' ON $accountTable ($accountUserId)';

const createBalanceSQL = 'CREATE TABLE IF NOT EXISTS $balanceTable ('
    ' $balanceId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $balanceAccountId INTEGER NOT NULL,'
    ' $balanceDate INTEGER NOT NULL,'
    ' $balanceTransCount INTEGER,'
    ' $balanceOpen REAL NOT NULL,'
    ' $balanceClose REAL NOT NULL,'
    ' FOREIGN KEY ($balanceAccountId)'
    '  REFERENCES $accountTable ($accountId)'
    '  ON DELETE RESTRICT'
    ')';

const createBalanceDateIndexSQL = 'CREATE INDEX IF NOT EXISTS $balanceDateIndex'
    ' ON $balanceTable ($balanceDate)';

const createBalanceAccountIndexSQL =
    'CREATE INDEX IF NOT EXISTS $balanceAccountIndex'
    ' ON $balanceTable ($balanceAccountId)';

const createCategorySQL = 'CREATE TABLE IF NOT EXISTS $categoriesTable ('
    ' $categoryId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $categoryName TEXT UNIQUE NOT NULL,'
    ' $categoryIcon INTEGER NOT NULL,'
    ' $categoryBudget REAL DEFAULT 0,'
    ' $categoryIsIncome INTEGER DEFAULT 0,'
    ' FOREIGN KEY ($categoryIcon)'
    '  REFERENCES $iconsTable ($iconId)'
    '  ON DELETE CASCADE'
    ')';

const createCategoriesNameIndexSQL =
    'CREATE INDEX IF NOT EXISTS $categoriesNameIndex'
    ' ON $categoriesTable ($categoryName)';

const createTransactionsSQL = 'CREATE TABLE IF NOT EXISTS $transactionsTable ('
    ' $transId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $transBalanceId INTEGER NOT NULL,'
    ' $transAccountId INTEGER NOT NULL,'
    ' $transDescription TEXT NOT NULL,'
    ' $transCategoryId INTEGER NOT NULL,'
    ' $transValue REAL NOT NULL,'
    ' $transStatus INTEGER NOT NULL,'
    ' $transTransferId INTEGER,'
    ' $transDate INTEGER NOT NULL,'
    ' $transOfxId INTEGER,'
    ' FOREIGN KEY ($transCategoryId)'
    '   REFERENCES $categoriesTable ($categoryId)'
    '   ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transBalanceId)'
    '   REFERENCES $balanceTable ($balanceId)'
    '   ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transAccountId)'
    '   REFERENCES $accountTable ($accountId)'
    '   ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transTransferId)'
    '   REFERENCES $transfersTable ($transferId)'
    '   ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transOfxId)'
    '   REFERENCES $ofxACCTable ($ofxACCId)'
    ')';

const createTransactionsDateIndexSQL =
    'CREATE INDEX IF NOT EXISTS $transactionsDateIndex'
    ' ON $transactionsTable ($transDate)';

const createTransactionsCategoryIndexSQL =
    'CREATE INDEX IF NOT EXISTS $transactionsCategoryIndex'
    ' ON $transactionsTable ($transCategoryId)';

const createTransfersSQL = 'CREATE TABLE IF NOT EXISTS $transfersTable ('
    ' $transferId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $transferTransId0 INTEGER,'
    ' $transferTransId1 INTEGER,'
    ' $transferAccount0 INTEGER,'
    ' $transferAccount1 INTEGER,'
    ' FOREIGN KEY ($transferTransId0)'
    '   REFERENCES $transactionsTable ($transId),'
    ' FOREIGN KEY ($transferTransId1)'
    '   REFERENCES $transactionsTable ($transId),'
    ' FOREIGN KEY ($transferAccount0)'
    '   REFERENCES $accountTable ($accountId)'
    '   ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transferAccount1)'
    '   REFERENCES $accountTable ($accountId)'
    '   ON DELETE RESTRICT'
    ')';

const createOfxACCSQL = 'CREATE TABLE IF NOT EXISTS $ofxACCTable ('
    ' $ofxACCId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $ofxACCAccountId INTEGER NOT NULL,'
    ' $ofxACCBankAccountId TEXT NOT NULL,'
    ' $ofxACCBankName TEXT,'
    ' $ofxACCType TEXT NOT NULL,'
    ' $ofxACCNTrans INTEGER NOT NULL,'
    ' $ofxACCStartDate INTEGER NOT NULL,'
    ' $ofxACCEndDate INTEGER NOT NULL,'
    ' FOREIGN KEY ($ofxACCAccountId)'
    '   REFERENCES $accountTable ($accountId),'
    ' FOREIGN KEY ($ofxACCBankAccountId)'
    '   REFERENCES $ofxRelationshipTable ($ofxRelBankAccountId)'
    ')';

const createOfxACCBankIndexSQL =
    'CREATE INDEX IF NOT EXISTS $ofxAccountBankIndex'
    ' ON $ofxACCTable ($ofxACCStartDate)';

const createOfxRelationshipTableSQL =
    'CREATE TABLE IF NOT EXISTS $ofxRelationshipTable ('
    ' $ofxRelId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $ofxRelBankAccountId TEXT UNIQUE NOT NULL,'
    ' $ofxRelAccountId INTEGER NOT NULL,'
    ' $ofxRelBankName TEXT,'
    ' FOREIGN KEY ($ofxRelAccountId)'
    '   REFERENCES $accountTable ($accountId)'
    ')';

const createOfxRelationshipIndexSQL =
    'CREATE INDEX IF NOT EXISTS $ofxRelaltionshipIndex'
    ' ON $ofxRelationshipTable ($ofxRelBankAccountId)';

const createOfxTransactionsSQL =
    'CREATE TABLE IF NOT EXISTS $ofxTransTemplateTable ('
    ' $ofxTransId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $ofxTransMemo TEXT NOT NULL,'
    ' $ofxTransAccountId INTEGER NOT NULL,'
    ' $ofxTransCategoryId INTEGER NOT NULL,'
    ' $ofxTransDescription TEXT,'
    ' $ofxTransTransferAccountId INTEGER,'
    ' FOREIGN KEY ($ofxTransAccountId)'
    '   REFERENCES $accountTable ($accountId),'
    ' FOREIGN KEY ($ofxTransCategoryId)'
    '   REFERENCES $categoriesTable ($categoryId),'
    ' FOREIGN KEY ($ofxTransTransferAccountId)'
    '   REFERENCES $accountTable ($accountId)'
    ')';

const createOfxTransMemoIndexSQL =
    'CREATE INDEX IF NOT EXISTS $ofxTransMemoIndex'
    ' ON $ofxTransTemplateTable ($ofxTransMemo)';

const createOfxTransAccountIndexSQL =
    'CREATE INDEX IF NOT EXISTS $ofxTransAccountIndex'
    ' ON $ofxTransTemplateTable ($ofxTransAccountId)';

const createTriggerAfterInsertTransaction =
    'CREATE TRIGGER IF NOT EXISTS $triggerAfterInsertTransaction'
    ' AFTER INSERT ON $transactionsTable'
    ' FOR EACH ROW'
    ' BEGIN'
    '   UPDATE $balanceTable'
    '   SET $balanceClose = $balanceClose + NEW.$transValue,'
    '       $balanceTransCount = IFNULL($balanceTransCount, 0) + 1'
    '   WHERE $balanceId = NEW.$transBalanceId;'
    '   UPDATE $balanceTable'
    '   SET $balanceClose = $balanceClose + NEW.$transValue,'
    '       $balanceOpen = $balanceOpen + NEW.$transValue'
    '   WHERE $balanceDate > NEW.$transDate'
    '     AND $balanceAccountId = NEW.$transAccountId;'
    ' END';

const createTriggerAfterDeleteTransaction =
    'CREATE TRIGGER IF NOT EXISTS $triggerAfterDeleteTransaction'
    ' AFTER DELETE ON $transactionsTable'
    ' FOR EACH ROW'
    ' BEGIN'
    '   UPDATE $balanceTable'
    '   SET $balanceClose = $balanceClose - OLD.$transValue,'
    '       $balanceTransCount = IFNULL($balanceTransCount, 0) - 1'
    '   WHERE $balanceId = OLD.$transBalanceId;'
    '   UPDATE $balanceTable'
    '   SET $balanceClose = $balanceClose - OLD.$transValue,'
    '       $balanceOpen = $balanceOpen - OLD.$transValue'
    '   WHERE $balanceDate > OLD.$transDate'
    '     AND $balanceAccountId = OLD.$transAccountId;'
    ' END';

const getIncomeBetweenDatesSQL = 'SELECT SUM($transValue) AS totalIncomes'
    ' FROM $transactionsTable'
    ' WHERE $transDate BETWEEN ? AND ?'
    '   AND $transValue > 0'
    '   AND $transAccountId = ?';

const getExpenseBetweenDatesSQL = 'SELECT SUM($transValue) AS totalExpenses'
    ' FROM $transactionsTable'
    ' WHERE $transDate BETWEEN ? AND ?'
    '   AND $transValue < 0'
    '   AND $transAccountId = ?';

const countTransactionForCategoryIdSQL =
    'SELECT COUNT(*) FROM $transactionsTable WHERE $transCategoryId = ?';

const countTransactionsForAccountIdSQL =
    'SELECT COUNT(*) FROM $transactionsTable WHERE $transAccountId = ?';
