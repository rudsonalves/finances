import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransactionValidator {
  final AppLocalizations locale;

  TransactionValidator(this.locale);

  static String _getOnlyNumbers(String text) =>
      text.replaceAll(RegExp(r'[^\d]'), '');

  double _numberValue(String text) {
    int precision = 2;
    List<String> listNumbers = _getOnlyNumbers(text).split('');
    listNumbers.insert(listNumbers.length - precision, '.');
    double value = double.tryParse(listNumbers.join()) ?? 0.0;
    return value;
  }

  String? amountValidator(String? value) {
    value = value ?? '';

    if (value.isEmpty || value == '0.00' || value == '0,00') {
      return locale.transValidatorAmountEmpty;
    }

    double amount = _numberValue(value);
    if (amount == 0) return locale.transValidatorAmountGt0;

    return null;
  }

  String? descriptionValidator(String? value) {
    final String description = value ?? '';

    if (description.isEmpty) return locale.transValidatorDescriptionEmpty;
    if (description.length < 3) return locale.transValidatorDescriptionGt3;

    return null;
  }

  String? categoryValidator(String? value) {
    final String category = value ?? '';

    if (category.isEmpty) return locale.transValidatorCategory;

    return null;
  }

  String? dateValidator(String? value) {
    final RegExp dateRE =
        RegExp(r'^[A-Z][a-z]{2}, [A-Z][a-z]{2} [\d]{1,2}, 20[\d]{2}$');
    final String date = value ?? '';

    if (date.isEmpty) return locale.transValidatorDateEmpty;
    if (!dateRE.hasMatch(date)) return locale.transValidatorDateValid;

    return null;
  }

  String? accountForTransferValidator(int? value) {
    if (value == null) {
      return 'Select an account for the transfer';
    }
    return null;
  }
}
