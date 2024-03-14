import 'dart:developer';

import '../common/models/ofx_account_model.dart';
import '../repositories/ofx_account/ofx_account_repository.dart';

sealed class OfxAccountManager {
  static final accountRepository = OfxAccountRepository();

  OfxAccountManager._();

  static Future<bool> add(OfxAccountModel ofxAccount) async {
    try {
      // Check if this ofx is registred
      final ofxCheck = await accountRepository.queryBankAccountIdStartDate(
        ofxAccount.bankAccountId,
        ofxAccount.startDate,
      );

      if (ofxCheck != null) {
        ofxAccount.copy(ofxCheck);
        return false;
      }

      // Write ofxAccount
      final result = await accountRepository.insert(ofxAccount);
      if (result < 1) {
        throw Exception('repository.insert return $result');
      }

      return true;
    } catch (err) {
      log('OfxAccountManager.addNewOfxAccount: $err');
      return false;
    }
  }
}
