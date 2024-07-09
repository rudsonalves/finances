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

import 'icons/material_icons_codes.dart';
import 'icons/trademarks_icons_codes.dart';
import 'icons/fontello_icons_codes.dart';

enum IconsFontFamily {
  // ignore: constant_identifier_names
  MaterialIcons,
  // ignore: constant_identifier_names
  TrademarkIcons,
  // ignore: constant_identifier_names
  FontelloIcons,
}

class AppIcons {
  AppIcons._();

  static IconsFontFamily iconsFontFamily(String fontFamilyName) {
    if (fontFamilyName == IconsFontFamily.TrademarkIcons.name) {
      return IconsFontFamily.TrademarkIcons;
    } else if (fontFamilyName == IconsFontFamily.FontelloIcons.name) {
      return IconsFontFamily.FontelloIcons;
    }
    return IconsFontFamily.MaterialIcons;
  }

  // ignore: flutter_tree_shake_icons
  static _materialIcons(int codePoint, String fontFamilyName) => IconData(
        codePoint,
        fontFamily: fontFamilyName,
      );

  static List<String> iconNames(IconsFontFamily fontFamily) {
    switch (fontFamily) {
      case IconsFontFamily.TrademarkIcons:
        return trademarksIconsCodes.keys.toList();
      case IconsFontFamily.FontelloIcons:
        return fontelloIconsCodes.keys.toList();
      default:
        return materialIconsCodes.keys.toList();
    }
  }

  static IconData? iconData(
    String iconName, [
    IconsFontFamily fontFamily = IconsFontFamily.MaterialIcons,
  ]) {
    Map<String, int> icons;
    String fontFamilyName = fontFamily.name;
    switch (fontFamily) {
      case IconsFontFamily.TrademarkIcons:
        icons = trademarksIconsCodes;
        break;
      case IconsFontFamily.FontelloIcons:
        icons = fontelloIconsCodes;
        break;
      default:
        icons = materialIconsCodes;
    }
    if (icons.containsKey(iconName)) {
      // log('${icons[iconName]!}, $fontFamilyName');
      return _materialIcons(
        icons[iconName]!,
        fontFamilyName,
      );
    }
    return null;
  }
}
