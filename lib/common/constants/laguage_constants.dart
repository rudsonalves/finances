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

const Map<String, LanguageConstants> languageAttributes = {
  'pt': LanguageConstants(
    language: 'Português Portugal',
    flag: '🇵🇹',
    localeCode: 'pt',
    decimalSeparator: ',',
    thousandSeparator: '\u00A0',
    leftSymbol: '',
    rightSymbol: ' €',
  ),
  'pt_BR': LanguageConstants(
    language: 'Português Brasil',
    flag: '🇧🇷',
    localeCode: 'pt_BR',
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
    rightSymbol: '',
  ),
  'es': LanguageConstants(
    language: 'Español',
    flag: '🇪🇸',
    localeCode: 'es',
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: '',
    rightSymbol: ' €',
  ),
  'en': LanguageConstants(
    language: 'English',
    flag: '🇬🇧',
    localeCode: 'en',
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: '£ ',
    rightSymbol: '',
  ),
  'en_US': LanguageConstants(
    language: 'US English',
    flag: '🇺🇸',
    localeCode: 'en_US',
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: '\$ ',
    rightSymbol: '',
  ),
  'it': LanguageConstants(
    language: 'Italiano',
    flag: '🇮🇹',
    localeCode: 'it',
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: '',
    rightSymbol: ' €',
  ),
  'de': LanguageConstants(
    language: 'Deutsch',
    flag: '🇩🇪',
    localeCode: 'de',
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: '',
    rightSymbol: ' €',
  ),
  'fr': LanguageConstants(
    language: 'Français',
    flag: '🇫🇷',
    localeCode: 'fr_FR',
    decimalSeparator: ',',
    thousandSeparator: '\u202F',
    leftSymbol: '',
    rightSymbol: ' €',
  ),
};

class LanguageConstants {
  final String decimalSeparator;
  final String thousandSeparator;
  final String leftSymbol;
  final String rightSymbol;
  final String language;
  final String flag;
  final String localeCode;

  const LanguageConstants({
    required this.decimalSeparator,
    required this.thousandSeparator,
    required this.leftSymbol,
    required this.rightSymbol,
    required this.language,
    required this.flag,
    required this.localeCode,
  });
}
