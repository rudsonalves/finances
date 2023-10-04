import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/models/icons_model.dart';
import '../../common/constants/themes/app_icons.dart';
import '../../locator.dart';
import '../icons/icons_repository.dart';
import './category_repository.dart';
import '../../services/database/database_helper.dart';
import '../../common/models/category_db_model.dart';

class SqflileCategoryRepository implements CategoryRepository {
  final DatabaseHelper helper = locator.get<DatabaseHelper>();
  final Map<String, CategoryDbModel> _categories = {};
  bool isStarting = true;

  @override
  Map<String, CategoryDbModel> get categoriesMap => _categories;

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
          iconName: 'monetization on',
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
    List<Map<String, dynamic>> categories = await helper.queryAllCategories();
    _categories.clear();
    for (var categoryMap in categories) {
      final category = await CategoryDbModel.fromMap(categoryMap);
      _categories[category.categoryName] = category;
    }
  }

  @override
  Future<void> addCategory(CategoryDbModel category) async {
    int result =
        await locator.get<IconRepository>().addIcon(category.categoryIcon);
    if (result < 0) {
      throw Exception('addCategory.categoryIcon return id $result');
    }
    category.categoryIcon.iconId = result;
    result = await helper.insertCategory(category.toMap());
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
    await helper.deleteCategoryId(category.categoryId!);
    await getCategories();
  }

  @override
  Future<void> updateCategory(CategoryDbModel category) async {
    await locator.get<IconRepository>().updateIcon(category.categoryIcon);
    await helper.updateCategory(category.toMap());
    await getCategories();
  }

  @override
  Future<void> updateCategoryBudget(CategoryDbModel category) async {
    await helper.updateCategoryBudget(
      category.categoryId!,
      category.categoryBudget,
    );
    _categories[category.categoryName]!.categoryBudget =
        category.categoryBudget;
  }
}
