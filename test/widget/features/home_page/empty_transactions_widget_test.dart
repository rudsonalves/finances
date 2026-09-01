import 'package:finances/features/home_page/widgets/empty_transactions.dart';
import 'package:finances/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyTransactions', () {
    testWidgets(
      'apresenta imagem e mensagem amigável quando não há transações',
      (tester) async {
        const messageColor = Colors.indigo;

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('pt', 'BR'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: EmptyTransactions(
                color: messageColor,
              ),
            ),
          ),
        );

        await tester.pump();

        final context = tester.element(
          find.byType(EmptyTransactions),
        );
        final locale = AppLocalizations.of(context)!;

        expect(
          find.text(locale.homePageNoTransactions),
          findsOneWidget,
        );
        expect(find.byType(Image), findsOneWidget);

        final image = tester.widget<Image>(find.byType(Image));
        final imageProvider = image.image;

        expect(imageProvider, isA<AssetImage>());
        expect(
          (imageProvider as AssetImage).assetName,
          'assets/images/no_trasactions.png',
        );
        expect(image.width, 100);
        expect(image.height, 100);
        expect(image.fit, BoxFit.fitHeight);

        final message = tester.widget<Text>(
          find.text(locale.homePageNoTransactions),
        );

        expect(message.style?.color, messageColor);
      },
    );
  });
}
