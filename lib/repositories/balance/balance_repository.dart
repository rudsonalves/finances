import '../../common/models/account_db_model.dart';
import '../../locator.dart';
import '../../store/balance_store.dart';
import '../../store/managers/balance_manager.dart';
import 'abstract_balance_repository.dart';
import '../../common/models/extends_date.dart';
import '../../common/current_models/current_account.dart';
import '../../common/models/balance_db_model.dart';

class BalanceRepository implements AbstractBalanceRepository {
  final _store = BalanceStore();
  final _currentAccount = locator<CurrentAccount>();

  @override
  Future<void> addBalance(BalanceDbModel balance) async {
    int id = await _store.insertBalance(balance.toMap());
    if (id < 0) {
      throw Exception('addBalance return id $id');
    }
    balance.balanceId = id;
  }

  @override
  Future<BalanceDbModel> createTodayBalance(AccountDbModel? account) async {
    account ??= _currentAccount;

    final today = ExtendedDate.nowDate();

    BalanceDbModel? dateBalance = await getBalanceInDate(
      date: today,
      accountId: account.accountId,
    );

    // opens an existing balance in Date
    if (dateBalance != null) {
      return dateBalance;
    }

    final balance = BalanceDbModel(
      balanceAccountId: account.accountId,
      balanceDate: today,
    );

    // create a new balance and save it
    if (account.accountLastBalance == null) {
      // create the first balance in currentAccount
      await addBalance(balance);
      // update account accountLastBalance attribute
      account.accountLastBalance = balance.balanceId;
      await account.updateAccount();
      return balance;
    }

    await BalanceManager.injectBalance(
      injectedBalance: balance,
      account: account,
    );
    return balance;
  }

  // Return a balance in id
  @override
  Future<BalanceDbModel> getBalanceId(int id) async {
    final map = await _store.queryBalanceId(id);
    if (map == null) {
      throw Exception(
          'SqfliteBalanceRepository: null value in unexpected balance');
    }
    BalanceDbModel balance = BalanceDbModel.fromMap(map);

    return balance;
  }

  /// Return a [BalanceDbModel] balance in a passed [date] of type
  /// [ExtendedDate] and return it. Return null if the balance not exist.
  @override
  Future<BalanceDbModel?> getBalanceInDate({
    required ExtendedDate date,
    int? accountId,
  }) async {
    accountId ??= _currentAccount.accountId!;
    final map = await _store.queryBalanceDate(
      account: accountId,
      date: date.millisecondsSinceEpoch,
    );
    if (map != null) return BalanceDbModel.fromMap(map);
    return null;
  }

  @override
  Future<void> deleteBalance(int id) async {
    await _store.deleteBalance(id);
  }

  @override
  Future<void> updateBalance(BalanceDbModel balance) async {
    await _store.updateBalance(balance.toMap());
  }
}
