import '../../common/models/user_db_model.dart';

abstract class UserRepository {
  Future<void> init();
  Future<void> restart();
  Map<String, UserDbModel> get users;
  Future<void> addUser(UserDbModel user);
  Map<String, dynamic> getUserMapById(String id);
  Future<void> updateUser(UserDbModel user);
  Future<void> updateUserBudgetRef(UserDbModel user);
  Future<void> updateUserGrpShowGrid(UserDbModel user);
  Future<void> updateUserGrpShowDots(UserDbModel user);
  Future<void> updateUserGrpIsCurved(UserDbModel user);
  Future<void> updateUserGrpAreaChart(UserDbModel user);
  Future<void> updateUserLanguage(UserDbModel user);
  Future<void> updateUserTheme(UserDbModel user);
  Future<void> updateUserMaxTransactions(UserDbModel user);
}
