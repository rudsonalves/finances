const Map<String, LanguageConstants> languageAttributes = {
  'pt': LanguageConstants(
    language: 'Português Portugal',
    flag: '🇵🇹',
    localeCode: 'pt',
    decimalSeparator: '.',
    thousandSeparator: ',',
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
    decimalSeparator: '.',
    thousandSeparator: ',',
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
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: '',
    rightSymbol: ' €',
  ),
  'de': LanguageConstants(
    language: 'Deutsch',
    flag: '🇩🇪',
    localeCode: 'de',
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: '',
    rightSymbol: ' €',
  ),
  'fr': LanguageConstants(
    language: 'Français',
    flag: '🇫🇷',
    localeCode: 'fr_FR',
    decimalSeparator: '.',
    thousandSeparator: ',',
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
