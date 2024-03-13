import 'dart:developer';

import 'package:finances/packages/ofx/lib/ofx.dart';

import '../common/models/ofx_account_model.dart';
import '../repositories/ofx_account/ofx_account_repository.dart';

sealed class OfxAccountManager {
  static Future<bool> addNewOfxAccount({
    required OfxAccountModel ofxAccount,
    required Ofx ofx,
  }) async {
    try {
      final repository = OfxAccountRepository();

      final ofxCheck = await repository.queryBankIdStartDate(
        ofxAccount.bankId,
        ofxAccount.startDate,
      );

      if (ofxCheck != null) {
        throw Exception('can not save! This ofxAccount exists');
      }

      // Write ofxAccount
      final result = await repository.insert(ofxAccount);
      if (result < 1) {
        throw Exception('repository.insert return $result');
      }

      // Insert transactions.
      // FIXME: Remember to add the transOfxId in the transactions

      return true;
    } catch (err) {
      log('OfxAccountManager.addNewOfxAccount: $err');
      return false;
    }
  }
}
