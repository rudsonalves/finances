import 'package:flutter/material.dart';

import '../constants/themes/app_icons.dart';

class CategoriesIcons {
  final _iconsList = AppIcons.iconNames(
    IconsFontFamily.MaterialIcons,
  );

  List<String> listOfIconsContains(String text) {
    return _iconsList.where((name) => name.contains(text)).toList();
  }

  List<String> get keys => _iconsList;

  IconData? getIconData(String iconName) {
    if (_iconsList.contains(iconName)) {
      return AppIcons.iconData(iconName);
    }
    return null;
  }
}
