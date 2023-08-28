import '../../locator.dart';
import './user_repository.dart';
import '../../services/database/database_helper.dart';
import '../../common/models/user_db_model.dart';

class SqfliteUserRepository implements UserRepository {
  final DatabaseHelper helper = locator.get<DatabaseHelper>();
  final Map<String, UserDbModel> _users = {};
  bool isStarting = true;

  @override
  Map<String, UserDbModel> get users => _users;

  @override
  Future<void> init() async {
    if (isStarting) {
      await _getUsers();
      isStarting = false;
    }
  }

  @override
  Future<void> restart() async {
    isStarting = true;
    await init();
  }

  Future<void> _getUsers() async {
    List<Map<String, dynamic>> users = await helper.queryAllUsers();
    _users.clear();
    _users.addEntries(
      users.map(
        (userMap) {
          final user = UserDbModel.fromMap(userMap);
          return MapEntry(user.userId!, user);
        },
      ),
    );
  }

  @override
  Future<void> addUser(UserDbModel user) async {
    Map<String, dynamic> userMap = user.toMap();
    int result = await helper.insertUser(userMap);
    if (result < 0) {
      throw Exception('addUser return id $result');
    }
    await _getUsers();
  }

  @override
  Future<void> updateUser(UserDbModel user) async {
    await helper.updateUser(user.toMap());
    await _getUsers();
  }

  // @override
  // void setCurrentUserByEmail(String email) {
  //   for (var user in _users.values) {
  //     if (user.userEmail == email) {
  //       getIt.get<CurrentUser>().setFromUserMap(user.toMap());
  //       return;
  //     }
  //   }
  //   throw Exception('Error: User with email "$email" not found!');
  // }

  @override
  Map<String, dynamic> getUserMapById(String id) {
    return _users[id]!.toMap();
  }
}
