import '../../locator.dart';
// import '../../common/models/icons_model.dart';
import '../../common/models/account_db_model.dart';
import '../../services/database/database_helper.dart';
// import '../../common/constants/themes/app_icons.dart';
import '../../common/current_models/current_user.dart';
import '../balance/balance_repository.dart';
import '../icons/icons_repository.dart';
import './account_repository.dart';

class SqfliteAccountRepository implements AccountRepository {
  final helper = locator.get<DatabaseHelper>();
  final currentUser = locator.get<CurrentUser>();
  final iconRepository = locator.get<IconRepository>();

  SqfliteAccountRepository();

  final Map<int, AccountDbModel> _accounts = {};
  bool isStarting = true;

  @override
  Map<int, AccountDbModel> get accountsMap => _accounts;

  @override
  List<AccountDbModel> get accountsList => _accounts.values.toList();

  @override
  int? accountIdByName(String name) {
    for (int id in accountsMap.keys) {
      if (accountsMap[id]!.accountName == name) {
        return id;
      }
    }
    return null;
  }

  @override
  Future<void> init() async {
    if (isStarting) {
      await _getUserAccounts();
      isStarting = false;
    }
  }

  @override
  Future<void> restart() async {
    isStarting = true;
    await init();
  }

  Future<void> _getUserAccounts() async {
    List<Map<String, dynamic>> accounts =
        await helper.queryUserAccounts(currentUser.userId!);

    _accounts.clear();

    for (var accountMap in accounts) {
      final account = await AccountDbModel.fromMap(accountMap);
      _accounts[account.accountId!] = account;
    }
  }

  @override
  Future<int> addAccount(AccountDbModel account) async {
    int id = await _addOnly(account);
    await locator.get<BalanceRepository>().createTodayBalance(account);

    await _getUserAccounts();
    return id;
  }

  Future<int> _addOnly(AccountDbModel account) async {
    int result = await iconRepository.addIcon(account.accountIcon);
    if (result > 0) {
      account.accountIcon.iconId = result;
    } else {
      throw Exception('addAccount: Write account.accountIcon error');
    }

    int id = await helper.insertAccount(account.toMap());
    if (id < 0) {
      throw Exception('addAccount return id $id');
    }
    account.accountId = id;
    return id;
  }

  @override
  Future<void> deleteAccount(AccountDbModel account) async {
    await helper.deleteTransactionsByAccountId(account.accountId!);
    await helper.deleteBalancesByAccountId(account.accountId!);
    await helper.deleteAccountId(account.accountId!);

    // await helper.deleteAccountId(account.accountId!);
    await _getUserAccounts();
  }

  @override
  Future<void> updateAccount(AccountDbModel account) async {
    await locator.get<IconRepository>().updateIcon(account.accountIcon);
    await helper.updateAccount(account.toMap());
    await _getUserAccounts();
  }

  @override
  AccountDbModel? getAccount(int accountId) {
    return accountsMap[accountId];
  }
}
