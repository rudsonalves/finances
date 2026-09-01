import 'package:finances/common/constants/themes/app_icons.dart';
import 'package:finances/common/constants/themes/colors/custom_color.g.dart';
import 'package:finances/common/current_models/current_account.dart';
import 'package:finances/common/current_models/current_balance.dart';
import 'package:finances/common/extensions/money_masked_text.dart';
import 'package:finances/common/models/account_db_model.dart';
import 'package:finances/common/models/card_balance_model.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:finances/common/models/icons_model.dart';
import 'package:finances/features/home_page/balance_card/balance_card.dart';
import 'package:finances/features/home_page/balance_card/balance_card_controller.dart';
import 'package:finances/features/home_page/balance_card/balance_cart_state.dart';
import 'package:finances/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBalanceCardController extends Mock implements BalanceCardController {}

class MockCurrentBalance extends Mock implements CurrentBalance {}

class MockCurrentAccount extends Mock implements CurrentAccount {}

void main() {
  late MockBalanceCardController controller;
  late MockCurrentBalance currentBalance;
  late MockCurrentAccount currentAccount;

  late AccountDbModel account;
  late MoneyMaskedText money;

  late double balanceClose;

  setUp(() {
    controller = MockBalanceCardController();
    currentBalance = MockCurrentBalance();
    currentAccount = MockCurrentAccount();

    money = MoneyMaskedText(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: r'R$ ',
    );

    final accountIcon = IconModel(
      iconId: 1,
      iconName: 'account_balance_wallet',
      iconFontFamily: IconsFontFamily.MaterialIcons,
    );

    account = AccountDbModel(
      accountId: 1,
      accountName: 'Conta principal',
      accountUserId: 'user-1',
      accountIcon: accountIcon,
    );

    balanceClose = 125.50;

    when(() => currentBalance.balanceClose).thenAnswer((_) => balanceClose);

    when(() => currentAccount.accountId).thenReturn(account.accountId);
    when(() => currentAccount.accountName).thenReturn(account.accountName);
    when(() => currentAccount.accountUserId).thenReturn(account.accountUserId);
    when(() => currentAccount.accountIcon).thenReturn(account.accountIcon);

    when(() => controller.state).thenReturn(BalanceCardStateSuccess());
    when(() => controller.balanceDate).thenReturn(ExtendedDate(2026, 9, 1));
    when(() => controller.balance).thenReturn(
      CardBalanceModel(
        incomes: 300,
        expanses: -174.50,
      ),
    );
    when(() => controller.accountsList).thenReturn([account]);
    when(() => controller.accountsMap).thenReturn({1: account});
    when(() => controller.transStatusCheck).thenReturn(false);
    when(() => controller.futureTransactions).thenReturn(FutureTrans.week);
  });

  Widget buildTestWidget() {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        extensions: [lightCustomColors],
      ),
      home: Scaffold(
        body: Stack(
          children: [
            BalanceCard(
              textScale: 1,
              balanceCallBack: (_) {},
              controller: controller,
              money: money,
              currentBalance: currentBalance,
              currentAccount: currentAccount,
            ),
          ],
        ),
      ),
    );
  }

  group('BalanceCard', () {
    testWidgets(
      'usa cores diferentes para saldo positivo e negativo',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        final cardContext = tester.element(find.byType(BalanceCard));
        final theme = Theme.of(cardContext);
        final customColors = theme.extension<CustomColors>()!;
        final formattedBalance = money.text(balanceClose);

        Text balanceText = tester.widget<Text>(
          find.text(formattedBalance),
        );

        expect(balanceClose, isPositive);
        expect(balanceText.style?.color, theme.colorScheme.onPrimary);

        balanceClose = -125.50;

        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        balanceText = tester.widget<Text>(
          find.text(money.text(balanceClose)),
        );

        expect(balanceClose, isNegative);
        expect(
          balanceText.style?.color,
          customColors.sourceMinusred,
        );
      },
    );

    testWidgets(
      'oculta o saldo com uma máscara e permite exibi-lo novamente',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        final cardContext = tester.element(find.byType(BalanceCard));
        final locale = AppLocalizations.of(cardContext)!;
        final formattedBalance = money.text(balanceClose);
        final visibilityButton = find.byTooltip(
          locale.balanceCardBalance,
        );

        expect(find.text(formattedBalance), findsOneWidget);
        expect(find.text('••••••'), findsNothing);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);

        await tester.tap(visibilityButton);
        await tester.pump();

        expect(find.text(formattedBalance), findsNothing);
        expect(find.text('••••••'), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        await tester.tap(visibilityButton);
        await tester.pump();

        expect(find.text(formattedBalance), findsOneWidget);
        expect(find.text('••••••'), findsNothing);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);
      },
    );
  });
}
