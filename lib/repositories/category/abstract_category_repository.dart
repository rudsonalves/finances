import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/models/category_db_model.dart';

abstract class AbstractCategoryRepository {
  Map<String, CategoryDbModel> get categoriesMap;
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
