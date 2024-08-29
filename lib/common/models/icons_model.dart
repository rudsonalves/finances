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

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants/themes/app_icons.dart';

class IconModel {
  int? iconId;
  String iconName;
  IconsFontFamily iconFontFamily;
  int iconColor;

  IconModel({
    this.iconId,
    required this.iconName,
    required this.iconFontFamily,
    this.iconColor = 0xFFB0B0B0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'iconId': iconId,
      'iconName': iconName,
      'iconFontFamily': iconFontFamily.name,
      'iconColor': iconColor,
    };
  }

  factory IconModel.fromMap(Map<String, dynamic> map) {
    return IconModel(
      iconId: map['iconId'] as int?,
      iconName: map['iconName'] as String,
      iconFontFamily: AppIcons.iconsFontFamily(map['iconFontFamily'] as String),
      iconColor: map['iconColor'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory IconModel.fromJson(String source) =>
      IconModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Icon iconWidget({
    double? size,
    Color? color,
  }) {
    return Icon(
      AppIcons.iconData(iconName, iconFontFamily),
      color: color ?? Color(iconColor),
      size: size,
    );
  }

  @override
  String toString() {
    return 'IconModel('
        ' iconId: $iconId;'
        ' iconName: $iconName;'
        ' iconFontFamily: ${iconFontFamily.name};'
        ' iconColor: $iconColor'
        ')';
  }
}
