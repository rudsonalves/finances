import 'package:finances/common/validate/sign_validator.dart';
import 'package:finances/l10n/app_localizations_pt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizationsPtBr locale;
  late SignValidator validator;

  setUp(() {
    locale = AppLocalizationsPtBr();
    validator = SignValidator(locale);
  });

  group('SignValidator.emailValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.emailValidator(null),
        locale.signValidatorEmailEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.emailValidator(''),
        locale.signValidatorEmailEmpty,
      );
    });

    test('aceita endereço de e-mail válido', () {
      expect(
        validator.emailValidator('usuario@example.com'),
        isNull,
      );
    });

    test('rejeita endereço sem arroba', () {
      expect(
        validator.emailValidator('usuario.example.com'),
        locale.signValidatorEmailValid,
      );
    });

    test('rejeita endereço sem domínio', () {
      expect(
        validator.emailValidator('usuario@'),
        locale.signValidatorEmailValid,
      );
    });

    test('rejeita endereço sem sufixo do domínio', () {
      expect(
        validator.emailValidator('usuario@example'),
        locale.signValidatorEmailValid,
      );
    });

    test('ignora espaços externos', () {
      expect(
        validator.emailValidator('  usuario@example.com  '),
        isNull,
      );
    });

    test('rejeita espaços internos', () {
      expect(
        validator.emailValidator('usuario @example.com'),
        locale.signValidatorEmailValid,
      );
    });
  });

  group('SignValidator.passwordValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.passwordValidator(null),
        locale.signValidatorPassordEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.passwordValidator(''),
        locale.signValidatorPassordEmpty,
      );
    });

    test('rejeita senha com menos de oito caracteres', () {
      expect(
        validator.passwordValidator('Abc1234'),
        locale.signValidatorPassordValid,
      );
    });

    test('rejeita senha sem número', () {
      expect(
        validator.passwordValidator('abcdef'),
        locale.signValidatorPassordValid,
      );
    });

    test('rejeita senha sem letra minúscula', () {
      expect(
        validator.passwordValidator('123456'),
        locale.signValidatorPassordValid,
      );
    });

    test('aceita senha composta por maiúsculas e números', () {
      expect(
        validator.passwordValidator('ABCDEF12'),
        isNull,
      );
    });

    test('rejeita senha sem letra maiúscula', () {
      expect(
        validator.passwordValidator('abcdef12'),
        locale.signValidatorPassordValid,
      );
    });

    test('aceita senha com oito caracteres, maiúscula e número', () {
      expect(
        validator.passwordValidator('Abcdef12'),
        isNull,
      );
    });

    test('rejeita espaços internos', () {
      expect(
        validator.passwordValidator('abc 12'),
        locale.signValidatorPassordValid,
      );
    });

    test('rejeita espaços externos', () {
      expect(
        validator.passwordValidator(' abc123 '),
        locale.signValidatorPassordValid,
      );
    });
  });

  group('SignValidator.pwdConfirmValidator', () {
    test('aceita confirmação igual à senha', () {
      expect(
        validator.pwdConfirmValidator('abc123', 'abc123'),
        isNull,
      );
    });

    test('rejeita confirmação diferente', () {
      expect(
        validator.pwdConfirmValidator('abc124', 'abc123'),
        locale.signValidatorPassordMatch,
      );
    });

    test('rejeita confirmação nula quando existe senha', () {
      expect(
        validator.pwdConfirmValidator(null, 'abc123'),
        locale.signValidatorPassordMatch,
      );
    });

    test('rejeita confirmação vazia quando existe senha', () {
      expect(
        validator.pwdConfirmValidator('', 'abc123'),
        locale.signValidatorPassordMatch,
      );
    });

    test('não ignora espaços na confirmação', () {
      expect(
        validator.pwdConfirmValidator(' abc123 ', 'abc123'),
        locale.signValidatorPassordMatch,
      );
    });
  });

  group('SignValidator.nameValidator', () {
    test('rejeita valor nulo', () {
      expect(
        validator.nameValidator(null),
        locale.signValidatorNameEmpty,
      );
    });

    test('rejeita string vazia', () {
      expect(
        validator.nameValidator(''),
        locale.signValidatorNameEmpty,
      );
    });

    test('rejeita texto contendo somente espaços', () {
      expect(
        validator.nameValidator('   '),
        locale.signValidatorNameEmpty,
      );
    });

    test('rejeita nome com menos de três caracteres', () {
      expect(
        validator.nameValidator('Al'),
        locale.signValidatorNameSize,
      );
    });

    test('aceita nome simples', () {
      expect(
        validator.nameValidator('Maria'),
        isNull,
      );
    });

    test('aceita nome composto e acentuado', () {
      expect(
        validator.nameValidator('João da Silva'),
        isNull,
      );
    });

    test('aceita hífen e apóstrofo', () {
      expect(
        validator.nameValidator("Maria D'Ávila-Souza"),
        isNull,
      );
    });

    test('ignora espaços externos', () {
      expect(
        validator.nameValidator('  Maria da Silva  '),
        isNull,
      );
    });

    test('rejeita nome contendo números', () {
      expect(
        validator.nameValidator('Maria123'),
        locale.signValidatorNameValid,
      );
    });

    test('rejeita nome contendo caracteres especiais', () {
      expect(
        validator.nameValidator('Maria@Silva'),
        locale.signValidatorNameValid,
      );
    });
  });
}
