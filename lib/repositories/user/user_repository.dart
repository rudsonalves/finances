import '../../common/models/user_db_model.dart';

abstract class UserRepository {
  Future<void> init();
  Future<void> restart();
  Map<String, UserDbModel> get users;
  Future<void> addUser(UserDbModel user);
  Map<String, dynamic> getUserMapById(String id);
  Future<void> updateUser(UserDbModel user);
}
