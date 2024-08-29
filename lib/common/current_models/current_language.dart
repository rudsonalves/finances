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
