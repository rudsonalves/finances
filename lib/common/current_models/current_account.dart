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

import '../../locator.dart';
import '../models/app_locale.dart';
import './current_user.dart';
import '../models/icons_model.dart';
import '../models/account_db_model.dart';
import '../constants/themes/app_icons.dart';
import '../../repositories/account/abstract_account_repository.dart';

class CurrentAccount extends AccountDbModel {
  final _accountRepository = locator<AbstractAccountRepository>();

  CurrentAccount({
    super.accountId,
    required super.accountName,
    required super.accountUserId,
    required super.accountIcon,
    int? accountLastBalance,
    super.accountDescription,
  });

  Future<void> init() async {
    await _accountRepository.init();

    final currentUser = locator<CurrentUser>();

    if (currentUser.userMainAccountId == null) {
      // create first Account
      final account = AccountDbModel(
        accountName: locator<AppLocale>().locale.mainAccounName,
        accountUserId: locator<CurrentUser>().userId!,
        accountIcon: IconModel(
          iconName: 'wallet',
          iconFontFamily: IconsFontFamily.MaterialIcons,
        ),
      );
      int id = await _accountRepository.addAccount(account);
      currentUser.userMainAccountId = id;
      account.accountId = id;
      currentUser.updateUser();
    }

    setFromAccountDbModel(
      _accountRepository.accountsMap[currentUser.userMainAccountId]!,
    );
  }

  void changeCurrenteAccount(AccountDbModel account) {
    setFromAccountDbModel(account);
  }

  void setFromAccountDbModel(AccountDbModel account) {
    accountId = account.accountId;
    accountName = account.accountName;
    accountUserId = account.accountUserId;
    accountIcon = account.accountIcon;
    accountDescription = account.accountDescription;
  }

  factory CurrentAccount.fromAccountDbModel(AccountDbModel account) {
    return CurrentAccount(
      accountId: account.accountId,
      accountName: account.accountName,
      accountUserId: account.accountUserId,
      accountIcon: account.accountIcon,
      accountDescription: account.accountDescription,
    );
  }
}
