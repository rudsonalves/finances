import 'package:finances/common/validate/transaction_validator.dart';
import 'package:finances/l10n/app_localizations_pt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizationsPtBr locale;
  late TransactionValidator validator;

  setUp(() {
    locale = AppLocalizationsPtBr();
    validator = TransactionValidator(locale);
  });

  group('TransactionValidator.amountValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.amountValidator(null),
        locale.transValidatorAmountEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.amountValidator(''),
        locale.transValidatorAmountEmpty,
      );
    });

    test('rejeita texto contendo somente espaços', () {
      expect(
        validator.amountValidator('   '),
        locale.transValidatorAmountEmpty,
      );
    });

    test('rejeita zero com ponto decimal', () {
      expect(
        validator.amountValidator('0.00'),
        locale.transValidatorAmountGt0,
      );
    });

    test('rejeita zero com vírgula decimal', () {
      expect(
        validator.amountValidator('0,00'),
        locale.transValidatorAmountGt0,
      );
    });

    test('rejeita zero monetário formatado', () {
      expect(
        validator.amountValidator(r'R$ 0,00'),
        locale.transValidatorAmountGt0,
      );
    });

    test('aceita valor com vírgula decimal', () {
      expect(
        validator.amountValidator('12,34'),
        isNull,
      );
    });

    test('aceita valor monetário formatado', () {
      expect(
        validator.amountValidator(r'R$ 1.234,56'),
        isNull,
      );
    });

    test('rejeita valor negativo', () {
      expect(
        validator.amountValidator('-12,34'),
        locale.transValidatorAmountGt0,
      );
    });

    test('rejeita texto sem valor numérico', () {
      expect(
        validator.amountValidator('valor inválido'),
        locale.transValidatorAmountGt0,
      );
    });
  });

  group('TransactionValidator.descriptionValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.descriptionValidator(null),
        locale.transValidatorDescriptionEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.descriptionValidator(''),
        locale.transValidatorDescriptionEmpty,
      );
    });

    test('rejeita texto contendo somente espaços', () {
      expect(
        validator.descriptionValidator('   '),
        locale.transValidatorDescriptionEmpty,
      );
    });

    test('rejeita descrição com menos de três caracteres', () {
      expect(
        validator.descriptionValidator('Ab'),
        locale.transValidatorDescriptionGt3,
      );
    });

    test('desconsidera espaços externos ao verificar o tamanho', () {
      expect(
        validator.descriptionValidator(' Ab '),
        locale.transValidatorDescriptionGt3,
      );
    });

    test('aceita descrição com exatamente três caracteres', () {
      expect(
        validator.descriptionValidator('ABC'),
        isNull,
      );
    });

    test('aceita descrição válida com espaços externos', () {
      expect(
        validator.descriptionValidator('  Compra no mercado  '),
        isNull,
      );
    });
  });

  group('TransactionValidator.categoryValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.categoryValidator(null),
        locale.transValidatorCategory,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.categoryValidator(''),
        locale.transValidatorCategory,
      );
    });

    test('rejeita texto contendo somente espaços', () {
      expect(
        validator.categoryValidator('   '),
        locale.transValidatorCategory,
      );
    });

    test('aceita categoria selecionada', () {
      expect(
        validator.categoryValidator('Alimentação'),
        isNull,
      );
    });

    test('aceita categoria com espaços externos', () {
      expect(
        validator.categoryValidator('  Alimentação  '),
        isNull,
      );
    });
  });

  group('TransactionValidator.dateValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.dateValidator(null),
        locale.transValidatorDateEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.dateValidator(''),
        locale.transValidatorDateEmpty,
      );
    });

    test('rejeita texto contendo somente espaços', () {
      expect(
        validator.dateValidator('   '),
        locale.transValidatorDateEmpty,
      );
    });

    test('aceita data e hora no formato produzido pelo formulário', () {
      expect(
        validator.dateValidator('2026-09-01T10:30:00.000000'),
        isNull,
      );
    });

    test('rejeita texto que não representa uma data', () {
      expect(
        validator.dateValidator('data inválida'),
        locale.transValidatorDateValid,
      );
    });

    test('rejeita mês inexistente', () {
      expect(
        validator.dateValidator('2026-13-01T10:30:00.000000'),
        locale.transValidatorDateValid,
      );
    });

    test('rejeita dia inexistente no mês', () {
      expect(
        validator.dateValidator('2026-02-30T10:30:00.000000'),
        locale.transValidatorDateValid,
      );
    });
  });

  group('TransactionValidator.accountForTransferValidator', () {
    test('rejeita conta não selecionada', () {
      expect(
        validator.accountForTransferValidator(null),
        locale.transPageSelectAccTransfer,
      );
    });

    test('rejeita identificador igual a zero', () {
      expect(
        validator.accountForTransferValidator(0),
        locale.transPageSelectAccTransfer,
      );
    });

    test('rejeita identificador negativo', () {
      expect(
        validator.accountForTransferValidator(-1),
        locale.transPageSelectAccTransfer,
      );
    });

    test('aceita identificador positivo', () {
      expect(
        validator.accountForTransferValidator(1),
        isNull,
      );
    });
  });
}
