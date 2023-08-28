import 'package:flutter/material.dart';

const Map<String, Map<String, String>> supportedLanguages = {
  'en': {
    'name': 'English',
    'flag': '🇬🇧',
    'localeCode': 'en',
  },
  'en_US': {
    'name': 'US English',
    'flag': '🇺🇸',
    'localeCode': 'en_US',
  },
  'pt': {
    'name': 'Português',
    'flag': '🇵🇹',
    'localeCode': 'pt',
  },
  'pt_BR': {
    'name': 'Português Brasil',
    'flag': '🇧🇷',
    'localeCode': 'pt_BR',
  },
  'es': {
    'name': 'Español',
    'flag': '🇪🇸',
    'localeCode': 'es',
  },
};

class LanguageModel {
  String name;
  String flag;
  String localeCode;

  LanguageModel({
    this.name = 'English',
    this.flag = '🇬🇧',
    this.localeCode = 'en',
  });

  void setFromLocaleCode(String localeCode) {
    if (supportedLanguages.containsKey(localeCode)) {
      name = supportedLanguages[localeCode]!['name']!;
      flag = supportedLanguages[localeCode]!['flag']!;
      this.localeCode = localeCode;
    } else {
      name = supportedLanguages['en']!['name']!;
      flag = supportedLanguages['en']!['flag']!;
      this.localeCode = 'en';
    }
  }

  Locale getLocale() {
    List<String> codes = localeCode.split('_');
    if (codes.length > 1) return Locale(codes[0], codes[1]);
    return Locale(codes[0], '');
  }

  @override
  String toString() {
    return 'LanguageModel: $name ($flag); $localeCode';
  }
}
