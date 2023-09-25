import 'dart:convert';

import '../../locator.dart';
import '../../repositories/icons/icons_repository.dart';
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
    var categoryIcon = await locator.get<IconRepository>().getIconId(iconId);

    return CategoryDbModel(
      categoryId: map['categoryId'] != null ? map['categoryId'] as int : null,
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
