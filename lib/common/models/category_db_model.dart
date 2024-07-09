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

import 'dart:convert';

import '../../locator.dart';
import '../../repositories/icons/abstract_icons_repository.dart';
import './icons_model.dart';

class CategoryDbModel {
  int? categoryId;
  String categoryName;
  IconModel categoryIcon;
  double categoryBudget;
  bool categoryIsIncome;

  CategoryDbModel({
    this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    this.categoryBudget = 0.0,
    this.categoryIsIncome = false,
  });

  @override
  String toString() => 'Category('
      ' Id: $categoryId;'
      ' Name: "$categoryName";'
      ' Image: "${categoryIcon.iconName}" '
      '(FontFamily: ${categoryIcon.iconFontFamily.name}; '
      'Color: ${categoryIcon.iconColor});'
      ' Budget: $categoryBudget;'
      ' IsIncome: $categoryIsIncome'
      ')';

  Map<String, dynamic> toMap() {
    if (categoryId != null) {
      return <String, dynamic>{
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon.iconId!,
        'categoryBudget': categoryBudget,
        'categoryIsIncome': categoryIsIncome ? 1 : 0,
      };
    } else {
      return <String, dynamic>{
        'categoryName': categoryName,
        'categoryIcon': categoryIcon.iconId!,
        'categoryBudget': categoryBudget,
        'categoryIsIncome': categoryIsIncome ? 1 : 0,
      };
    }
  }

  static Future<CategoryDbModel> fromMap(Map<String, dynamic> map) async {
    int iconId = map['categoryIcon'] as int;
    var categoryIcon =
        await locator<AbstractIconRepository>().getIconId(iconId);

    return CategoryDbModel(
      categoryId: map['categoryId'] as int?,
      categoryName: map['categoryName'] as String,
      categoryIcon: categoryIcon,
      categoryBudget: map['categoryBudget'] as double,
      categoryIsIncome: (map['categoryIsIncome'] as int) == 1,
    );
  }

  String toJson() => json.encode(toMap());

  static Future<CategoryDbModel> fromJson(String source) async {
    return await CategoryDbModel.fromMap(
      json.decode(source) as Map<String, dynamic>,
    );
  }
}
