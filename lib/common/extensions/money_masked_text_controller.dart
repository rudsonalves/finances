import 'package:flutter/widgets.dart';

import '../../locator.dart';
import '../constants/laguage_constants.dart';
import '../current_models/current_user.dart';

MoneyMaskedTextController getMoneyMaskedTextController(double initialValue) {
  final language = locator<CurrentUser>().userLanguage;

  final LanguageConstants languageConstants;

  if (languageAttributes.containsKey(language)) {
    languageConstants = languageAttributes[language]!;
  } else {
    languageConstants = languageAttributes['en_US']!;
  }

  return MoneyMaskedTextController(
    initialValue: initialValue,
    decimalSeparator: languageConstants.decimalSeparator,
    thousandSeparator: languageConstants.thousandSeparator,
    leftSymbol: languageConstants.leftSymbol,
    rightSymbol: languageConstants.rightSymbol,
  );
}

class MoneyMaskedTextController extends TextEditingController {
  MoneyMaskedTextController({
    double? initialValue,
    this.decimalSeparator = '.',
    this.thousandSeparator = ',',
    this.leftSymbol = '\$ ',
    this.rightSymbol = '',
    this.precision = 2,
  }) {
    _validateConfig();
    _shouldApplyTheMask = true;

    addListener(() {
      if (_shouldApplyTheMask) {
        var parts = _getOnlyNumbers(text).split('').toList(growable: true);

        if (parts.isNotEmpty) {
          if (parts.length < precision + 1) {
            parts = [...List.filled(precision, '0'), ...parts];
          }

          if (precision > 0) {
            parts.insert(parts.length - precision, '.');
          }

          updateValue(double.parse(parts.join()));
        }
      }
    });

    updateValue(initialValue);
  }

  final String decimalSeparator;
  final String thousandSeparator;
  final String rightSymbol;
  final String leftSymbol;
  final int precision;

  double? _lastValue;
  late bool _shouldApplyTheMask;

  double get numberValue {
    final parts = _getOnlyNumbers(text).split('').toList(growable: true);

    if (parts.isEmpty) {
      return 0;
    }

    if (precision > 0) {
      parts.insert(parts.length - precision, '.');
    }

    return double.parse(parts.join());
  }

  static const int _maxNumLength = 12;

  void updateValue(double? value) {
    if (value == null) {
      return;
    }

    if (!value.isFinite) {
      throw ArgumentError.value(
        value,
        'value',
        'O valor deve ser um número finito.',
      );
    }

    final double normalizedValue = value.abs();
    final bool exceedsLimit =
        normalizedValue.toStringAsFixed(0).length > _maxNumLength;

    if (exceedsLimit) {
      if (_lastValue == null) {
        throw ArgumentError.value(
          value,
          'value',
          'O valor deve ter no máximo $_maxNumLength dígitos inteiros.',
        );
      }

      _updateText(_applyMask(_lastValue!));
      return;
    }

    _lastValue = normalizedValue;
    _updateText(_applyMask(normalizedValue));
  }

  void _updateText(String newText) {
    if (text != newText) {
      _shouldApplyTheMask = false;

      final newSelection = _getNewSelection(newText);

      value = TextEditingValue(
        selection: newSelection,
        text: newText,
      );

      _shouldApplyTheMask = true;
    }
  }

  TextSelection _getNewSelection(String newText) {
    if (selection.baseOffset != selection.extentOffset) {
      return selection;
    }

    if (selection.baseOffset == 0) {
      return TextSelection.fromPosition(
        TextPosition(offset: leftSymbol.length + 1),
      );
    }

    if (selection.baseOffset != text.length) {
      try {
        var numberOfLeadingZeros =
            text.length - int.parse(text).toString().length;
        if (numberOfLeadingZeros == 2 && text.length == 4) {
          numberOfLeadingZeros = 1;
        }

        final skippedString =
            text.substring(numberOfLeadingZeros, selection.baseOffset);

        var cursorPosition = leftSymbol.length + 1;
        if (skippedString != '') {
          for (var i = leftSymbol.length, j = 0; i < newText.length; i++) {
            if (newText[i] == skippedString[j]) {
              j++;
              cursorPosition = i + 1;
            }

            if (j == skippedString.length) {
              cursorPosition = i + 1;
              break;
            }
          }
        }

        return TextSelection.fromPosition(
          TextPosition(offset: cursorPosition),
        );
      } catch (_) {
        return TextSelection.fromPosition(
          TextPosition(offset: newText.length - rightSymbol.length),
        );
      }
    }

    return TextSelection.fromPosition(
      TextPosition(offset: newText.length - rightSymbol.length),
    );
  }

  void _validateConfig() {
    if (_getOnlyNumbers(rightSymbol).isNotEmpty) {
      throw ArgumentError('rightSymbol must not have numbers.');
    }
  }

  String _getOnlyNumbers(String text) => text.replaceAll(RegExp(r'[^\d]'), '');

  String _applyMask(double value) {
    final textRepresentation = value
        .toStringAsFixed(precision)
        .replaceAll('.', '')
        .split('')
        .reversed
        .toList(growable: true);

    if (precision > 0) {
      textRepresentation.insert(precision, decimalSeparator);
    }

    for (var i = precision + (precision > 0 ? 4 : 3);
        textRepresentation.length > i;
        i += 4) {
      if (textRepresentation.length > i) {
        textRepresentation.insert(i, thousandSeparator);
      }
    }

    var masked = textRepresentation.reversed.join('');

    if (rightSymbol.isNotEmpty) {
      masked += rightSymbol;
    }

    if (leftSymbol.isNotEmpty) {
      masked = leftSymbol + masked;
    }

    return masked;
  }
}
