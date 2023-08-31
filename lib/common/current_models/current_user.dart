import '../../locator.dart';
import '../../repositories/user/user_repository.dart';
import '../models/user_db_model.dart';
import 'current_language.dart';
import 'current_theme.dart';

class CurrentUser extends UserDbModel {
  final userRepository = locator.get<UserRepository>();

  Future<void> init() async {
    await userRepository.init();
  }

  Future<void> addUser() async {
    await userRepository.addUser(this);
  }

  Future<void> setUserTheme(String themeName) async {
    userTheme = themeName;
    await updateUser();
  }

  Future<void> setUserLanguage(String languageCode) async {
    userLanguage = languageCode;
    await updateUser();
  }

  void applyCurrentUserSettings() {
    locator.get<CurrentTheme>().setThemeFromThemeName(userTheme);
    locator.get<CurrentLanguage>().setFromLocaleCode(userLanguage);
  }
}
