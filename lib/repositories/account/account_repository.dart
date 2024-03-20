import '../../locator.dart';
import '../../common/models/account_db_model.dart';
import '../../common/current_models/current_user.dart';
import '../../store/account_store.dart';
import '../icons/abstract_icons_repository.dart';
import 'abstract_account_repository.dart';

class AccountRepository implements AbstractAccountRepository {
  final _store = AccountStore();
  final _currentUser = locator<CurrentUser>();
  final _iconRepository = locator<AbstractIconRepository>();

  AccountRepository();

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
        await _store.queryUserAccounts(_currentUser.userId!);

    _accounts.clear();

    for (var accountMap in accounts) {
      final account = await AccountDbModel.fromMap(accountMap);
      _accounts[account.accountId!] = account;
    }
  }

  @override
  Future<int> addAccount(AccountDbModel account) async {
    int id = await _addOnly(account);

    await _getUserAccounts();
    return id;
  }

  Future<int> _addOnly(AccountDbModel account) async {
    int result = await _iconRepository.addIcon(account.accountIcon);
    if (result > 0) {
      account.accountIcon.iconId = result;
    } else {
      throw Exception('addAccount: Write account.accountIcon error');
    }

    int id = await _store.insertAccount(account.toMap());
    if (id < 0) {
      throw Exception('addAccount return id $id');
    }
    account.accountId = id;
    return id;
  }

  @override
  Future<void> deleteAccount(AccountDbModel account) async {
    await _store.deleteTransactionsByAccountId(account.accountId!);
    await _store.deleteBalancesByAccountId(account.accountId!);
    await _store.deleteAccountId(account.accountId!);

    // await helper.deleteAccountId(account.accountId!);
    await _getUserAccounts();
  }

  @override
  Future<void> updateAccount(AccountDbModel account) async {
    await locator<AbstractIconRepository>().updateIcon(account.accountIcon);
    await _store.updateAccount(account.toMap());
    await _getUserAccounts();
  }

  @override
  AccountDbModel? getAccount(int accountId) {
    return accountsMap[accountId];
  }
}
