import 'package:finances/common/constants/themes/app_icons.dart';
import 'package:finances/common/models/account_db_model.dart';
import 'package:finances/common/models/balance_db_model.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:finances/common/models/icons_model.dart';
import 'package:finances/common/models/transaction_db_model.dart';
import 'package:finances/common/models/transfer_db_model.dart';
import 'package:finances/common/models/user_db_model.dart';

TransactionDbModel createFakeTransaction({
  int? id = 1,
  int? balanceId = 1,
  int accountId = 1,
  String description = 'Test transaction',
  int categoryId = 1,
  double value = 100.0,
  TransStatus status = TransStatus.transactionChecked,
  int? transferId,
  ExtendedDate? date,
  int? ofxId,
}) {
  return TransactionDbModel(
    transId: id,
    transBalanceId: balanceId,
    transAccountId: accountId,
    transDescription: description,
    transCategoryId: categoryId,
    transValue: value,
    transStatus: status,
    transTransferId: transferId,
    transDate: date ?? ExtendedDate(2024, 1, 15, 12),
    transOfxId: ofxId,
  );
}

BalanceDbModel createFakeBalance({
  int? id = 1,
  int accountId = 1,
  ExtendedDate? date,
  int transactionCount = 1,
  double openingBalance = 0.0,
  double closingBalance = 100.0,
}) {
  return BalanceDbModel(
    balanceId: id,
    balanceAccountId: accountId,
    balanceDate: date ?? ExtendedDate(2024, 1, 15),
    balanceTransCount: transactionCount,
    balanceOpen: openingBalance,
    balanceClose: closingBalance,
  );
}

AccountDbModel createFakeAccount({
  int? id = 1,
  String name = 'Test account',
  String userId = 'test-user',
  String? description = 'Account fixture',
  IconModel? icon,
}) {
  return AccountDbModel(
    accountId: id,
    accountName: name,
    accountUserId: userId,
    accountDescription: description,
    accountIcon: icon ??
        IconModel(
          iconId: 1,
          iconName: 'wallet',
          iconFontFamily: IconsFontFamily.MaterialIcons,
        ),
  );
}

UserDbModel createFakeUser({
  String? id = 'test-user',
  String? name = 'Test User',
  String? email = 'test@example.com',
  bool logged = true,
  int? mainAccountId = 1,
  String theme = 'system',
  String language = 'pt_BR',
}) {
  return UserDbModel(
    userId: id,
    userName: name,
    userEmail: email,
    userLogged: logged,
    userMainAccountId: mainAccountId,
    userTheme: theme,
    userLanguage: language,
  );
}

TransferDbModel createFakeTransfer({
  int? id = 1,
  int? transactionId0 = 1,
  int? transactionId1 = 2,
  int? accountId0 = 1,
  int? accountId1 = 2,
}) {
  return TransferDbModel(
    transferId: id,
    transferTransId0: transactionId0,
    transferTransId1: transactionId1,
    transferAccount0: accountId0,
    transferAccount1: accountId1,
  );
}
