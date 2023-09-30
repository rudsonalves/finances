class HelpManager {
  HelpManager._();

  static Map<String, bool> helpFlags = {
    'FirstEntry': false,
    'HomePage': false,
    'AccountPage': false,
    'CategoryPage': false,
    'StatistisPage': false,
    'SettingPage': false,
    'TransactionPage': false,
  };

  static bool shoudShowHelpPage(String pageName) {
    return helpFlags.containsKey(pageName) && helpFlags[pageName] == true;
  }

  static void markTutorialAsShown(String pageName) {
    helpFlags[pageName] = false;
  }
}
