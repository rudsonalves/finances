import 'package:flutter/material.dart';

import '../../locator.dart';
import './category_state.dart';
import '../../common/models/icons_model.dart';
import '../../common/models/category_db_model.dart';
import '../../repositories/category/category_repository.dart';

class CategoryController extends ChangeNotifier {
  final _categoryRepository = locator.get<CategoryRepository>();

  CategoryController();

  CategoryState _state = CategoryStateInitial();

  CategoryState get state => _state;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoryNames {
    return _categoryRepository.categoriesMap.keys.toList();
  }

  void _changeState(CategoryState newState) {
    _state = newState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> init() async {
    await _categoryRepository.init();
    await getAllCategories();
  }

  Future<void> getAllCategories() async {
    _changeState(CategoryStateLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      _changeState(CategoryStateSuccess());
    } catch (err) {
      _changeState(CategoryStateError());
    }
  }

  Future<void> removeCategory(CategoryDbModel category) async {
    await _categoryRepository.deleteCategory(category);
  }

  IconModel categoryImage(String categoryName) {
    return _categoryRepository.categoriesMap[categoryName]!.categoryIcon;
  }

  Future<void> addCategory(CategoryDbModel category) async {
    await _categoryRepository.addCategory(category);
  }

  Future<void> updateCategory(CategoryDbModel category) async {
    await _categoryRepository.updateCategory(category);
  }
}
