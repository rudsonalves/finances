import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignValidator {
  final AppLocalizations locale;

  SignValidator(this.locale);

  String? nameValidator(String? value) {
    final RegExp nameRE = RegExp(r"^([A-À-ÿ][a-z\-. ']+[ ])*");
    final String name = value ?? '';

    if (name.isEmpty) {
      return locale.signValidatorNameEmpty;
    } else if (name.length < 3) {
      return locale.signValidatorNameSize;
    } else if (!nameRE.hasMatch(name)) {
      return locale.signValidatorNameValid;
    }

    return null;
  }

  String? emailValidator(String? value) {
    final RegExp emailRE = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    final String email = value ?? '';

    if (email.isEmpty) {
      return locale.signValidatorEmailEmpty;
    } else if (!emailRE.hasMatch(email)) {
      return locale.signValidatorEmailValid;
    }

    return null;
  }

  String? passwordValidator(String? value) {
    final RegExp pwdRE = RegExp(r'^(?=.*\d)(?=.*[a-z]).{6,}');
    final String pwd = value ?? '';

    if (pwd.isEmpty) {
      return locale.signValidatorPassordEmpty;
    } else if (!pwdRE.hasMatch(pwd)) {
      return locale.signValidatorPassordValid;
    }

    return null;
  }

  String? pwdConfirmValidator(String? value, String pwd) {
    final String pwdConfirm = value ?? '';

    if (pwd != pwdConfirm) {
      return locale.signValidatorPassordMatch;
    }

    return null;
  }
}
