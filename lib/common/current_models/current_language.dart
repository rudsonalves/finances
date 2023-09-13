import 'package:flutter/material.dart';

import '../constants/laguage_constants.dart';
import '../models/language_model.dart';

class CurrentLanguage extends LanguageModel {
  final locale$ = ValueNotifier(const Locale('en', 'US'));

  Locale get locale => locale$.value;

  @override
  void setFromLocaleCode(String localeCode) {
    if (languageAttributes.containsKey(localeCode)) {
      super.setFromLocaleCode(localeCode);
      locale$.value = getLocale();
    }
  }
}
