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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../../common/constants/app_constants.dart';
import '../../common/models/category_db_model.dart';
import '../../common/models/icons_model.dart';
import '../../locator.dart';
import '../../repositories/category/abstract_category_repository.dart';
import '../statistics/statistic_controller.dart';
import 'categories_state.dart';

class CategoriesController extends ChangeNotifier {
  final _categoryRepository = locator<AbstractCategoryRepository>();
  final _statController = locator<StatisticsController>();
  double _totalBudget = 0.0;

  CategoriesState _state = CategoriesStateInitial();

  CategoriesState get state => _state;

  double get totalBudget => _totalBudget;

  List<CategoryDbModel> get categories => _categoryRepository.categories;

  List<String> get categoryNames {
    return _categoryRepository.categoriesMap.keys.toList();
  }

  void _changeState(CategoriesState newState) {
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
    _state = CategoriesStateSuccess();
  }

  Future<void> getAllCategories() async {
    _changeState(CategoriesStateLoading());

    try {
      if (!_statController.noData) {
        await _statController.getStatistics(false);
        _statController.recalculate();
      }
      _sumTotalBudget();
      _changeState(CategoriesStateSuccess());
    } catch (err) {
      _changeState(CategoriesStateError());
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
    _changeState(CategoriesStateLoading());

    try {
      final references = _statController.getReferences(statReference);
      final categories = _categoryRepository.categoriesMap;

      for (final categoryName in references.keys) {
        final category = categories[categoryName];
        double signal = category!.categoryIsIncome ? 1 : -1;
        double reference = signal * references[categoryName]!.abs();
        category.categoryBudget = reference;
        await _categoryRepository.updateCategoryBudget(category);
      }
      _sumTotalBudget();
      _changeState(CategoriesStateSuccess());
    } catch (err) {
      log('Error: $err');
      _changeState(CategoriesStateError());
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
    _changeState(CategoriesStateLoading());
    try {
      await _categoryRepository.updateCategoryBudget(category);
      _sumTotalBudget();
      _changeState(CategoriesStateSuccess());
    } catch (err) {
      log('Error: $err');
      _changeState(CategoriesStateError());
    }
  }
}
