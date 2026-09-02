import 'package:finances/common/extensions/app_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget appWithWidth({
    required double width,
    required AppScale scale,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
        ),
        child: Builder(
          builder: (BuildContext context) {
            scale.init(context);
            return const SizedBox();
          },
        ),
      ),
    );
  }

  group('AppScale', () {
    testWidgets('usa escala reduzida abaixo de 360 pixels', (
      WidgetTester tester,
    ) async {
      final AppScale scale = AppScale();

      await tester.pumpWidget(
        appWithWidth(width: 359, scale: scale),
      );

      expect(scale.screenWidth, 359);
      expect(scale.textScaleFactor, 0.7);
      expect(scale.iconSize, 16);
    });

    testWidgets('usa escala normal a partir de 360 pixels', (
      WidgetTester tester,
    ) async {
      final AppScale scale = AppScale();

      await tester.pumpWidget(
        appWithWidth(width: 360, scale: scale),
      );

      expect(scale.screenWidth, 360);
      expect(scale.textScaleFactor, 1);
      expect(scale.iconSize, 24);
    });

    testWidgets('atualiza a escala quando a largura da tela muda', (
      WidgetTester tester,
    ) async {
      final AppScale scale = AppScale();

      await tester.pumpWidget(
        appWithWidth(width: 359, scale: scale),
      );

      expect(scale.textScaleFactor, 0.7);
      expect(scale.iconSize, 16);

      await tester.pumpWidget(
        appWithWidth(width: 400, scale: scale),
      );

      expect(scale.screenWidth, 400);
      expect(scale.textScaleFactor, 1);
      expect(scale.iconSize, 24);
    });
  });
}
