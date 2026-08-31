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

  String text(double value) {
    final bool negative = value.isNegative;
    final String fixedValue = value.abs().toStringAsFixed(precision);
    final List<String> parts = fixedValue.split('.');

    String integerPart = parts.first;
    final List<String> integerGroups = [];

    while (integerPart.length > 3) {
      integerGroups.insert(
        0,
        integerPart.substring(integerPart.length - 3),
      );
      integerPart = integerPart.substring(0, integerPart.length - 3);
    }

    integerGroups.insert(0, integerPart);

    final String formattedInteger = integerGroups.join(thousandSeparator);
    final String formattedDecimal =
        precision > 0 ? '$decimalSeparator${parts.last}' : '';
    final String formattedValue = '$formattedInteger$formattedDecimal';

    if (!nosignal && negative) {
      if (preffixSignal) {
        return '-$leftSymbol$formattedValue$rightSymbol';
      }

      return '$leftSymbol-$formattedValue$rightSymbol';
    }

    return '$leftSymbol$formattedValue$rightSymbol';
  }
}
