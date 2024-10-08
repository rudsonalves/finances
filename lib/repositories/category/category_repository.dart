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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/models/icons_model.dart';
import '../../common/constants/themes/app_icons.dart';
import '../../locator.dart';
import '../../store/stores/category_store.dart';
import '../icons/abstract_icons_repository.dart';
import 'abstract_category_repository.dart';
import '../../common/models/category_db_model.dart';

class CategoryRepository implements AbstractCategoryRepository {
  final _store = CatgoryStore();
  final Map<String, CategoryDbModel> _categories = {};
  bool isStarting = true;

  @override
  Map<String, CategoryDbModel> get categoriesMap => _categories;

  @override
  // ignore: prefer_for_elements_to_map_fromiterable
  Map<int, CategoryDbModel> get categoriesIdMap => Map.fromIterable(
        _categories.values,
        key: (category) => category.categoryId!,
        value: (category) => category,
      );

  @override
  List<CategoryDbModel> get categories => _categories.values.toList();

  @override
  int getIdByName(String name) {
    for (CategoryDbModel category in _categories.values) {
      if (category.categoryName == name) return category.categoryId!;
    }
    throw Exception('Category name $name not found!');
  }

  @override
  CategoryDbModel getCategoryId(int id) {
    CategoryDbModel category =
        _categories.values.firstWhere((category) => category.categoryId == id);

    return category;
  }

  @override
  Future<void> init() async {
    if (isStarting) {
      await getCategories();
      isStarting = false;
    }
  }

  @override
  Future<void> restart() async {
    isStarting = true;
    await init();
  }

  @override
  Future<void> firstCategory(AppLocalizations locale) async {
    await init();
    if (_categories.isEmpty) {
      final transferCategory = CategoryDbModel(
        categoryName: locale.categoryNameTransfers,
        categoryIcon: IconModel(
          iconName: 'shuffle',
          iconFontFamily: IconsFontFamily.FontelloIcons,
          iconColor: 0xFF0F8EE2,
        ),
      );
      await addCategory(transferCategory);
      final depositCategory = CategoryDbModel(
        categoryName: locale.categoryNameInputs,
        categoryIsIncome: true,
        categoryIcon: IconModel(
          iconName: 'attach money',
          iconFontFamily: IconsFontFamily.MaterialIcons,
          iconColor: 4280786688,
        ),
      );
      await addCategory(depositCategory);
      await getCategories();
    }
  }

  @override
  Future<void> getCategories() async {
    List<Map<String, dynamic>> categories = await _store.queryAllCategories();
    _categories.clear();
    for (var categoryMap in categories) {
      final category = await CategoryDbModel.fromMap(categoryMap);
      _categories[category.categoryName] = category;
    }
  }

  @override
  Future<void> addCategory(CategoryDbModel category) async {
    int result =
        await locator<AbstractIconRepository>().addIcon(category.categoryIcon);
    if (result < 0) {
      throw Exception('addCategory.categoryIcon return id $result');
    }
    category.categoryIcon.iconId = result;
    result = await _store.insertCategory(category.toMap());
    if (result < 0) {
      throw Exception('addCategory return id $result');
    }
    category.categoryId = result;
    await getCategories();
  }

  @override
  Future<void> deleteCategory(CategoryDbModel category) async {
    if (category.categoryId == null) {
      throw Exception('Category ${category.categoryName} don\'t have id');
    }
    await _store.deleteCategoryId(category.categoryId!);
    await getCategories();
  }

  @override
  Future<void> updateCategory(CategoryDbModel category) async {
    await locator<AbstractIconRepository>().updateIcon(category.categoryIcon);
    await _store.updateCategory(category.toMap());
    await getCategories();
  }

  @override
  Future<void> updateCategoryBudget(CategoryDbModel category) async {
    await _store.updateCategoryBudget(
      category.categoryId!,
      category.categoryBudget,
    );
    _categories[category.categoryName]!.categoryBudget =
        category.categoryBudget;
  }
}
