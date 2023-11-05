import '../../locator.dart';
import '../models/user_db_model.dart';
import 'current_language.dart';
import 'current_theme.dart';

class CurrentUser extends UserDbModel {
  Future<void> init() async {
    await userRepository.init();
  }

  Future<void> addUser() async {
    await userRepository.addUser(this);
  }

  Future<void> setUserTheme(String themeName) async {
    userTheme = themeName;
    await updateUserTheme();
  }

  Future<void> setUserLanguage(String languageCode) async {
    userLanguage = languageCode;
    await updateUserLanguage();
  }

  void applyCurrentUserSettings() {
    locator<CurrentTheme>().setThemeFromThemeName(userTheme);
    locator<CurrentLanguage>().setFromLocaleCode(userLanguage);
  }
}
