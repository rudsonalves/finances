import 'package:finances/common/models/transaction_db_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures/model_fixtures.dart';

void main() {
  test('creates a transaction with deterministic defaults and overrides', () {
    final defaultTransaction = createFakeTransaction();
    final expense = createFakeTransaction(
      id: 2,
      description: 'Expense',
      value: -25.5,
      status: TransStatus.transactionNotChecked,
    );

    expect(defaultTransaction.transId, 1);
    expect(defaultTransaction.transDate.year, 2024);
    expect(defaultTransaction.transValue, 100.0);
    expect(expense.transId, 2);
    expect(expense.transDescription, 'Expense');
    expect(expense.transValue, -25.5);
    expect(expense.transStatus, TransStatus.transactionNotChecked);
  });

  test('creates a balance with deterministic financial values', () {
    final balance = createFakeBalance(
      transactionCount: 3,
      openingBalance: 10,
      closingBalance: 35,
    );

    expect(balance.balanceAccountId, 1);
    expect(balance.balanceTransCount, 3);
    expect(balance.balanceOpen, 10);
    expect(balance.balanceClose, 35);
  });

  test('creates an account with a persistent icon fixture', () {
    final account = createFakeAccount(name: 'Wallet');

    expect(account.accountName, 'Wallet');
    expect(account.accountUserId, 'test-user');
    expect(account.accountIcon.iconId, 1);
    expect(account.accountIcon.iconName, 'wallet');
  });

  test('creates a user without requiring a registered locator', () {
    final user = createFakeUser(name: 'Fixture User', language: 'de');

    expect(user.userId, 'test-user');
    expect(user.userName, 'Fixture User');
    expect(user.userLogged, isTrue);
    expect(user.userLanguage, 'de');
  });
}
