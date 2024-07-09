// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

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
