import 'package:flutter/material.dart';

import '../constants/laguage_constants.dart';

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
    if (languageAttributes.containsKey(localeCode)) {
      name = languageAttributes[localeCode]!.language;
      flag = languageAttributes[localeCode]!.flag;
      this.localeCode = localeCode;
    } else {
      name = languageAttributes['en']!.language;
      flag = languageAttributes['en']!.flag;
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
