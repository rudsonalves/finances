import 'package:finances/common/constants/laguage_constants.dart';
import 'package:finances/common/extensions/money_masked_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyMaskedText.text', () {
    test('formata dólar com separadores dos Estados Unidos', () {
      final MoneyMaskedText money = MoneyMaskedText();

      expect(
        money.text(1234.56),
        r'$ 1,234.56',
      );
    });

    test('formata real com separadores brasileiros', () {
      final MoneyMaskedText money = MoneyMaskedText(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );

      expect(
        money.text(1234.56),
        r'R$ 1.234,56',
      );
    });

    test('formata zero com duas casas decimais', () {
      final MoneyMaskedText money = MoneyMaskedText(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );

      expect(
        money.text(0),
        r'R$ 0,00',
      );
    });

    test('arredonda o valor para centavos', () {
      final MoneyMaskedText money = MoneyMaskedText(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );

      expect(
        money.text(12.345),
        r'R$ 12,35',
      );
    });

    test('oculta o sinal negativo quando nosignal é verdadeiro', () {
      final MoneyMaskedText money = MoneyMaskedText(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
      );

      expect(
        money.text(-12.34),
        r'R$ 12,34',
      );
    });

    test('coloca o sinal antes do símbolo monetário', () {
      final MoneyMaskedText money = MoneyMaskedText(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
        nosignal: false,
        preffixSignal: true,
      );

      expect(
        money.text(-12.34),
        r'-R$ 12,34',
      );
    });

    test('coloca o sinal depois do símbolo monetário', () {
      final MoneyMaskedText money = MoneyMaskedText(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: r'R$ ',
        nosignal: false,
        preffixSignal: false,
      );

      expect(
        money.text(-12.34),
        r'R$ -12,34',
      );
    });

    test('respeita precisão igual a zero', () {
      final MoneyMaskedText money = MoneyMaskedText(
        precision: 0,
      );

      expect(
        money.text(1234.56),
        r'$ 1,235',
      );
    });

    test('respeita precisão igual a três', () {
      final MoneyMaskedText money = MoneyMaskedText(
        precision: 3,
      );

      expect(
        money.text(1234.567),
        r'$ 1,234.567',
      );
    });
  });

  group('MoneyMaskedText localidades suportadas', () {
    final Map<String, String> expectedValues = {
      'pt': '1\u00A0234,56 €',
      'pt_BR': r'R$ 1.234,56',
      'es': '1.234,56 €',
      'en': '£ 1,234.56',
      'en_US': r'$ 1,234.56',
      'it': '1.234,56 €',
      'de': '1.234,56 €',
      'fr': '1\u202F234,56 €',
    };

    for (final MapEntry<String, String> entry in expectedValues.entries) {
      test('formata corretamente a localidade ${entry.key}', () {
        final LanguageConstants language = languageAttributes[entry.key]!;
        final MoneyMaskedText money = MoneyMaskedText(
          decimalSeparator: language.decimalSeparator,
          thousandSeparator: language.thousandSeparator,
          leftSymbol: language.leftSymbol,
          rightSymbol: language.rightSymbol,
        );

        expect(
          money.text(1234.56),
          entry.value,
        );
      });
    }
  });
}
