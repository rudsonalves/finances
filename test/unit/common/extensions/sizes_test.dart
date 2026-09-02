import 'package:finances/common/extensions/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> initializeSizes(
    WidgetTester tester, {
    required Size deviceSize,
    Size? designSize,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: deviceSize),
          child: Builder(
            builder: (BuildContext context) {
              if (designSize == null) {
                Sizes.init(context);
              } else {
                Sizes.init(
                  context,
                  designSize: designSize,
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  group('Sizes', () {
    testWidgets('armazena as dimensões atuais do dispositivo', (
      WidgetTester tester,
    ) async {
      await initializeSizes(
        tester,
        deviceSize: const Size(207, 448),
      );

      expect(Sizes().width, 207);
      expect(Sizes().height, 448);
    });

    testWidgets('escala largura e altura a partir do tamanho padrão', (
      WidgetTester tester,
    ) async {
      await initializeSizes(
        tester,
        deviceSize: const Size(207, 448),
      );

      expect(414.w, 207);
      expect(896.h, 448);
      expect(100.w, 50);
      expect(100.h, 50);
    });

    testWidgets('atualiza os cálculos quando o dispositivo muda de tamanho', (
      WidgetTester tester,
    ) async {
      await initializeSizes(
        tester,
        deviceSize: const Size(207, 448),
      );

      expect(414.w, 207);
      expect(896.h, 448);

      await initializeSizes(
        tester,
        deviceSize: const Size(414, 896),
      );

      expect(414.w, 414);
      expect(896.h, 896);
    });

    testWidgets('respeita um tamanho de design personalizado', (
      WidgetTester tester,
    ) async {
      await initializeSizes(
        tester,
        deviceSize: const Size(100, 200),
        designSize: const Size(200, 400),
      );

      expect(200.w, 100);
      expect(400.h, 200);
    });
  });
}
