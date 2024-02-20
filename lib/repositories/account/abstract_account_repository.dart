import '../../common/models/account_db_model.dart';

abstract class AbstractAccountRepository {
  Map<int, AccountDbModel> get accountsMap;
  int? accountIdByName(String name);
  List<AccountDbModel> get accountsList;
  Future<void> init();
  Future<void> restart();
  Future<int> addAccount(AccountDbModel account);
  Future<void> updateAccount(AccountDbModel account);
  Future<void> deleteAccount(AccountDbModel account);
  AccountDbModel? getAccount(int accountId);
}
