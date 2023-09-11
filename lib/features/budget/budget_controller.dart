import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../../common/constants/app_constants.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/icons_model.dart';
import '../../locator.dart';
import '../../repositories/category/category_repository.dart';
import '../statistics/statistic_controller.dart';
import 'budget_state.dart';

class BudgetController extends ChangeNotifier {
  final _categoryRepository = locator.get<CategoryRepository>();
  final _statController = locator.get<StatisticsController>();
  double _totalBudget = 0.0;

  BudgetState _state = BudgetStateInitial();

  BudgetState get state => _state;

  double get totalBudget => _totalBudget;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoryNames {
    return _categoryRepository.categoriesMap.keys.toList();
  }

  void _changeState(BudgetState newState) {
    _state = newState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // bool _redraw = false;

  // bool get redraw {
  //   if (_redraw) {
  //     _redraw = false;
  //     return true;
  //   }
  //   return false;
  // }

  // void requestRedraw() {
  //   _redraw = true;
  // }

  Future<void> init() async {
    await _categoryRepository.init();
    await getAllCategories();
  }

  Future<void> getAllCategories() async {
    _changeState(BudgetStateLoading());

    try {
      if (!_statController.noData) {
        await _statController.getStatistics();
      }
      _sumTotalBudget();
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

  Future<void> setAllBudgets(StatisticMedium statReference) async {
    _changeState(BudgetStateLoading());

    try {
      final references = _statController.getReferences(statReference);
      final categories = _categoryRepository.categoriesMap;

      for (final categoryName in references.keys) {
        final category = categories[categoryName];
        double reference = references[categoryName]!;
        category!.categoryBudget = reference;
        await _categoryRepository.updateCategory(category);
      }
      _sumTotalBudget();
      _changeState(BudgetStateSuccess());
    } catch (err) {
      log('Error: $err');
      _changeState(BudgetStateError());
    }
  }

  void _sumTotalBudget() {
    final categories = _categoryRepository.categoriesMap;
    _totalBudget = 0.0;
    for (final category in categories.values) {
      _totalBudget += category.categoryBudget;
    }
  }

  Future<void> updateCategoryBudget(CategoryDbModel category) async {
    _changeState(BudgetStateLoading());
    try {
      await _categoryRepository.updateCategory(category);
      _sumTotalBudget();
      _changeState(BudgetStateSuccess());
    } catch (err) {
      log('Error: $err');
      _changeState(BudgetStateError());
    }
  }
}
