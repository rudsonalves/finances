import '../../locator.dart';
import '../constants/laguage_constants.dart';
import '../current_models/current_user.dart';

class MoneyMaskedText {
  String decimalSeparator;
  String thousandSeparator;
  String leftSymbol;
  String rightSymbol;
  int precision;
  bool preffixSignal;
  bool nosignal;

  MoneyMaskedText({
    this.decimalSeparator = '.',
    this.thousandSeparator = ',',
    this.leftSymbol = '\$ ',
    this.rightSymbol = '',
    this.precision = 2,
    this.preffixSignal = true,
    this.nosignal = true,
  });

  void setLanguage() {
    final language = locator<CurrentUser>().userLanguage;

    final LanguageConstants currence =
        (languageAttributes.containsKey(language))
            ? languageAttributes[language]!
            : languageAttributes['en_US']!;

    decimalSeparator = currence.decimalSeparator;
    thousandSeparator = currence.thousandSeparator;
    leftSymbol = currence.leftSymbol;
    rightSymbol = currence.rightSymbol;
  }

  static MoneyMaskedText getMoneyMaskedText() {
    final language = locator<CurrentUser>().userLanguage;

    final LanguageConstants currence =
        (languageAttributes.containsKey(language))
            ? languageAttributes[language]!
            : languageAttributes['en_US']!;

    return MoneyMaskedText(
      decimalSeparator: currence.decimalSeparator,
      thousandSeparator: currence.thousandSeparator,
      leftSymbol: currence.leftSymbol,
      rightSymbol: currence.rightSymbol,
    );
  }

  String _getOnlyNumbers(String text) => text.replaceAll(RegExp(r'[^\d]'), '');

  String text(double value) {
    bool negative = value.isNegative;

    String text = value.toStringAsFixed(2);

    List<String> onlyNumbers = _getOnlyNumbers(text).split('');

    int index = onlyNumbers.length - 2;

    onlyNumbers.insert(index, decimalSeparator);

    while (index > 3) {
      index -= 3;
      onlyNumbers.insert(index, thousandSeparator);
    }

    String preffix = '';
    if (!nosignal) {
      if (negative) {
        if (preffixSignal) {
          preffix = '-';
        } else {
          onlyNumbers.insert(0, '-');
        }
      }
    }
    return '$preffix$leftSymbol${onlyNumbers.join()}$rightSymbol';
  }
}
