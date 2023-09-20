import '../../locator.dart';
import './current_user.dart';
import '../models/icons_model.dart';
import '../models/account_db_model.dart';
import '../constants/themes/app_icons.dart';
import '../../repositories/account/account_repository.dart';

class CurrentAccount extends AccountDbModel {
  final accountRepository = locator.get<AccountRepository>();

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
          accountLastBalance: accountLastBalance,
          accountDescription: accountDescription,
        );

  Future<void> init() async {
    await accountRepository.init();

    final currentUser = locator.get<CurrentUser>();

    if (currentUser.userMainAccountId == null) {
      // create first Account
      final account = AccountDbModel(
        accountName: 'main',
        accountUserId: locator.get<CurrentUser>().userId!,
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

    // print(currentUser.toString());
    // for (final id in accountRepository.accountsMap.keys) {
    //   print('id: $id');
    //   print(accountRepository.accountsMap[id].toString());
    // }

    setFromAccountDbModel(
        accountRepository.accountsMap[currentUser.userMainAccountId]!);
  }

  void changeCurrenteAccount(AccountDbModel account) {
    setFromAccountDbModel(account);
  }

  void setFromAccountDbModel(AccountDbModel account) {
    accountId = account.accountId;
    accountName = account.accountName;
    accountUserId = account.accountUserId;
    accountIcon = account.accountIcon;
    accountLastBalance = account.accountLastBalance;
    accountDescription = accountDescription;
  }

  factory CurrentAccount.fromAccountDbModel(AccountDbModel account) {
    return CurrentAccount(
      accountId: account.accountId,
      accountName: account.accountName,
      accountUserId: account.accountUserId,
      accountIcon: account.accountIcon,
      accountLastBalance: account.accountLastBalance,
      accountDescription: account.accountDescription,
    );
  }
}
