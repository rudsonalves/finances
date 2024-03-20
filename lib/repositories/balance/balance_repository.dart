import 'dart:developer';

import '../../locator.dart';
import '../../store/balance_store.dart';
import 'abstract_balance_repository.dart';
import '../../common/models/extends_date.dart';
import '../../common/current_models/current_account.dart';
import '../../common/models/balance_db_model.dart';

class BalanceRepository implements AbstractBalanceRepository {
  final _store = BalanceStore();
  final _currentAccount = locator<CurrentAccount>();

  @override
  Future<int> insert(BalanceDbModel balance) async {
    int id = await _store.insert(balance.toMap());
    if (id < 0) {
      final message = 'addBalance: return id $id';
      log(message);
      throw Exception(message);
    }
    // Update balance id
    balance.balanceId = id;
    return id;
  }

  @override
  Future<BalanceDbModel> getId(int id) async {
    final map = await _store.queryId(id);
    if (map == null) {
      const message =
          'SqfliteBalanceRepository: null value in unexpected balance';
      log(message);
      throw Exception(message);
    }
    BalanceDbModel balance = BalanceDbModel.fromMap(map);

    return balance;
  }

  @override
  Future<BalanceDbModel?> getInDate({
    required ExtendedDate date,
    int? accountId,
  }) async {
    accountId ??= _currentAccount.accountId!;

    final map = await _store.queryInDate(
      accountId: accountId,
      date: date.millisecondsSinceEpoch,
    );
    if (map != null) return BalanceDbModel.fromMap(map);
    return null;
  }

  @override
  Future<List<BalanceDbModel>> getAllAfterDate({
    required ExtendedDate date,
    required int accountId,
  }) async {
    final mapsList = await _store.queryAllAfterDate(
      accountId: accountId,
      date: date.millisecondsSinceEpoch,
    );

    final List<BalanceDbModel> balancesList =
        List.from(mapsList.map((map) => BalanceDbModel.fromMap(map)));

    return balancesList;
  }

  @override
  Future<void> deleteId(int id) async {
    await _store.deleteId(id);
  }

  @override
  Future<void> update(BalanceDbModel balance) async {
    await _store.update(balance.toMap());
  }

  @override
  Future<void> deleteEmptyBalance(int id) async {
    await _store.deleteEmptyBalance(id);
  }

  @override
  Future<int> deleteAllEmptyBalances() async {
    return await _store.deleteAllEmptyBalances();
  }
}
