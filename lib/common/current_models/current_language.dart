import 'package:flutter/material.dart';

import '../models/language_model.dart';

class CurrentLanguage extends LanguageModel {
  final locale$ = ValueNotifier(const Locale('en', 'US'));

  Locale get locale => locale$.value;

  @override
  void setFromLocaleCode(String localeCode) {
    super.setFromLocaleCode(localeCode);
    locale$.value = getLocale();
  }
}
