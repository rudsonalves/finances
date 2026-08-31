import 'package:finances/locator.dart';
import 'package:finances/manager/balance_manager.dart';
import 'package:finances/repositories/balance/abstract_balance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  tearDown(tearDownTestLocator);

  test('registers the default test dependencies', () async {
    final dependencies = await setupTestLocator();

    expect(
      locator<AbstractBalanceRepository>(),
      same(dependencies.balanceRepository),
    );
    expect(BalanceManager.repository, same(dependencies.balanceRepository));
  });

  test('replaces dependencies without retaining static manager state',
      () async {
    final firstRepository = MockAbstractBalanceRepository();
    await setupTestLocator(
      dependencies: TestDependencies(balanceRepository: firstRepository),
    );
    expect(BalanceManager.repository, same(firstRepository));

    final secondRepository = MockAbstractBalanceRepository();
    await setupTestLocator(
      dependencies: TestDependencies(balanceRepository: secondRepository),
    );

    expect(BalanceManager.repository, same(secondRepository));
    expect(BalanceManager.repository, isNot(same(firstRepository)));
  });

  test('tearDown removes all registrations', () async {
    await setupTestLocator();

    await tearDownTestLocator();

    expect(locator.isRegistered<AbstractBalanceRepository>(), isFalse);
  });
}
