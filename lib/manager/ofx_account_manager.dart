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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import '../common/models/ofx_account_model.dart';
import '../locator.dart';
import '../repositories/ofx_account/ofx_account_repository.dart';
import '../repositories/transaction/abstract_transaction_repository.dart';
import 'transaction_manager.dart';
import 'transfer_manager.dart';

sealed class OfxAccountManager {
  static final ofxAccountRepository = OfxAccountRepository();

  OfxAccountManager._();

  static Future<bool> add(OfxAccountModel ofxAccount) async {
    try {
      // Check if this ofx is registred
      final ofxCheck = await ofxAccountRepository.queryBankAccountIdStartDate(
        ofxAccount.bankAccountId,
        ofxAccount.startDate,
      );

      if (ofxCheck != null) {
        ofxAccount.copy(ofxCheck);
        return false;
      }

      // Write ofxAccount
      final result = await ofxAccountRepository.insert(ofxAccount);
      if (result < 1) {
        throw Exception('repository.insert return $result');
      }

      return true;
    } catch (err) {
      log('OfxAccountManager.insert: $err');
      return false;
    }
  }

  static Future<void> getAll(
    List<OfxAccountModel> ofxAccounts, [
    int? limit,
  ]) async {
    try {
      ofxAccounts.clear();
      for (final ofxAccount in await ofxAccountRepository.queryAll(limit)) {
        ofxAccounts.add(ofxAccount);
      }
    } catch (err) {
      log('OfxAccountManager.getAll: $err');
    }
  }

  static Future<void> delete(OfxAccountModel ofxAccount) async {
    try {
      // Remove all transactions from
      final transRepository = locator<AbstractTransactionRepository>();
      final transactions = await transRepository.queryFromOfxId(
        ofxAccount.id!,
      );
      for (final transaction in transactions) {
        if (transaction.transTransferId == null) {
          await TransactionManager.remove(transaction);
        } else {
          final result = await transRepository.getId(transaction.transId!);
          if (result != null) {
            await TransferManager.remove(transaction);
          }
        }
      }

      // Remove ofxAccount
      final result = await ofxAccountRepository.deleteId(ofxAccount.id!);
      if (result != 1) {
        throw Exception('accountRepository.deleteId return $result');
      }
    } catch (err) {
      log('OfxAccountManager.delete: $err');
    }
  }
}
