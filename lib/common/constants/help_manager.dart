// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

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
