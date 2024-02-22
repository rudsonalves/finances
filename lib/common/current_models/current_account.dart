import '../../locator.dart';
import '../models/app_locale.dart';
import './current_user.dart';
import '../models/icons_model.dart';
import '../models/account_db_model.dart';
import '../constants/themes/app_icons.dart';
import '../../repositories/account/abstract_account_repository.dart';

class CurrentAccount extends AccountDbModel {
  final accountRepository = locator<AbstractAccountRepository>();

  CurrentAccount({
    int? accountId,
    required String accountName,
    required String accountUserId,
    required IconModel accountIcon,
    int? accountLastBalance,
    String? accountDescription,
  }) : super(
          accountId: accountId,
          accountName: accountName,
          accountUserId: accountUserId,
          accountIcon: accountIcon,
          accountDescription: accountDescription,
        );

  Future<void> init() async {
    await accountRepository.init();

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
      int id = await accountRepository.addAccount(account);
      currentUser.userMainAccountId = id;
      account.accountId = id;
      currentUser.updateUser();
    }

    setFromAccountDbModel(
      accountRepository.accountsMap[currentUser.userMainAccountId]!,
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
