import 'package:finances/common/extensions/money_masked_text_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyMaskedTextController', () {
    test('formata o valor inicial com configuração brasileira', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 1234.56,
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );
      addTearDown(controller.dispose);

      expect(controller.text, r'R$ 1.234,56');
      expect(controller.numberValue, 1234.56);
    });

    test('formata zero como valor monetário', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 0,
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );
      addTearDown(controller.dispose);

      expect(controller.text, r'R$ 0,00');
      expect(controller.numberValue, 0);
    });

    test('arredonda o valor inicial para centavos', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 12.345,
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );
      addTearDown(controller.dispose);

      expect(controller.text, r'R$ 12,35');
      expect(controller.numberValue, 12.35);
    });

    test('converte os dígitos editados em centavos', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 0,
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );
      addTearDown(controller.dispose);

      controller.text = '1234';

      expect(controller.text, r'R$ 12,34');
      expect(controller.numberValue, 12.34);
    });

    test('retorna zero quando o texto não possui dígitos', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 0,
      );
      addTearDown(controller.dispose);

      controller.clear();

      expect(controller.numberValue, 0);
    });

    test('respeita precisão igual a zero', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 1234.56,
        precision: 0,
      );
      addTearDown(controller.dispose);

      expect(controller.text, r'$ 1,235');
      expect(controller.numberValue, 1235);
    });

    test('respeita precisão igual a três', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 1234.567,
        precision: 3,
      );
      addTearDown(controller.dispose);

      expect(controller.text, r'$ 1,234.567');
      expect(controller.numberValue, 1234.567);
    });

    test('rejeita símbolo à direita contendo números', () {
      expect(
        () => MoneyMaskedTextController(rightSymbol: ' moeda 1'),
        throwsArgumentError,
      );
    });

    test('normaliza valor inicial negativo como magnitude positiva', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: -12.34,
      );
      addTearDown(controller.dispose);

      expect(controller.text, r'$ 12.34');
      expect(controller.numberValue, 12.34);
    });

    test('aceita valor com doze dígitos na parte inteira', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 999999999999,
      );
      addTearDown(controller.dispose);

      expect(controller.text, r'$ 999,999,999,999.00');
      expect(controller.numberValue, 999999999999);
    });

    test('mantém o último valor quando uma atualização excede o limite', () {
      final MoneyMaskedTextController controller = MoneyMaskedTextController(
        initialValue: 123.45,
      );
      addTearDown(controller.dispose);

      controller.updateValue(1000000000000);

      expect(controller.text, r'$ 123.45');
      expect(controller.numberValue, 123.45);
    });

    test('rejeita valor inicial que excede o limite', () {
      expect(
        () => MoneyMaskedTextController(
          initialValue: 1000000000000,
        ),
        throwsArgumentError,
      );
    });
  });
}
