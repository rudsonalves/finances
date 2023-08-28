import '../../locator.dart';
import '../current_models/current_user.dart';

MoneyMaskedText getMoneyMaskedText() {
  switch (locator.get<CurrentUser>().userLanguage) {
    case 'pt':
      return MoneyMaskedText(
        decimalSeparator: '.',
        thousandSeparator: ',',
        leftSymbol: '',
        rightSymbol: ' €',
      );
    case 'pt_BR':
      return MoneyMaskedText(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: 'R\$ ',
        rightSymbol: '',
      );
    case 'es':
      return MoneyMaskedText(
        decimalSeparator: '.',
        thousandSeparator: ',',
        leftSymbol: '',
        rightSymbol: ' €',
      );
    case 'en':
      return MoneyMaskedText(
        decimalSeparator: '.',
        thousandSeparator: ',',
        leftSymbol: '£ ',
        rightSymbol: '',
      );
    case 'en_US':
      return MoneyMaskedText();
    default:
      return MoneyMaskedText();
  }
}

class MoneyMaskedText {
  final String decimalSeparator;
  final String thousandSeparator;
  final String leftSymbol;
  final String rightSymbol;
  final int precision;
  final bool preffixSignal;
  final bool nosignal;

  MoneyMaskedText({
    this.decimalSeparator = '.',
    this.thousandSeparator = ',',
    this.leftSymbol = '\$ ',
    this.rightSymbol = '',
    this.precision = 2,
    this.preffixSignal = true,
    this.nosignal = true,
  });

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
