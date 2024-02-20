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
const accountLastBalance = 'accountLastBalance';

const balanceTable = 'balanceTable';
const balanceDateIndex = 'idxBalanceDate';
const checkBalancePreviousId = 'checkBalancePreviousId';
const checkBalanceNextId = 'checkBalanceNextId';
const balanceAccountIndex = 'idxBalanceAccount';
const balanceId = 'balanceId';
const balanceAccountId = 'balanceAccountId';
const balanceDate = 'balanceDate';
const balanceNextId = 'balanceNextId';
const balancePreviousId = 'balancePreviousId';
const balanceTransCount = 'balanceTransCount';
const balanceOpen = 'balanceOpen';
const balanceClose = 'balanceClose';

const transDayTable = 'transDayTable';
const transDayBalanceId = 'transDayBalanceId';
const transDayTransId = 'transDayTransId';

const categoriesTable = 'categoriesTable';
const categoriesNameIndex = 'idxCategoriesName';
const categoryId = 'categoryId';
const categoryName = 'categoryName';
const categoryIcon = 'categoryIcon';
const categoryBudget = 'categoryBudget';
const categoryIsIncome = 'categoryIsIncome';

const transactionsTable = 'transactonsTable';
const transactionsDateIndex = 'idxTransactionsDate';
const transactionsCategoryIndex = 'idxTransactionsCategory';
const transId = 'transId';
const transDescription = 'transDescription';
const transCategoryId = 'transCategoryId';
const transValue = 'transValue';
const transStatus = 'transStatus';
const transTransferId = 'transTransferId';
const transDate = 'transDate';

const transfersTable = 'transfersTable';
const transferId = 'transferId';
const transferTransId0 = 'transferTransId0';
const transferTransId1 = 'transferTransId1';
const transferAccount0 = 'transferAccount0';
const transferAccount1 = 'transferAccount1';

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
    ' $accountLastBalance INTEGER,'
    ' FOREIGN KEY ($accountIcon)'
    '  REFERENCES $iconsTable ($iconId)'
    '  ON DELETE CASCADE,'
    ' FOREIGN KEY ($accountUserId)'
    '  REFERENCES $usersTable ($userId)'
    '  ON DELETE RESTRICT'
    ')';

const createAccountUserIndexSQL =
    'CREATE INDEX IF NOT EXISTS $accountUserIndex '
    'ON $accountTable ($accountUserId)';

const createBalanceSQL = 'CREATE TABLE IF NOT EXISTS $balanceTable ('
    ' $balanceId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $balanceAccountId INTEGER NOT NULL,'
    ' $balanceDate INTEGER NOT NULL,'
    ' $balanceNextId INTEGER,'
    ' $balancePreviousId INTEGER,'
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
    ' $transDescription TEXT NOT NULL,'
    ' $transCategoryId INTEGER NOT NULL,'
    ' $transValue REAL NOT NULL,'
    ' $transStatus INTEGER NOT NULL,'
    ' $transTransferId INTEGER,'
    ' $transDate INTEGER NOT NULL,'
    ' FOREIGN KEY ($transCategoryId)'
    '  REFERENCES $categoriesTable ($categoryId)'
    '  ON DELETE RESTRICT'
    ')';

const createTransactionsDateIndexSQL =
    'CREATE INDEX IF NOT EXISTS $transactionsDateIndex'
    ' ON $transactionsTable ($transDate)';

const createTransactionsCategoryIndexSQL =
    'CREATE INDEX IF NOT EXISTS $transactionsCategoryIndex'
    ' ON $transactionsTable ($transCategoryId)';

const createTransDaySQL = 'CREATE TABLE IF NOT EXISTS $transDayTable ('
    ' $transDayTransId INTEGER PRIMARY KEY NOT NULL,'
    ' $transDayBalanceId INTEGER NOT NULL,'
    ' FOREIGN KEY ($transDayBalanceId)'
    '  REFERENCES $balanceTable ($balanceId)'
    '  ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transDayTransId)'
    '  REFERENCES $transactionsTable ($transId)'
    '  ON DELETE CASCADE'
    ')';

const createTransfersSQL = 'CREATE TABLE IF NOT EXISTS $transfersTable ('
    ' $transferId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $transferTransId0 INTEGER NOT NULL,'
    ' $transferTransId1 INTEGER NOT NULL,'
    ' $transferAccount0 INTEGER NOT NULL,'
    ' $transferAccount1 INTEGER NOT NULL,'
    ' FOREIGN KEY ($transferTransId0)'
    '  REFERENCES $transactionsTable ($transId)'
    '  ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transferTransId1)'
    '  REFERENCES $transactionsTable ($transId)'
    '  ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transferAccount0)'
    '  REFERENCES $accountTable ($accountId)'
    '  ON DELETE RESTRICT,'
    ' FOREIGN KEY ($transferAccount1)'
    '  REFERENCES $accountTable ($accountId)'
    '  ON DELETE RESTRICT'
    ')';

const createTriggerCheckBalanceNextIdSQL =
    'CREATE TRIGGER IF NOT EXISTS $checkBalanceNextId'
    ' BEFORE INSERT ON $balanceTable'
    ' FOR EACH ROW'
    ' BEGIN'
    '   SELECT CASE'
    '     WHEN NEW.$balanceNextId IS NOT NULL THEN'
    '       CASE WHEN EXISTS(SELECT 1 FROM $balanceTable'
    '       WHERE $balanceId = NEW.$balanceNextId) THEN'
    '       1 ELSE RAISE(ABORT, \'Invalid $balanceNextId\') END'
    '     ELSE 1'
    '   END;'
    ' END;';

const createTriggerCheckBalancePreviousIdSQL =
    'CREATE TRIGGER IF NOT EXISTS $checkBalancePreviousId'
    ' BEFORE INSERT ON $balanceTable'
    ' FOR EACH ROW'
    ' BEGIN'
    '   SELECT CASE'
    '     WHEN NEW.$balancePreviousId IS NOT NULL THEN'
    '       CASE WHEN EXISTS(SELECT 1 FROM $balanceTable'
    '       WHERE $balanceId = NEW.$balancePreviousId) THEN'
    '       1 ELSE RAISE(ABORT, \'Invalid $balancePreviousId\') END'
    '     ELSE 1'
    '   END;'
    ' END;';

const rawQueryTransForBalanceIdSQL = 'SELECT t.*'
    ' FROM $balanceTable b'
    ' JOIN $transDayTable td ON b.$balanceId = td.$transDayBalanceId'
    ' JOIN $transactionsTable t ON td.$transDayTransId = t.$transId'
    ' WHERE b.$balanceId = ?'
    ' ORDER BY t.transDate DESC';

const getIncomeBetweenDatesSQL = 'SELECT SUM($transValue) AS totalIncomes'
    ' FROM $transactionsTable'
    ' WHERE $transDate BETWEEN ? AND ?'
    '   AND $transValue > 0'
    '   AND $transId IN ('
    '     SELECT $transDayTransId'
    '     FROM $transDayTable'
    '     WHERE $transDayBalanceId IN ('
    '       SELECT $balanceId'
    '       FROM $balanceTable'
    '       WHERE $balanceAccountId = ?'
    '     )'
    '   )';

const getExpenseBetweenDatesSQL = 'SELECT SUM($transValue) AS totalExpenses'
    ' FROM $transactionsTable'
    ' WHERE $transDate BETWEEN ? AND ?'
    '   AND $transValue < 0'
    '   AND $transId IN ('
    '     SELECT $transDayTransId'
    '     FROM $transDayTable'
    '     WHERE $transDayBalanceId IN ('
    '       SELECT $balanceId'
    '       FROM $balanceTable'
    '       WHERE $balanceAccountId = ?'
    '     )'
    '   )';
