import 'dart:convert';

import '../../repositories/account/abstract_account_repository.dart';
import './icons_model.dart';
import '../../locator.dart';
import '../../repositories/icons/abstract_icons_repository.dart';

class AccountDbModel {
  int? accountId;
  String accountName;
  String accountUserId;
  IconModel accountIcon;
  String? accountDescription;

  AccountDbModel({
    this.accountId,
    required this.accountName,
    required this.accountUserId,
    required this.accountIcon,
    this.accountDescription,
  });

  @override
  String toString() => 'Account('
      'Id: $accountId;'
      ' Name: "$accountName";'
      ' UserId: $accountUserId;'
      ' Icon: ${accountIcon.iconName}(${accountIcon.iconFontFamily});'
      ' Description: "$accountDescription"'
      ')';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accountId': accountId,
      'accountName': accountName,
      'accountUserId': accountUserId,
      'accountIcon': accountIcon.iconId!,
      'accountDescription': accountDescription,
    };
  }

  static Future<AccountDbModel> fromMap(Map<String, dynamic> map) async {
    int iconId = map['accountIcon'] as int;
    var accountIcon = await locator<AbstractIconRepository>().getIconId(iconId);

    return AccountDbModel(
      accountId: map['accountId'] as int?,
      accountName: map['accountName'] as String,
      accountUserId: map['accountUserId'] as String,
      accountIcon: accountIcon,
      accountDescription: map['accountDescription'] != null
          ? map['accountDescription'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  static Future<AccountDbModel> fromJson(String source) async {
    return await AccountDbModel.fromMap(
        json.decode(source) as Map<String, dynamic>);
  }

  Future<void> updateAccount() async {
    await locator<AbstractAccountRepository>().updateAccount(this);
  }
}
