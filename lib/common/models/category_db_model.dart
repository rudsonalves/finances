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
    final int? iconId = categoryIcon.iconId;
    if (iconId == null) {
      throw StateError(
        'CategoryDbModel cannot be serialized without categoryIcon.iconId.',
      );
    }

    final Map<String, dynamic> map = {
      'categoryName': categoryName,
      'categoryIcon': iconId,
      'categoryBudget': categoryBudget,
      'categoryIsIncome': categoryIsIncome ? 1 : 0,
    };

    if (categoryId != null) {
      map['categoryId'] = categoryId;
    }

    return map;
  }

  static Future<CategoryDbModel> fromMap(Map<String, dynamic> map) async {
    int iconId = map['categoryIcon'] as int;
    var categoryIcon =
        await locator<AbstractIconRepository>().getIconId(iconId);

    return CategoryDbModel(
      categoryId: map['categoryId'] as int?,
      categoryName: map['categoryName'] as String,
      categoryIcon: categoryIcon,
      categoryBudget: (map['categoryBudget'] as num).toDouble(),
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
