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

import '../../common/models/category_db_model.dart';

abstract class AbstractCategoryRepository {
  Map<String, CategoryDbModel> get categoriesMap;
  Map<int, CategoryDbModel> get categoriesIdMap;
  List<CategoryDbModel> get categories;
  Future<void> init();
  Future<void> restart();
  int getIdByName(String name);
  CategoryDbModel getCategoryId(int id);
  Future<void> getCategories();
  Future<void> addCategory(CategoryDbModel category);
  Future<void> updateCategory(CategoryDbModel category);
  Future<void> updateCategoryBudget(CategoryDbModel category);
  Future<void> deleteCategory(CategoryDbModel category);
  Future<void> firstCategory(AppLocalizations locale);
}
