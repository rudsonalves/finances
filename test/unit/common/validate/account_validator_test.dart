import 'package:finances/common/validate/account_validator.dart';
import 'package:finances/l10n/app_localizations_pt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizationsPtBr locale;
  late AccountValidator validator;

  setUp(() {
    locale = AppLocalizationsPtBr();
    validator = AccountValidator(locale);
  });

  group('AccountValidator.nameValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.nameValidator(null),
        locale.statefullAccountDialogNameEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.nameValidator(''),
        locale.statefullAccountDialogNameEmpty,
      );
    });

    test('rejeita texto contendo somente espaços', () {
      expect(
        validator.nameValidator('   '),
        locale.statefullAccountDialogNameEmpty,
      );
    });

    test('rejeita nome com menos de dois caracteres', () {
      expect(
        validator.nameValidator('A'),
        locale.statefullAccountDialogNameGt3,
      );
    });

    test('desconsidera espaços externos ao verificar o tamanho', () {
      expect(
        validator.nameValidator(' A '),
        locale.statefullAccountDialogNameGt3,
      );
    });

    test('aceita nome com exatamente dois caracteres', () {
      expect(
        validator.nameValidator('Nu'),
        isNull,
      );
    });

    test('aceita nome válido com espaços externos', () {
      expect(
        validator.nameValidator('  Conta corrente  '),
        isNull,
      );
    });
  });

  group('AccountValidator.descriptionValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.descriptionValidator(null),
        locale.statefullAccountDialogDescripEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.descriptionValidator(''),
        locale.statefullAccountDialogDescripEmpty,
      );
    });

    test('rejeita texto contendo somente espaços', () {
      expect(
        validator.descriptionValidator('   '),
        locale.statefullAccountDialogDescripEmpty,
      );
    });

    test('rejeita descrição com menos de três caracteres', () {
      expect(
        validator.descriptionValidator('AB'),
        locale.statefullAccountDialogDescripGt3,
      );
    });

    test('desconsidera espaços externos ao verificar o tamanho', () {
      expect(
        validator.descriptionValidator(' AB '),
        locale.statefullAccountDialogDescripGt3,
      );
    });

    test('aceita descrição com exatamente três caracteres', () {
      expect(
        validator.descriptionValidator('PIX'),
        isNull,
      );
    });

    test('aceita descrição válida com espaços externos', () {
      expect(
        validator.descriptionValidator('  Conta de uso diário  '),
        isNull,
      );
    });
  });
}
