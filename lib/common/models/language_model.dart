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
