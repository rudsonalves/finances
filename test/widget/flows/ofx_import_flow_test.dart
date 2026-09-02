import 'dart:io';

import 'package:finances/common/constants/themes/colors/custom_color.g.dart';
import 'package:finances/common/constants/themes/icons/fontello_icons.dart';
import 'package:finances/features/home_page/balance_card/balance_card_controller.dart';
import 'package:finances/features/home_page/home_page_controller.dart';
import 'package:finances/features/home_page_view/home_page_view.dart';
import 'package:finances/features/ofx_page/ofx_page_controller.dart';
import 'package:finances/features/statistics/statistic_controller.dart';
import 'package:finances/l10n/app_localizations.dart';
import 'package:finances/packages/ofx/lib/ofx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomePageController extends Mock implements HomePageController {}

class MockBalanceCardController extends Mock implements BalanceCardController {}

class MockStatisticsController extends Mock implements StatisticsController {}

class MockOfxPageController extends Mock implements OfxPageController {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockHomePageController homePageController;
  late MockBalanceCardController balanceCardController;
  late MockStatisticsController statisticsController;
  late MockOfxPageController ofxPageController;

  late ValueNotifier<int> importedTransactions;
  late Ofx ofx;

  const fixturePath =
      'test/helpers/fixtures/ofx/valid_bank_xml_single_transaction.ofx';

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    homePageController = MockHomePageController();
    balanceCardController = MockBalanceCardController();
    statisticsController = MockStatisticsController();
    ofxPageController = MockOfxPageController();

    importedTransactions = ValueNotifier<int>(0);

    final source = File(fixturePath).readAsStringSync();
    ofx = Ofx.fromString(source);

    when(() => homePageController.redraw).thenReturn(false);

    when(
      () => statisticsController.makeRecalculated(),
    ).thenAnswer((_) async {});

    when(
      () => ofxPageController.ofxFileRegister(),
    ).thenAnswer((_) {});

    when(
      () => ofxPageController.pickAndValidateOfxFile(any()),
    ).thenAnswer((_) async => fixturePath);

    when(
      () => ofxPageController.processOfxFile(
        any(),
        fixturePath,
      ),
    ).thenAnswer((_) async => ofx);

    when(
      () => ofxPageController.handleOfxImport(
        any(),
        ofx: ofx,
        ofxPath: fixturePath,
      ),
    ).thenAnswer((invocation) async {
      final context = invocation.positionalArguments.first as BuildContext;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar importação'),
          content: Text(
            '${ofx.transactions.length} transação disponível',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        importedTransactions.value = ofx.transactions.length;
      }
    });

    when(
      () => ofxPageController.ofxFileRegister(),
    ).thenAnswer((_) {});
  });

  tearDown(() {
    importedTransactions.dispose();
  });

  Widget importedTransactionsPage() {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: importedTransactions,
          builder: (context, value, _) {
            return Text('Transações importadas: $value');
          },
        ),
      ),
    );
  }

  Widget buildTestWidget() {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        extensions: [lightCustomColors],
      ),
      home: HomePageView(
        homePageController: homePageController,
        balanceCardController: balanceCardController,
        statisticsController: statisticsController,
        ofxPageController: ofxPageController,
        pages: [
          const Center(child: Text('Home')),
          const Center(child: Text('Contas')),
          const Center(child: Text('Categorias')),
          importedTransactionsPage(),
          const Center(child: Text('Estatísticas')),
        ],
      ),
    );
  }

  testWidgets(
    'seleciona um OFX, confirma a importação e atualiza o extrato',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Transações importadas: 0'), findsNothing);

      await tester.tap(
        find.byIcon(FontelloIcons.ofx_archive_off),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transações importadas: 0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar importação'), findsOneWidget);
      expect(find.text('1 transação disponível'), findsOneWidget);

      await tester.tap(find.text('Importar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar importação'), findsNothing);
      expect(find.text('Transações importadas: 1'), findsOneWidget);

      verify(
        () => ofxPageController.pickAndValidateOfxFile(any()),
      ).called(1);

      verify(
        () => ofxPageController.processOfxFile(
          any(),
          fixturePath,
        ),
      ).called(1);

      verify(
        () => ofxPageController.handleOfxImport(
          any(),
          ofx: ofx,
          ofxPath: fixturePath,
        ),
      ).called(1);

      verify(
        () => ofxPageController.ofxFileRegister(),
      ).called(1);
    },
  );
}
