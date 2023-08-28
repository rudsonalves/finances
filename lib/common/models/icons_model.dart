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
      iconId: map['iconId'] != null ? map['iconId'] as int : null,
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
