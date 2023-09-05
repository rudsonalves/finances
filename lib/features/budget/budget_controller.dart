import 'package:flutter/foundation.dart';

import '../../common/models/category_db_model.dart';
import '../../common/models/icons_model.dart';
import '../../locator.dart';
import '../../repositories/category/category_repository.dart';
import 'budget_state.dart';

class BudgetController extends ChangeNotifier {
  final _categoryRepository = locator.get<CategoryRepository>();

  BudgetState _state = BudgetStateInitial();

  BudgetState get state => _state;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  void _changeState(BudgetState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    await _categoryRepository.init();
    await getAllCategories();
  }

  Future<void> getAllCategories() async {
    _changeState(BudgetStateLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      _changeState(BudgetStateSuccess());
    } catch (err) {
      _changeState(BudgetStateError());
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
