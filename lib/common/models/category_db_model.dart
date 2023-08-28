import 'dart:convert';

import '../../locator.dart';
import '../../repositories/icons/icons_repository.dart';
import './icons_model.dart';

class CategoryDbModel {
  int? categoryId;
  String categoryName;
  IconModel categoryIcon;

  CategoryDbModel({
    this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  String toString() => 'Category('
      ' Id: $categoryId;'
      ' Name: "$categoryName";'
      ' Image: "${categoryIcon.iconName}" '
      '(FontFamily: ${categoryIcon.iconFontFamily.name}; '
      'Color: ${categoryIcon.iconColor})'
      ')';

  Map<String, dynamic> toMap() {
    if (categoryId != null) {
      return <String, dynamic>{
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon.iconId!,
      };
    } else {
      return <String, dynamic>{
        'categoryName': categoryName,
        'categoryIcon': categoryIcon.iconId!,
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
    );
  }

  String toJson() => json.encode(toMap());

  static Future<CategoryDbModel> fromJson(String source) async {
    return await CategoryDbModel.fromMap(
      json.decode(source) as Map<String, dynamic>,
    );
  }
}
