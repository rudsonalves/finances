import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountValidator {
  final AppLocalizations locale;

  AccountValidator(this.locale);

  String? nameValidator(String? value) {
    final String name = value ?? '';

    if (name.isEmpty) return locale.statefullAccountDialogNameEmpty;
    if (name.length < 2) return locale.statefullAccountDialogNameGt3;

    return null;
  }

  String? descriptionValidator(String? value) {
    final String description = value ?? '';

    if (description.isEmpty) return locale.statefullAccountDialogDescripEmpty;
    if (description.length < 3) return locale.statefullAccountDialogDescripGt3;

    return null;
  }
}
